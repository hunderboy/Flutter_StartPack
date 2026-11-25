// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// 컬러 팔레트 (원색 정의, 테마와 무관)
/// 위젯에서는 이 값을 직접 쓰지 말고 common/theme/app_colors.dart 의
/// context.colors.xxx (의미 기반 컬러)를 사용한다.
/// 예외 : 브랜드 가이드상 테마와 상관없이 고정이어야 하는 색 (Primary, 소셜 로그인 등)
class AppColor {
  AppColor._(); // private constructor : 인스턴스화 방지

  /// Primary
  static const Primary = Color(0xFF146EFF);
  static const Primary_Red = Color(0xFFFF144D);

  /// Dark Theme
  static const Dark_Background = Color(0xFF121317);
  static const Dark_Surface = Color(0xFF1E1F24);
  static const Dark_Divider = Color(0xFF2A2B30);

  /// Background
  static const Background_Gray = Color(0xFFF5F5F5);

  /// Grey Scale
  static const Grey_100 = Color(0xFF13141A);
  static const Grey_80 = Color(0xFF515253);
  static const Grey_70 = Color(0xFF79797C);
  static const Grey_60 = Color(0xFF909091);
  static const Grey_40 = Color(0xFFACACAD);
  static const Grey_30 = Color(0xFFC2C3C4);
  static const Grey_20 = Color(0xFFDCDCDE);
  static const Grey_10 = Color(0xFFEEEEF0);

  /// Social Login
  static const Kakao_Yellow = Color(0xFFFEE500);
  static const Naver_Green = Color(0xFF03C75A);
  static const Apple_Black = Color(0xFF000000);
  static const Google_White = Color(0xFFFFFFFF);
}
