import 'package:apc_schedular/constants/app_colors.dart';
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
      backgroundColor: AppColors.blue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              width: 130,
              child: Image.asset('assets/images/apc1.png'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
