import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/authentication/contoller/auth_controller.dart';
import 'package:apc_schedular/features/widget/custom_button.dart';
import 'package:apc_schedular/features/widget/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

TextEditingController currentPasswordController = TextEditingController();
TextEditingController newPasswordController = TextEditingController();
final _authController = Get.put(AuthController());

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: AppTextStyle().textInter(size: 20, weight: FontWeight.w600),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => CustomTextField(
                hintText: 'current Password',
                controller: currentPasswordController,

                onPressed: () {
                  _authController.oldPasswordVisible.value =
                      !_authController.oldPasswordVisible.value;
                },
                isVisible: _authController.oldPasswordVisible.value,
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(
                  !_authController.oldPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomTextField(
                hintText: 'New Password',
                controller: newPasswordController,
                onPressed: () {
                  _authController.newPasswordVisible.value =
                      !_authController.newPasswordVisible.value;
                },
                isVisible: _authController.newPasswordVisible.value,
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(
                  !_authController.newPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButtonWidget(
                btnText: 'Change Password',
                onPressed: () {
                  _authController.changePasswordController(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                },

                isLoading: _authController.resttingPassword.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
