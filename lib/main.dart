import 'package:apc_schedular/features/authentication/presentation/splash_screen.dart';
import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_feedback.dart';
import 'package:apc_schedular/features/notifications/alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_lib;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Initializing app...');

  try {
    tz.initializeTimeZones();
    tz_lib.setLocalLocation(tz_lib.getLocation('Africa/Lagos'));
    print('✅ Timezone initialized: Africa/Lagos (${tz_lib.local.name})');

    final now = tz_lib.TZDateTime.now(tz_lib.local);
    print('✅ Current time in Lagos: $now');
  } catch (e) {
    print('❌ Error initializing timezone: $e');
    tz.initializeTimeZones();
    tz_lib.setLocalLocation(tz_lib.getLocation('UTC'));
    print('⚠️ Using UTC timezone as fallback');
  }

  // Initialize AlarmManager
  try {
    await AlarmManager.initialize();
    print('✅ AlarmManager initialized');

    // ⭐ REQUEST PERMISSIONS IMMEDIATELY AFTER INITIALIZATION
    await AlarmManager.requestAlarmPermissions();
    print('✅ Permission requests completed');
  } catch (e) {
    print('❌ Error initializing AlarmManager: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ApexScheduler',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: AppColors.primaryText,
          displayColor: AppColors.primaryText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          contentTextStyle: GoogleFonts.inter(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 1.6,
            ),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
