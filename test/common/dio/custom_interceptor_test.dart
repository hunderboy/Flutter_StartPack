import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/dio/dio.dart';

/// 가짜 서버
///   - 일반 API     : 'Bearer $validToken' 이면 200, 아니면 401
///   - 토큰 재발급  : refreshStatus 가 200 이면 새 토큰 발급, 아니면 해당 status 로 실패
class FakeServerAdapter implements HttpClientAdapter {
  String validToken = 'new-access';
  int refreshStatus = 200;
  int refreshCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (options.path.endsWith(CustomInterceptor.refreshPath)) {
      refreshCount++;
      if (refreshStatus != 200) return _json({'message': 'refresh failed'}, refreshStatus);
      return _json({'accessToken': validToken}, 200);
    }

    final ok = options.headers['authorization'] == 'Bearer $validToken';
    return ok ? _json({'ok': true}, 200) : _json({'message': 'unauthorized'}, 401);
  }

  ResponseBody _json(Map<String, dynamic> body, int status) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeServerAdapter server;
  late FlutterSecureStorage storage;
  late Dio dio;
  late int logoutCount;

  Dio fakeDio() => Dio()..httpClientAdapter = server;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      ACCESS_TOKEN_KEY: 'old-access',
      REFRESH_TOKEN_KEY: 'refresh',
    });
    storage = const FlutterSecureStorage();
    server = FakeServerAdapter();
    logoutCount = 0;

    dio = fakeDio()
      ..interceptors.add(
        CustomInterceptor(
          storage: storage,
          onLogout: () => logoutCount++,
          refreshDio: fakeDio(),
          retryDio: fakeDio(),
        ),
      );
  });

  Future<Response<dynamic>> authedGet() =>
      dio.get('https://api.test/me', options: Options(headers: {'accessToken': 'true'}));

  test('accessToken 헤더를 저장된 토큰으로 바꿔서 보낸다', () async {
    server.validToken = 'old-access';

    final resp = await authedGet();

    expect(resp.statusCode, 200);
    expect(resp.requestOptions.headers['authorization'], 'Bearer old-access');
    expect(resp.requestOptions.headers.containsKey('accessToken'), isFalse);
  });

  test('저장된 accessToken 이 없으면 요청을 보내지 않고 취소한다', () async {
    FlutterSecureStorage.setMockInitialValues({});

    await expectLater(
      authedGet(),
      throwsA(isA<DioException>().having((e) => e.type, 'type', DioExceptionType.cancel)),
    );
  });

  test('동시에 여러 요청이 401 을 받아도 토큰 재발급은 한 번만 한다', () async {
    final responses = await Future.wait([authedGet(), authedGet(), authedGet()]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(server.refreshCount, 1);
    expect(await storage.read(key: ACCESS_TOKEN_KEY), 'new-access');
    expect(logoutCount, 0);
  });

  test('Refresh 토큰이 만료(401)되면 로그아웃한다', () async {
    server.refreshStatus = 401;

    await expectLater(authedGet(), throwsA(isA<DioException>()));
    expect(logoutCount, 1);
  });

  test('토큰 재발급이 서버 오류(500)로 실패하면 로그아웃하지 않는다', () async {
    server.refreshStatus = 500;

    await expectLater(authedGet(), throwsA(isA<DioException>()));
    expect(logoutCount, 0);
  });

  test('토큰을 쓰지 않은 요청의 401 은 재발급 없이 그대로 에러를 던진다', () async {
    await expectLater(dio.get('https://api.test/public'), throwsA(isA<DioException>()));
    expect(server.refreshCount, 0);
  });
}
