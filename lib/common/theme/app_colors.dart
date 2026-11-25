import 'package:flutter/material.dart';

import 'package:flutter_start_pack/common/const/colors.dart';

/// 의미 기반(semantic) 컬러
/// - 위젯은 AppColor(팔레트)를 직접 쓰지 않고 context.colors.xxx 로 접근한다.
/// - 라이트/다크 테마별로 같은 이름이 다른 팔레트 값을 가리킨다.
/// - 새 색이 필요하면 필드 추가 → light / dark / copyWith / lerp 에 모두 반영한다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.iconSubtle,
    required this.divider,
    required this.surfaceSubtle,
    required this.navSelected,
    required this.navUnselected,
    required this.danger,
    required this.snackBarInfo,
  });

  /// 화면 기본 배경 (Scaffold / AppBar / BottomNavigationBar)
  final Color background;

  /// 본문 / 제목 텍스트
  final Color textPrimary;

  /// 보조 설명 텍스트
  final Color textSecondary;

  /// 플레이스홀더 / 안내 텍스트
  final Color textTertiary;

  /// 비활성 / 장식용 아이콘
  final Color iconSubtle;

  /// 구분선 / 얇은 테두리
  final Color divider;

  /// 입력창 / 아바타 등 배경보다 한 단계 떠 있는 영역
  final Color surfaceSubtle;

  /// BottomNavigationBar 선택 / 미선택
  final Color navSelected;
  final Color navUnselected;

  /// 로그아웃 / 에러 등 위험 동작
  final Color danger;

  /// info 타입 SnackBar 배경
  final Color snackBarInfo;

  static const light = AppColors(
    background: Colors.white,
    textPrimary: AppColor.Grey_100,
    textSecondary: AppColor.Grey_70,
    textTertiary: AppColor.Grey_60,
    iconSubtle: AppColor.Grey_40,
    divider: AppColor.Grey_10,
    surfaceSubtle: AppColor.Background_Gray,
    navSelected: AppColor.Grey_100,
    navUnselected: AppColor.Grey_40,
    danger: AppColor.Primary_Red,
    snackBarInfo: AppColor.Grey_100,
  );

  static const dark = AppColors(
    background: AppColor.Dark_Background,
    textPrimary: AppColor.Grey_10,
    textSecondary: AppColor.Grey_40,
    textTertiary: AppColor.Grey_60,
    iconSubtle: AppColor.Grey_70,
    divider: AppColor.Dark_Divider,
    surfaceSubtle: AppColor.Dark_Surface,
    navSelected: AppColor.Grey_10,
    navUnselected: AppColor.Grey_70,
    danger: AppColor.Primary_Red,
    snackBarInfo: AppColor.Grey_80,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? iconSubtle,
    Color? divider,
    Color? surfaceSubtle,
    Color? navSelected,
    Color? navUnselected,
    Color? danger,
    Color? snackBarInfo,
  }) {
    return AppColors(
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      iconSubtle: iconSubtle ?? this.iconSubtle,
      divider: divider ?? this.divider,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      danger: danger ?? this.danger,
      snackBarInfo: snackBarInfo ?? this.snackBarInfo,
    );
  }

  /// 테마 전환 시 색이 부드럽게 바뀌도록 보간
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      iconSubtle: Color.lerp(iconSubtle, other.iconSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      snackBarInfo: Color.lerp(snackBarInfo, other.snackBarInfo, t)!,
    );
  }
}

/// context.colors.textPrimary 형태로 접근
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
