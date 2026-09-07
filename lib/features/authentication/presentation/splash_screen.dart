import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/features/widget/app_shimmer.dart';
import 'package:apc_schedular/features/authentication/presentation/onboarding_screen.dart';
import 'package:apc_schedular/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Wait a bit for splash animation / logo display
    await Future.delayed(const Duration(seconds: 2));

    if (!hasSeenOnboarding) {
      Get.offAll(() => const ModernOnboardingScreen());
    } else if (token != null && token.isNotEmpty) {
      Get.offAll(() => const DashboardScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 136,
              width: 136,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppColors.softShadow],
              ),
              child: Image.asset('assets/images/logo.jpeg'),
            ),
            const SizedBox(height: 18),
            const AppShimmer(
              child: ShimmerBox(height: 8, width: 86, borderRadius: 4),
            ),
          ],
        ),
      ),
    );
  }
}
