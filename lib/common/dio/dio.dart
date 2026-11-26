import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/storage/secure_storage.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// 공통 BaseOptions (기본 Dio / 토큰 재발급 Dio / 재전송 Dio 가 같은 설정을 공유한다)
BaseOptions _baseOptions() => BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
);

/// 디버그 모드에서만 로그를 출력하는 인터셉터 목록
List<Interceptor> _loggerInterceptors() => [
  if (kDebugMode) PrettyDioLogger(requestHeader: true, requestBody: true),
];

/// 공용 Dio
/// Repository(Retrofit) 생성 시 ref.watch(dioProvider) 로 주입받아 사용한다.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());

  final storage = ref.watch(secureStorageProvider);

  /// 인터셉터 추가 : PrettyDioLogger (디버그 모드에서만 로그 출력)
  dio.interceptors.addAll(_loggerInterceptors());

  /// 인터셉터 추가 : CustomInterceptor (토큰 자동 주입 / 401 토큰 재발급)
  dio.interceptors.add(
    CustomInterceptor(
      storage: storage,
      onLogout: () => ref.read(userMeProvider.notifier).logout(),
    ),
  );

  return dio;
});

/// Interceptor
///
/// QueuedInterceptor 를 사용하므로 onError 가 한 번에 하나씩 순서대로 처리된다.
/// 동시에 여러 요청이 401 을 받아도
///   1) 첫 번째 에러만 실제로 토큰을 재발급하고
///   2) 나머지는 "이미 새 토큰으로 바뀌었는지" 확인한 뒤 재발급 없이 새 토큰으로 재전송한다.
///
/// 재전송은 별도의 [_retryDio] 로 보낸다.
/// (같은 Dio 로 재전송하면, 재전송한 요청이 다시 401 일 때 큐가 서로를 기다리며 멈출 수 있음)
class CustomInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage storage;

  /// Refresh 토큰까지 만료되었을 때 호출 (로그아웃 처리)
  final VoidCallback onLogout;

  /// 토큰 재발급 요청용 Dio (인터셉터 없음)
  final Dio _refreshDio;

  /// 실패한 요청 재전송용 Dio (로거만 있고 CustomInterceptor 는 없음)
  final Dio _retryDio;

  CustomInterceptor({
    required this.storage,
    required this.onLogout,
    Dio? refreshDio,
    Dio? retryDio,
  }) : _refreshDio = refreshDio ?? (Dio(_baseOptions())..interceptors.addAll(_loggerInterceptors())),
       _retryDio = retryDio ?? (Dio(_baseOptions())..interceptors.addAll(_loggerInterceptors()));

  /// 토큰 재발급 API 경로
  /// TODO: 서버 스펙에 맞게 토큰 재발급 API 경로 수정
  static const refreshPath = '/auth/token';

  /// 1) 요청을 보낼때
  /// 요청 Header 에 `accessToken: true` 가 있으면
  /// storage 에서 실제 토큰을 꺼내 `authorization: Bearer $token` 으로 변경한다.
  /// (Retrofit 에서는 @Headers({'accessToken': 'true'}) 로 사용)
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    const tokenHeaders = {'accessToken': ACCESS_TOKEN_KEY, 'refreshToken': REFRESH_TOKEN_KEY};

    for (final MapEntry(key: headerName, value: storageKey) in tokenHeaders.entries) {
      if (options.headers[headerName] != 'true') continue;

      options.headers.remove(headerName);
      final token = await storage.read(key: storageKey);
      if (token == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: '$headerName 이 없습니다. 다시 로그인해주세요.',
          ),
        );
      }
      options.headers['authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  /// 2) 에러가 났을때
  /// 401 에러 시 토큰 재발급을 시도하고, 재발급되면 새로운 토큰으로 원래 요청을 재전송한다.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    }

    final options = err.requestOptions;
    final isStatus401 = err.response?.statusCode == 401;           // 엑세스 토큰 문제
    final isPathRefresh = options.path.endsWith(refreshPath);     // 토큰 재발급 요청 중 에러
    final usedAuth = options.headers['authorization'] as String?; // 실패한 요청에 사용한 토큰

    // 401 이 아니거나, 토큰을 쓰지 않은 요청이면 그대로 에러를 던진다.
    if (!isStatus401 || isPathRefresh || usedAuth == null) {
      return handler.reject(err);
    }

    try {
      // 큐에서 앞선 요청이 이미 토큰을 재발급했다면 → 재발급 없이 새 토큰으로 재전송
      final currentAccessToken = await storage.read(key: ACCESS_TOKEN_KEY);
      if (currentAccessToken != null && usedAuth != 'Bearer $currentAccessToken') {
        return handler.resolve(await _retry(options, currentAccessToken));
      }

      final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken == null) {
        return handler.reject(err);
      }

      final newAccessToken = await _refreshAccessToken(refreshToken);
      return handler.resolve(await _retry(options, newAccessToken));
    } on _RefreshExpiredException catch (e) {
      // Refresh 토큰도 유효하지 않음 → 로그아웃 처리
      onLogout();
      return handler.reject(e.error);
    } on DioException catch (e) {
      // 네트워크 오류 등 → 로그아웃 없이 에러만 전달
      return handler.reject(e);
    } catch (_) {
      return handler.reject(err);
    }
  }

  /// 토큰 재발급 후 새 accessToken 을 저장하고 반환한다.
  /// 서버가 401 / 403 을 주면 Refresh 토큰 만료로 보고 [_RefreshExpiredException] 을 던진다.
  Future<String> _refreshAccessToken(String refreshToken) async {
    try {
      // TODO: 서버 스펙에 맞게 응답 파싱 수정 (refreshToken 도 같이 갱신된다면 함께 저장)
      final resp = await _refreshDio.post(
        '$serverIP$refreshPath',
        options: Options(headers: {'authorization': 'Bearer $refreshToken'}),
      );

      final accessToken = resp.data['accessToken'] as String;
      await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
      return accessToken;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) throw _RefreshExpiredException(e);
      rethrow;
    }
  }

  /// 실패했던 요청의 토큰만 변경하여 재전송
  Future<Response<dynamic>> _retry(RequestOptions options, String accessToken) {
    options.headers['authorization'] = 'Bearer $accessToken';
    return _retryDio.fetch(options);
  }
}

class _RefreshExpiredException implements Exception {
  final DioException error;
  _RefreshExpiredException(this.error);
}
