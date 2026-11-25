import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_start_pack/common/provider/route/router_guard_provider.dart';

/// 앱 전역 GoRouter
/// main.dart 에서 ref.watch(routerProvider) 로 받아 MaterialApp.router 에 연결한다.
final routerProvider = Provider<GoRouter>((ref) {
  final guard = ref.read(routerGuardProvider);

  return GoRouter(
    routes: guard.routes,
    initialLocation: '/splash',
    refreshListenable: guard,     // guard.notifyListeners() 시 redirect 재실행
    redirect: guard.redirectLogic,
    debugLogDiagnostics: false,
  );
});
