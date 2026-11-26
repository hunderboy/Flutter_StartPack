import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_start_pack/common/layout/default_layout.dart';
import 'package:flutter_start_pack/common/theme/app_colors.dart';
import 'package:flutter_start_pack/common/theme/theme_mode_provider.dart';
import 'package:flutter_start_pack/common/view/notification_test_screen.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// 마이 탭 : 로그인 유저 정보 + 로그아웃
class MyPageTab extends ConsumerWidget {
  const MyPageTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userMeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colors = context.colors;

    return DefaultLayout(
      title: '마이',
      body: ListView(
        children: [
          if (user is UserModel)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: colors.surfaceSubtle,
                child: Icon(Icons.person_rounded, color: colors.textTertiary),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${user.email} · ${user.loginType.name}'),
            ),
          const Divider(height: 1),

          /// 테마 설정 : 시스템 / 라이트 / 다크
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                const Text('테마', style: TextStyle(fontSize: 16)),
                const Spacer(),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('시스템')),
                    ButtonSegment(value: ThemeMode.light, label: Text('라이트')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('다크')),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selected) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(selected.first),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('알림 테스트'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(NotificationTestScreen.routeName),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Icon(Icons.logout_rounded, color: colors.danger),
            title: Text('로그아웃', style: TextStyle(color: colors.danger)),
            // 상태만 null 로 변경하면 RouterGuardProvider 가 로그인 화면으로 이동시킨다.
            onTap: () => ref.read(userMeProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
