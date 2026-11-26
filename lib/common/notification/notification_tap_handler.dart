import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/notification/local_notification_service.dart';
import 'package:flutter_start_pack/common/provider/route/go_router.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// 알림 탭 → 화면 이동 처리
/// main.dart 의 App 에서 ref.watch(notificationTapHandlerProvider) 로 활성화한다.
///
/// - 알림 payload 가 '/' 로 시작하면 GoRouter 경로로 보고 이동한다.
/// - 로그인 전(Splash / Login)이면 이동을 보류했다가, 로그인 완료(UserModel) 시점에 이동한다.
///   (로그인 전에 이동해도 RouterGuard 가 다시 막기 때문)
/// - 앱 종료 상태에서 알림을 탭해 실행된 경우도 같은 방식으로 처리된다.
final notificationTapHandlerProvider = Provider<void>((ref) {
  final service = ref.read(localNotificationProvider);

  String? pendingPath;

  void navigate(String path) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) debugPrint('🔔 알림 탭 → $path');
      ref.read(routerProvider).go(path);
    });
  }

  void handlePayload(String? payload) {
    if (payload == null || !payload.startsWith('/')) return;

    if (ref.read(userMeProvider) is UserModel) {
      navigate(payload);
    } else {
      pendingPath = payload;
    }
  }

  // 로그인 완료 시 보류 중인 이동 처리
  ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
    final path = pendingPath;
    if (next is UserModel && path != null) {
      pendingPath = null;
      navigate(path);
    }
  });

  // 종료 상태에서 알림 탭으로 실행된 경우
  handlePayload(service.consumeLaunchPayload());

  // 실행 중 알림 탭
  final StreamSubscription<String?> subscription = service.onTap.listen(handlePayload);
  ref.onDispose(subscription.cancel);
});
