import 'package:apc_schedular/constants/app_colors.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar({
  required String title,
  required String message,
  Color backgroundColor = AppColors.primary,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint('$title: $message');
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(color: AppColors.whiteColor),
              ),
            ],
          ),
        ),
      );
  });
}
