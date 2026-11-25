// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 컬러 상수
/// 라이트/다크모드 지원이 필요해지면 ThemeData 로 이전하고,
/// 자주 쓰는 색은 이 클래스에 상수로 유지한다.
class AppColor {
  AppColor._(); // private constructor : 인스턴스화 방지

  /// Primary
  static const Primary = Color(0xFF146EFF);
  static const Primary_Red = Color(0xFFFF144D);

  /// Grey Scale
  static const Grey_100 = Color(0xFF13141A);
  static const Grey_80 = Color(0xFF515253);
  static const Grey_70 = Color(0xFF79797C);
  static const Grey_60 = Color(0xFF909091);
  static const Grey_40 = Color(0xFFACACAD);
  static const Grey_30 = Color(0xFFC2C3C4);
  static const Grey_20 = Color(0xFFDCDCDE);
  static const Grey_10 = Color(0xFFEEEEF0);

  /// Background
  static const Background_Gray = Color(0xFFF5F5F5);

  /// Social Login
  static const Kakao_Yellow = Color(0xFFFEE500);
  static const Naver_Green = Color(0xFF03C75A);
  static const Apple_Black = Color(0xFF000000);
  static const Google_White = Color(0xFFFFFFFF);
}
