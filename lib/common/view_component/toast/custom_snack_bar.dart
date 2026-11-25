import 'package:flutter/material.dart';

import 'package:flutter_start_pack/common/const/colors.dart';

enum SnackBarType { positive, negative, info }

/// 공통 SnackBar
/// showCustomSnackBar(context, '메세지', SnackBarType.positive);
void showCustomSnackBar(
  BuildContext context,
  String message, [
  SnackBarType type = SnackBarType.info,
]) {
  final Color backgroundColor = switch (type) {
    SnackBarType.positive => AppColor.Primary,
    SnackBarType.negative => AppColor.Primary_Red,
    SnackBarType.info => AppColor.Grey_100,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}
