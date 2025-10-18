import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  State<ModernOnboardingScreen> createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      ),
    );
    _animationControllers[0].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     Colors.white,
              //     const Color(0xFF5F57FF).withOpacity(0.9),
              //   ],
              // ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => _navigateToHome(),
                      child: Text(
                        _currentPage == 2 ? "" : "Skip",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _animationControllers[index].forward();
                    },
                    children: [
                      _buildModernPage(
                        0,
                        "Plan Your Day/week",
                        "Create schedules. Organize tasks by priority and never miss what matters.",
                        Icons.event_note_rounded,
                      ),
                      _buildModernPage(
                        1,
                        "Stay Productive",
                        "Track your progresss. See what you've accomplished at a glance.",
                        Icons.insights_rounded,
                      ),
                      _buildModernPage(
                        2,
                        "Achieve More",
                        "Let's get started on your journey to productivity and organization!",
                        Icons.emoji_events_rounded,
                      ),
                    ],
                  ),
                ),

                // Page Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF5F57FF)
                              : AppColors.blue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == 2) {
                          _navigateToHome();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F57FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF5F57FF).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2 ? "Get Started" : "Continue",
                            style: const TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPage(
    int index,
    String title,
    String description,
    IconData icon,
  ) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        final value = _animationControllers[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF5F57FF).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5F57FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5F57FF).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 100, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle().textInter(
                      size: 32,
                      weight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyle().textInter(
                      size: 16,
                      weight: FontWeight.w500,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAll(() => const LoginScreen());
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
