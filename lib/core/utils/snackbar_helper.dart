import 'package:flutter/material.dart';
import 'package:sparkd/core/utils/app_colors.dart';

enum SnackBarType { success, error, info }

void showSnackbar(
  BuildContext context,
  String message,
  SnackBarType snackBarType,
) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final Color backgroundColor = switch (snackBarType) {
    SnackBarType.success => AppColors.primary100,
    SnackBarType.error => AppColors.error,
    SnackBarType.info => AppColors.accent300,
  };
  final Color textColor = switch (snackBarType) {
    SnackBarType.success => AppColors.black,
    SnackBarType.error => AppColors.white,
    SnackBarType.info => AppColors.white,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
