import 'dart:convert';

import 'package:apc_schedular/constants/api.dart';
import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/http_service.dart';
import 'package:apc_schedular/features/dashboard/dashboard_screen.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  //REPO
  Future createUser(username, email, password) async {
    final response = await BaseHttpClient.instance.post(
      ApiRoutes.register,
      body: {"username": username, "email": email, "password": password},
    );
    return response;
  }

  Future loginUser(email, password) async {
    final response = await BaseHttpClient().post(
      ApiRoutes.login,
      body: {"email": email, "password": password},
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

  Future createUserController(username, email, password) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      registering(true);
      var result = await createUser(username, email, password);
      registering(false);
      final token = result['data']['token'];
      await prefs.setString('token', token);
      Get.offAll(() => DashboardScreen());
    } catch (e) {
      registering(false);
      print(e);
      Get.snackbar(
        'OPPSS',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.blue,
        colorText: AppColors.whiteColor,
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
      Get.offAll(() => DashboardScreen());
    } catch (e) {
      loading(false);
      Get.snackbar(
        'OPPSS',
        e.toString(),
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  Future changePasswordController(oldPassword, newPassword) async {
    try {
      resttingPassword(true);
      var result = await changePasswordRepo(oldPassword, newPassword);
      resttingPassword(false);
      Get.snackbar(
        'SUCCESS',
        'Password changed successfully!',
        backgroundColor: AppColors.blue,
        colorText: AppColors.whiteColor,
      );
      Get.off(() => DashboardScreen());
    } catch (e) {
      resttingPassword(false);
      Get.snackbar(
        'OPPSS',
        e.toString(),
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }
}
