import 'package:flutter/material.dart';

/// 화면 위에 로딩 인디케이터를 덮어씌우는 공통 위젯
/// isLoading 이 true 인 동안 터치를 막는다.
class LoaderOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoaderOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
