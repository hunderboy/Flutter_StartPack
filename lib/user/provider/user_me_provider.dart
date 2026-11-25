import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/storage/secure_storage.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';

/// 유저 상태를 관리하는 userMeProvider (UserModelBase? 상태 관리)
///   null             : 로그아웃 상태
///   UserModelLoading : 계정정보 가져오는 중 (Splash / 로그인 진행 중)
///   UserModelError   : 계정정보 가져오는데 에러 발생
///   UserModel        : 로그인 완료
///
/// RouterGuardProvider 가 이 상태를 감시하여 화면을 자동으로 전환한다.
/// (화면에서 직접 context.go 하지 않고, 상태만 변경하면 된다.)
final userMeProvider = StateNotifierProvider<UserMeStateNotifier, UserModelBase?>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return UserMeStateNotifier(storage: storage);
});

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final FlutterSecureStorage storage;

  UserMeStateNotifier({required this.storage}) : super(UserModelLoading()) {
    getMe();
  }

  /// 내정보 요청 (앱 진입 시) ---------------------------------------------------------
  Future<void> getMe() async {
    await Future.delayed(splashDuration); // Splash 화면 3초 보여주기

    // TODO: 자동 로그인이 필요하면 아래 주석을 해제하고 서버에 내정보 요청
    // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    // if (accessToken != null) {
    //   state = await userMeRepository.getMe();
    //   return;
    // }

    state = null; // 로그인 정보 없음 → 로그인 화면으로 이동
  }

  /// 구글 로그인 ---------------------------------------------------------------------
  /// 현재는 Fake 로그인 : 1초 대기 후 더미 유저로 로그인 처리 → Lobby 화면으로 이동
  Future<bool> googleLogin() async {
    try {
      state = UserModelLoading();

      // TODO: 실제 연동 시 google_sign_in 패키지로 idToken 획득
      //   final googleUser = await GoogleSignIn.instance.authenticate();
      //   final idToken = googleUser.authentication.idToken;
      // TODO: 서버에 idToken 전송 → accessToken / refreshToken 수신 후 저장
      //   await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      //   await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await Future.delayed(const Duration(seconds: 1));

      state = UserModel(
        id: 1,
        name: '홍길동',
        email: 'test@gmail.com',
        loginType: SocialLoginType.google,
      );
      return true;
    } catch (error, stack) {
      if (kDebugMode) debugPrint('구글 로그인 실패 : $error\n$stack');
      state = UserModelError(message: '구글 로그인 실패: $error');
      return false;
    }
  }

  /// 애플 로그인 ---------------------------------------------------------------------
  /// TODO: sign_in_with_apple 패키지로 identityToken 획득 후 서버 로그인
  Future<bool> appleLogin() async => false;

  /// 카카오 로그인 -------------------------------------------------------------------
  /// TODO: kakao_flutter_sdk_user 패키지로 accessToken 획득 후 서버 로그인
  Future<bool> kakaoLogin() async => false;

  /// 네이버 로그인 -------------------------------------------------------------------
  /// TODO: flutter_naver_login 패키지로 accessToken 획득 후 서버 로그인
  Future<bool> naverLogin() async => false;

  /// 로그아웃 -----------------------------------------------------------------------
  Future<void> logout() async {
    state = null; // → 로그인 화면으로 이동

    await Future.wait([
      storage.delete(key: ACCESS_TOKEN_KEY),
      storage.delete(key: REFRESH_TOKEN_KEY),
    ]);
  }
}
