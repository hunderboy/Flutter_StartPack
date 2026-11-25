import 'package:flutter/material.dart';

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
      backgroundColor: backgroundColor, // null 이면 테마의 scaffoldBackgroundColor 사용
      appBar: _renderAppBar(),
      body: SafeArea(bottom: safeAreaBottom, child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  AppBar? _renderAppBar() {
    if (title == null) return null;

    // 배경 / 글자색 / elevation / 상태바 스타일은 AppTheme.appBarTheme 에서 지정
    return AppBar(
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
