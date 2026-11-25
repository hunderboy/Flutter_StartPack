import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/theme/app_colors.dart';
import 'package:flutter_start_pack/common/theme/theme_mode_provider.dart';

/// 테마 변경 버튼 (시스템 / 라이트 / 다크)
/// AppBar actions 나 화면 우측 상단 등 어디서든 재사용한다.
/// 아이콘은 현재 선택된 테마 모드를 보여준다.
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  static const _options = [
    (mode: ThemeMode.system, label: '시스템 설정', icon: Icons.brightness_auto_rounded),
    (mode: ThemeMode.light, label: '라이트', icon: Icons.light_mode_rounded),
    (mode: ThemeMode.dark, label: '다크', icon: Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final current = _options.firstWhere((o) => o.mode == themeMode);

    return PopupMenuButton<ThemeMode>(
      key: const Key('theme_mode_button'),
      tooltip: '테마 변경',
      initialValue: themeMode,
      icon: Icon(current.icon, color: context.colors.textPrimary),
      onSelected: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      itemBuilder: (_) => [
        for (final option in _options)
          PopupMenuItem(
            value: option.mode,
            child: Row(
              children: [
                Icon(option.icon, size: 20),
                const SizedBox(width: 12),
                Text(option.label),
              ],
            ),
          ),
      ],
    );
  }
}
