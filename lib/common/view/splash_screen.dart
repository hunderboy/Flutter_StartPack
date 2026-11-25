import 'package:flutter/material.dart';

import 'package:flutter_start_pack/common/const/colors.dart';

/// Splash 화면
/// 화면 자체는 UI 만 담당하고, 화면 전환은 RouterGuardProvider 가 담당한다.
///   userMeProvider 초기화(getMe) 시 splashDuration(3초) 대기
///   → 로그인 정보 없음(null) → redirect '/login'
class SplashScreen extends StatelessWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.Primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Flutter Start Pack',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
