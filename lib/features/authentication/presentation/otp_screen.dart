import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';

import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 160,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Please enter the otp sent to the email: ',
              style: AppTextStyle().textInter(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
            Text(
              '${widget.email}',
              style: AppTextStyle().textInter(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
