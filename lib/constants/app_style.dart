import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  textInter({required double size, weight, double? height, Color? color}) =>
      GoogleFonts.inter(
        color: color ?? Color(0xFF3C3C43),
        letterSpacing: 0.0,
        height: height,
        
        fontWeight: weight,
        fontSize: size,
      );
}
