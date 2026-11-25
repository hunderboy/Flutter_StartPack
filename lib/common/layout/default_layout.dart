import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_start_pack/common/const/colors.dart';

/// 공통 레이아웃
/// - title 이 있으면 AppBar 를 보여준다.
/// - 뒤로가기 버튼은 GoRouter 스택에 따라 자동으로 표시된다.
class DefaultLayout extends StatelessWidget {
  final String? title;
  final Widget body;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeAreaBottom;

  const DefaultLayout({
    super.key,
    required this.body,
    this.title,
    this.backgroundColor,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: _renderAppBar(),
      body: SafeArea(bottom: safeAreaBottom, child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  AppBar? _renderAppBar() {
    if (title == null) return null;

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColor.Grey_100,
      elevation: 0,
      scrolledUnderElevation: 0, // 스크롤 시 AppBar 색상 변경 방지
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        title!,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
  }
}
