import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_start_pack/common/const/colors.dart';
import 'package:flutter_start_pack/common/theme/app_colors.dart';

/// 라이트 / 다크 ThemeData
/// 공통 위젯(AppBar, Divider, BottomNavigationBar 등)의 기본 색은 여기서 지정하고,
/// 개별 위젯에서는 가능한 한 색을 직접 지정하지 않는다.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppColors.light);

  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColor.Primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColor.Primary,
      error: colors.danger,
      surface: colors.background,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0, // 스크롤 시 AppBar 색상 변경 방지
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.navSelected,
        unselectedItemColor: colors.navUnselected,
      ),
      dividerTheme: DividerThemeData(color: colors.divider, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.surfaceSubtle,
        hintStyle: TextStyle(color: colors.textTertiary),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColor.Primary),
      extensions: [colors],
    );
  }
}
