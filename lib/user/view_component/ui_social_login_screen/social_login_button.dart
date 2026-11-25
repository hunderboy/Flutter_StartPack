import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 소셜 로그인 버튼
/// 좌측 로고 + 중앙 텍스트 구조
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String logoAssetPath;
  final Color backgroundColor;
  final Color textColor;
  final Color? logoColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.logoAssetPath,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.logoColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                logoAssetPath,
                width: 20,
                height: 20,
                colorFilter: logoColor == null
                    ? null
                    : ColorFilter.mode(logoColor!, BlendMode.srcIn),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
