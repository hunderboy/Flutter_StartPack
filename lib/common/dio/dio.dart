import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/storage/secure_storage.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// 공용 Dio
/// Repository(Retrofit) 생성 시 ref.watch(dioProvider) 로 주입받아 사용한다.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  /// 인터셉터 추가 : PrettyDioLogger (디버그 모드에서만 로그 출력)
  if (kDebugMode) {
    dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true));
  }

  /// 인터셉터 추가 : CustomInterceptor (토큰 자동 주입 / 401 토큰 재발급)
  dio.interceptors.add(CustomInterceptor(storage: storage, ref: ref));

  return dio;
});

/// Interceptor
/// 동시에 여러 요청이 401 을 받는 경우 토큰 재발급이 중복될 수 있으므로,
/// 필요하다면 QueuedInterceptor 로 변경하는 것을 권장한다.
class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  /// 1) 요청을 보낼때
  /// 요청 Header 에 `accessToken: true` 가 있으면
  /// storage 에서 실제 토큰을 꺼내 `authorization: Bearer $token` 으로 변경한다.
  /// (Retrofit 에서는 @Headers({'accessToken': 'true'}) 로 사용)
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);
      if (token == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: '인증 토큰이 없습니다. 다시 로그인해주세요.',
          ),
        );
      }
      options.headers['authorization'] = 'Bearer $token';
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);
      if (token == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Refresh 토큰이 없습니다. 다시 로그인해주세요.',
          ),
        );
      }
      options.headers['authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  /// 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return super.onResponse(response, handler);
  }

  /// 3) 에러가 났을때
  /// 401 에러 시 토큰 재발급을 시도하고, 재발급되면 새로운 토큰으로 원래 요청을 재전송한다.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');
    }

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken 이 아예 없으면 에러를 그대로 던진다.
    if (refreshToken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;            // 엑세스 토큰 문제
    final isPathRefresh = err.requestOptions.path == '/auth/token'; // 토큰 재발급 요청 중 에러

    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        // TODO: 서버 스펙에 맞게 토큰 재발급 API 경로 / 응답 파싱 수정
        final resp = await dio.post(
          '$serverIP/auth/token',
          options: Options(headers: {'authorization': 'Bearer $refreshToken'}),
        );

        final accessToken = resp.data['accessToken'] as String;
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 실패했던 요청의 토큰만 변경하여 재전송
        final options = err.requestOptions;
        options.headers['authorization'] = 'Bearer $accessToken';
        final response = await dio.fetch(options);

        return handler.resolve(response);
      } on DioException catch (e) {
        // Refresh 토큰도 유효하지 않음 → 로그아웃 처리
        ref.read(userMeProvider.notifier).logout();
        return handler.reject(e);
      } catch (_) {
        return handler.reject(err);
      }
    }

    return handler.reject(err);
  }
}
