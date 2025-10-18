import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/authentication/contoller/auth_controller.dart';
import 'package:apc_schedular/features/authentication/presentation/registers_screen.dart';
import 'package:apc_schedular/features/widget/custom_button.dart';
import 'package:apc_schedular/features/widget/custom_textfield.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final _loginKey = GlobalKey<FormState>();
final _authController = Get.put(AuthController());
TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Form(
          key: _loginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Sign in with Apc schedular',
                    style: AppTextStyle().textInter(
                      size: 20,
                      weight: FontWeight.w800,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(17.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: AppTextStyle().textInter(
                        size: 27,
                        color: AppColors.blackColor,
                        weight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 60),
                    Text(
                      'Email',
                      style: AppTextStyle().textInter(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    CustomTextField(
                      prefixIcon: Icon(EvaIcons.email),
                      suffixIcon: SizedBox.shrink(),
                      hintText: 'Enter Email',
                      isVisible: false,

                      onPressed: () {},
                      controller: _emailController,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Password',
                      style: AppTextStyle().textInter(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Obx(
                      () => CustomTextField(
                        prefixIcon: Icon(EvaIcons.lock),
                        suffixIcon: !_authController.isVisible.value
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                        hintText: 'Enter Password',
                        isVisible: !_authController.isVisible.value,

                        onPressed: () {
                          _authController.isVisible.value =
                              !_authController.isVisible.value;
                        },
                        controller: _passwordController,
                      ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyle().textInter(
                          size: 12,
                          color: AppColors.blackColor,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Obx(
                      () => CustomButtonWidget(
                        btnText: 'Login',
                        isLoading: _authController.loading.value,
                        onPressed: () {
                          if (_loginKey.currentState!.validate()) {
                            _authController.loginUserController(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyle().textInter(
                            size: 14,
                            weight: FontWeight.w400,
                            color: AppColors.blackColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => RegistersScreen());
                          },
                          child: Text(
                            'Sign Up',
                            style: AppTextStyle().textInter(
                              size: 14,
                              weight: FontWeight.w500,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
