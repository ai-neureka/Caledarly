import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  textInter({required double size, weight, double? height, Color? color}) =>
      GoogleFonts.inter(
        color: color ?? const Color(0xFF17202A),
        letterSpacing: 0.0,
        height: height ?? 1.35,
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size,
      );
}
