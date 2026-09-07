import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/authentication/contoller/auth_controller.dart';
import 'package:apc_schedular/features/authentication/presentation/login_screen.dart';
import 'package:apc_schedular/features/widget/custom_button.dart';
import 'package:apc_schedular/features/widget/custom_textfield.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistersScreen extends StatefulWidget {
  const RegistersScreen({super.key});

  @override
  State<RegistersScreen> createState() => _RegistersScreenState();
}

final _registerKey = GlobalKey<FormState>();
final _authController = Get.put(AuthController());
TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _usernameController = TextEditingController();

class _RegistersScreenState extends State<RegistersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _registerKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Join APC Scheduler',
                      style: AppTextStyle().textInter(
                        size: 20,
                        weight: FontWeight.w600,
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
                        'Create your account',
                        style: AppTextStyle().textInter(
                          size: 27,
                          color: AppColors.blackColor,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Set up access for your NGO scheduling workspace.',
                        style: AppTextStyle().textInter(
                          size: 15,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'User name',
                        style: AppTextStyle().textInter(
                          size: 14,
                          weight: FontWeight.w400,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      CustomTextField(
                        prefixIcon: Icon(EvaIcons.person),
                        suffixIcon: SizedBox.shrink(),
                        hintText: 'Enter username',
                        isVisible: false,

                        onPressed: () {},
                        controller: _usernameController,
                      ),
                      SizedBox(height: 16),
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
                          suffixIcon: Icon(Icons.visibility),
                          hintText: 'Enter Password',
                          isVisible: _authController.isVisible.value,

                          onPressed: () {
                            _authController.isVisible.value =
                                !_authController.isVisible.value;
                          },
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (!AuthController.isValidPassword(value)) {
                              return 'Use 7+ characters with letters and numbers';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use at least 7 characters with letters and numbers.',
                        style: AppTextStyle().textInter(
                          size: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),

                      SizedBox(height: 32),
                      Obx(
                        () => CustomButtonWidget(
                          isLoading: _authController.registering.value,
                          btnText: 'Sign up',
                          onPressed: () {
                            if (_registerKey.currentState!.validate()) {
                              _authController.createUserController(
                                _usernameController.text,
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
                            "Already have an account?",
                            style: AppTextStyle().textInter(
                              size: 14,
                              weight: FontWeight.w400,
                              color: AppColors.textColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => LoginScreen());
                            },
                            child: Text(
                              'Sign In',
                              style: AppTextStyle().textInter(
                                size: 14,
                                weight: FontWeight.w600,
                                color: AppColors.primary,
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
      ),
    );
  }
}
