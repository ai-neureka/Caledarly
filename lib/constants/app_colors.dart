import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF16324F);
  static const secondary = Color(0xFF2A7F7F);
  static const accent = Color(0xFFD9A441);
  static const background = Color(0xFFF7F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF17202A);
  static const secondaryText = Color(0xFF667085);
  static const success = Color(0xFF2E8B57);
  static const error = Color(0xFFD64545);
  static const border = Color(0xFFE4E7EC);
  static const mutedSurface = Color(0xFFF2F5F7);

  static const grey = border;
  static const whiteColor = surface;
  static const blackColor = primaryText;
  static const redColor = error;
  static const blue = primary;
  static const textColor = secondaryText;

  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFF16324F).withValues(alpha: 0.08),
    blurRadius: 18,
    offset: const Offset(0, 8),
  );
}
