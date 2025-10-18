import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.onPressed,
    required this.isVisible,
    required this.prefixIcon,
    required this.suffixIcon,
  });
  final controller;
  final String hintText;
  final VoidCallback onPressed;
  final bool isVisible;
  final Widget prefixIcon;
  final Widget suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppTextStyle().textInter(
        size: 14,
        weight: FontWeight.w500,
        color: AppColors.blackColor,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      controller: controller,
      obscureText: isVisible,
      decoration: InputDecoration(
        hintStyle: AppTextStyle().textInter(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.textColor,
        ),
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: GestureDetector(onTap: onPressed, child: suffixIcon),
        border: InputBorder.none,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
        enabled: true,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
        
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
