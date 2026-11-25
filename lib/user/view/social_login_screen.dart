import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/const/colors.dart';
import 'package:flutter_start_pack/common/layout/loader_overlay.dart';
import 'package:flutter_start_pack/common/view_component/toast/custom_snack_bar.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';
import 'package:flutter_start_pack/user/view_component/ui_social_login_screen/social_login_button.dart';

/// 소셜 로그인 화면 (구글 / 애플 / 카카오 / 네이버)
/// 로그인 성공 시 userMeProvider 상태가 UserModel 로 변경되고,
/// RouterGuardProvider 가 이를 감지하여 Lobby 화면으로 이동시킨다.
class SocialLoginScreen extends ConsumerWidget {
  static String get routeName => 'login';

  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userMeProvider);
    final notifier = ref.read(userMeProvider.notifier);

    /// 로그인 실패 시 SnackBar 표시
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (next is UserModelError) {
        showCustomSnackBar(context, '로그인에 실패했습니다.', SnackBarType.negative);
      }
    });

    /// 아직 연동되지 않은 소셜 로그인 처리
    Future<void> notReady(String name, Future<bool> Function() login) async {
      final success = await login();
      if (!success && context.mounted) {
        showCustomSnackBar(context, '$name 로그인은 준비 중입니다.');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoaderOverlay(
        isLoading: user is UserModelLoading,
        child: SafeArea(
          child: Column(
            children: [
              /// 로고 영역
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch_rounded, size: 72, color: AppColor.Primary),
                    SizedBox(height: 16),
                    Text(
                      'Flutter Start Pack',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColor.Grey_100,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '소셜 계정으로 간편하게 시작하세요.',
                      style: TextStyle(fontSize: 14, color: AppColor.Grey_70),
                    ),
                  ],
                ),
              ),

              /// 구글
              SocialLoginButton(
                key: const Key('google_login_button'),
                text: 'Google로 시작하기',
                logoAssetPath: 'asset/svg/logo/logo_google.svg',
                backgroundColor: AppColor.Google_White,
                textColor: AppColor.Grey_100,
                borderColor: AppColor.Grey_10,
                onPressed: () => notifier.googleLogin(),
              ),

              /// 애플
              SocialLoginButton(
                key: const Key('apple_login_button'),
                text: 'Apple로 시작하기',
                logoAssetPath: 'asset/svg/logo/logo_apple.svg',
                backgroundColor: AppColor.Apple_Black,
                textColor: Colors.white,
                logoColor: Colors.white,
                onPressed: () => notReady('Apple', notifier.appleLogin),
              ),

              /// 카카오
              SocialLoginButton(
                key: const Key('kakao_login_button'),
                text: '카카오로 시작하기',
                logoAssetPath: 'asset/svg/logo/logo_kakao.svg',
                backgroundColor: AppColor.Kakao_Yellow,
                textColor: AppColor.Grey_100,
                onPressed: () => notReady('카카오', notifier.kakaoLogin),
              ),

              /// 네이버
              SocialLoginButton(
                key: const Key('naver_login_button'),
                text: '네이버로 시작하기',
                logoAssetPath: 'asset/svg/logo/logo_naver.svg',
                backgroundColor: AppColor.Naver_Green,
                textColor: Colors.white,
                onPressed: () => notReady('네이버', notifier.naverLogin),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
