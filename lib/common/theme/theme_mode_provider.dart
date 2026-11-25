import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/storage/secure_storage.dart';

/// 앱 테마 모드 (시스템 / 라이트 / 다크)
/// main.dart 에서 ref.watch(themeModeProvider) 로 MaterialApp.themeMode 에 연결한다.
/// 변경 : ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  /// 저장된 테마 모드 불러오기 (없으면 시스템 설정을 따른다)
  Future<void> _load() async {
    final saved = await ref.read(secureStorageProvider).read(key: THEME_MODE_KEY);
    final mode = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
    if (mode != null) state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(secureStorageProvider).write(key: THEME_MODE_KEY, value: mode.name);
  }
}
