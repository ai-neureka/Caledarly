import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/widget/app_shimmer.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButtonWidget({
    super.key,
    required this.btnText,
    required this.onPressed,
    required this.isLoading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: isLoading
                ? AppColors.primary.withValues(alpha: 0.72)
                : backgroundColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isLoading ? [] : [AppColors.softShadow],
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: isLoading
                ? AppShimmer(
                    baseColor: (foregroundColor ?? AppColors.whiteColor)
                        .withValues(alpha: 0.32),
                    child: const ShimmerBox(
                      height: 18,
                      width: 92,
                      borderRadius: 5,
                      color: Colors.white24,
                    ),
                  )
                : Text(
                    btnText,
                    style: AppTextStyle().textInter(
                      size: 16,
                      weight: FontWeight.w700,
                      color: foregroundColor ?? AppColors.whiteColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
