import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_start_pack/common/provider/route/app_routes.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// GoRouter 사용을 위해
/// 각 Route 정보와 Redirect 로직을 가지고 있는 RouterGuardProvider
final routerGuardProvider = ChangeNotifierProvider<RouterGuardProvider>((ref) {
  return RouterGuardProvider(ref: ref);
});

class RouterGuardProvider extends ChangeNotifier {
  final Ref ref;

  RouterGuardProvider({required this.ref}) {
    /// 유저 상태 변화 감지
    /// listen 시작 시 userMeProvider 인스턴스가 없다면 생성되며, 내부 로직(getMe)도 실행된다.
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        if (kDebugMode) {
          debugPrint('🔄 RouterGuard: userMeProvider 변경 (${previous.runtimeType} -> ${next.runtimeType})');
        }
        notifyListeners(); // GoRouter 의 refreshListenable 로 연결되어 redirectLogic 이 실행됨
      }
    });
  }

  /// 라우팅은 app_routes.dart 에서 따로 관리
  List<GoRoute> get routes => buildAppRoutes();

  /// userMeProvider 상태에 따라 이동할 화면을 결정한다.
  ///   UserModelLoading → Splash 유지 (로그인 화면에서 로그인 중이면 그대로 유지)
  ///   null / Error     → Login
  ///   UserModel        → Lobby
  String? redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);
    final location = state.matchedLocation;

    final isLoginScreen = location == '/login';
    final isSplashScreen = location == '/splash';

    String? result;

    if (user is UserModelLoading) {
      // 로딩 중에는 Splash / Login 화면에만 머무르게 한다.
      result = (isLoginScreen || isSplashScreen) ? null : '/splash';
    } else if (user == null || user is UserModelError) {
      // 로그아웃 상태 또는 에러 → 로그인 화면으로
      result = isLoginScreen ? null : '/login';
    } else if (user is UserModel) {
      // 로그인 완료 → Splash / Login 화면에 있다면 Lobby 로
      result = (isLoginScreen || isSplashScreen) ? '/' : null;
    }

    if (kDebugMode) {
      debugPrint('🚀 redirect : $location (${user.runtimeType}) → ${result ?? '유지'}');
    }
    return result;
  }
}
