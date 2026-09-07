import 'package:apc_schedular/constants/api.dart';
import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_feedback.dart';
import 'package:apc_schedular/constants/http_service.dart';
import 'package:apc_schedular/features/dashboard/dashboard_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static bool isValidPassword(String password) {
    return password.length > 6 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  //REPO
  Future createUser(username, email, password) async {
    final response = await BaseHttpClient.instance.post(
      ApiRoutes.register,
      body: {"username": username, "email": email, "password": password},
      includeAuth: false,
    );
    return response;
  }

  Future loginUser(email, password) async {
    final response = await BaseHttpClient().post(
      ApiRoutes.login,
      body: {"email": email, "password": password},
      includeAuth: false,
    );
    return response;
  }

  Future changePasswordRepo(oldPassword, newPassword) async {
    final response = await BaseHttpClient().put(
      ApiRoutes.changePassword,
      body: {"currentPassword": oldPassword, "newPassword": newPassword},
    );
    print(response);
    return response;
  }
  //CONTROLLERS

  RxBool registering = RxBool(false);
  RxBool loading = RxBool(false);
  RxBool isVisible = RxBool(false);
  RxBool oldPasswordVisible = RxBool(false);
  RxBool newPasswordVisible = RxBool(false);
  RxBool resttingPassword = RxBool(false);

  String _authErrorMessage(Object error) {
    if (error is ApiException) {
      final data = error.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }

  void _showAuthSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    showAppSnackBar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
    );
  }

  Future createUserController(username, email, password) async {
    if (!isValidPassword(password.toString())) {
      _showAuthSnackbar(
        title: 'Invalid password',
        message: 'Use at least 7 characters with both letters and numbers.',
        backgroundColor: AppColors.error,
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      registering(true);
      var result = await createUser(username, email, password);
      registering(false);
      final token = result['data']['token'];
      await prefs.setString('token', token);
      Get.offAll(() => const DashboardScreen());
    } catch (e) {
      registering(false);
      print(e);
      _showAuthSnackbar(
        title: 'Sign up failed',
        message: _authErrorMessage(e),
        backgroundColor: AppColors.error,
      );
    }
  }

  Future loginUserController(email, password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      loading(true);
      var result = await loginUser(email, password);
      loading(false);
      final token = result['data']['token'];
      await prefs.setString('token', token);
      Get.offAll(() => const DashboardScreen());
    } catch (e) {
      loading(false);
      _showAuthSnackbar(
        title: 'Login failed',
        message: _authErrorMessage(e),
        backgroundColor: AppColors.redColor,
      );
    }
  }

  Future changePasswordController(oldPassword, newPassword) async {
    try {
      resttingPassword(true);
      await changePasswordRepo(oldPassword, newPassword);
      resttingPassword(false);
      _showAuthSnackbar(
        title: 'Success',
        message: 'Password changed successfully!',
        backgroundColor: AppColors.blue,
      );
      Get.off(() => const DashboardScreen());
    } catch (e) {
      resttingPassword(false);
      _showAuthSnackbar(
        title: 'Password reset failed',
        message: _authErrorMessage(e),
        backgroundColor: AppColors.redColor,
      );
    }
  }
}
