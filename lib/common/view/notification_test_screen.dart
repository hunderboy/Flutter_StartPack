import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_start_pack/common/layout/default_layout.dart';
import 'package:flutter_start_pack/common/notification/local_notification_service.dart';
import 'package:flutter_start_pack/common/theme/app_colors.dart';
import 'package:flutter_start_pack/common/view_component/toast/custom_snack_bar.dart';

/// 로컬 알림 테스트 화면 (마이 탭 → 알림 테스트)
/// 알림을 탭하면 payload('/notification-test?from=notification') 로 이 화면에 다시 진입한다.
class NotificationTestScreen extends ConsumerWidget {
  static String get routeName => 'notificationTest';

  /// 알림 payload 로 사용할 경로
  static const String tapPayload = '/notification-test?from=notification';

  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(localNotificationProvider);
    final fromNotification = GoRouterState.of(context).uri.queryParameters['from'] == 'notification';
    final colors = context.colors;

    Future<bool> ensurePermission() async {
      final granted = await service.requestPermission();
      if (!granted && context.mounted) {
        showCustomSnackBar(context, '알림 권한이 꺼져 있어요. 설정에서 허용해 주세요.', SnackBarType.negative);
      }
      return granted;
    }

    return DefaultLayout(
      title: '알림 테스트',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (fromNotification)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded),
                  SizedBox(width: 12),
                  Expanded(child: Text('알림을 탭해서 이 화면으로 들어왔어요.')),
                ],
              ),
            ),
          FilledButton.icon(
            icon: const Icon(Icons.notifications_rounded),
            label: const Text('지금 알림 보내기'),
            onPressed: () async {
              if (!await ensurePermission()) return;
              await service.show(
                title: '테스트 알림',
                body: '탭하면 알림 테스트 화면으로 이동합니다.',
                payload: tapPayload,
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded),
            label: const Text('10초 뒤 알림 예약'),
            onPressed: () async {
              if (!await ensurePermission()) return;
              await service.schedule(
                title: '예약 알림',
                body: '10초 전에 예약한 알림입니다.',
                after: const Duration(seconds: 10),
                payload: tapPayload,
              );
              if (context.mounted) {
                showCustomSnackBar(
                  context,
                  '10초 뒤 알림이 와요. 앱을 백그라운드로 보내 확인해 보세요.',
                  SnackBarType.positive,
                );
              }
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await service.cancelAll();
              if (context.mounted) showCustomSnackBar(context, '모든 알림을 취소했어요.');
            },
            child: Text('모든 알림 취소', style: TextStyle(color: colors.danger)),
          ),
          const SizedBox(height: 16),
          Text(
            'Android 는 배터리 최적화를 위해 예약 알림이 수 초~수 분 늦게 올 수 있어요.',
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
