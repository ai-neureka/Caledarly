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
    this.validator,
  });
  final controller;
  final String hintText;
  final VoidCallback onPressed;
  final bool isVisible;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppTextStyle().textInter(size: 15, weight: FontWeight.w500),
      validator:
          validator ??
          (val) {
            if (val == null || val.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
      controller: controller,
      obscureText: isVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyle().textInter(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.secondaryText,
        ),
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: GestureDetector(onTap: onPressed, child: suffixIcon),
        prefixIconColor: AppColors.secondary,
        suffixIconColor: AppColors.secondaryText,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        enabled: true,
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.6),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
