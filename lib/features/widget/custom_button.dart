import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButtonWidget({
    super.key,
    required this.btnText,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 13),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: AppColors.whiteColor),
                )
              : Text(
                  btnText,
                  style: AppTextStyle().textInter(
                    size: 16,
                    weight: FontWeight.w500,
                    color: AppColors.whiteColor,
                  ),
                ),
        ),
      ),
    );
  }
}
