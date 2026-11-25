import 'package:go_router/go_router.dart';

import 'package:flutter_start_pack/common/view/splash_screen.dart';
import 'package:flutter_start_pack/lobby/lobby_screen.dart';
import 'package:flutter_start_pack/user/view/social_login_screen.dart';

/// 앱 전체 Route 목록
/// 새로운 화면 추가 시 이곳에 GoRoute 를 추가한다.
///
/// 이동 방법
///   context.goNamed(LobbyScreen.routeName);   // 스택 교체
///   context.pushNamed(SomeScreen.routeName, extra: data); // 스택 추가
List<GoRoute> buildAppRoutes() => [
  GoRoute(
    path: '/',
    name: LobbyScreen.routeName,
    builder: (_, _) => const LobbyScreen(),
    routes: [
      // Lobby 하위 화면 예시
      // GoRoute(
      //   path: 'setting',
      //   name: SettingScreen.routeName,
      //   builder: (_, _) => const SettingScreen(),
      // ),
    ],
  ),
  GoRoute(
    path: '/splash',
    name: SplashScreen.routeName,
    builder: (_, _) => const SplashScreen(),
  ),
  GoRoute(
    path: '/login',
    name: SocialLoginScreen.routeName,
    builder: (_, _) => const SocialLoginScreen(),
  ),
];
