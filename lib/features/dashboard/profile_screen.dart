import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/features/authentication/presentation/login_screen.dart';
import 'package:apc_schedular/features/profile/controller/profile_controller.dart';
import 'package:apc_schedular/features/profile/model/profile_model.dart';
import 'package:apc_schedular/features/profile/presentation/reset_password.dart';
import 'package:apc_schedular/features/widget/custom_button.dart';
import 'package:apc_schedular/features/widget/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final _profileController = Get.put(ProfileController());

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => _profileController.loadProfile.value
            ? const AppPageShimmer(itemCount: 3)
            : SizedBox(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildProfileCard(
                          context,
                          _profileController.loadedProfile.value,
                        ),
                        // const Spacer(),
                        // _buildResetButton(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
          child: const Icon(Icons.person, size: 50, color: AppColors.secondary),
        ),
        const SizedBox(height: 16),
        const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildProfileCard(BuildContext context, UserProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: TextEditingController(
              text: profile.data?.user?.username ?? '',
            ),
            label: profile.data?.user?.username ?? '',

            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            label: profile.data?.user?.email ?? '',
            controller: TextEditingController(
              text: profile.data?.user?.email ?? '',
            ),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          CustomButtonWidget(
            btnText: 'Logout',
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.clear();
              Get.off(() => LoginScreen());
            },
            isLoading: false,
          ),
          SizedBox(height: 15),

          GestureDetector(
            onTap: () {
              Get.to(() => const ResetPasswordScreen());
            },
            child:
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 900.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      readOnly: true,
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.secondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.6),
        ),
      ),
    );
  }
}
