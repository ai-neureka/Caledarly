import 'package:apc_schedular/features/authentication/presentation/splash_screen.dart';
import 'package:apc_schedular/features/notifications/alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';



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

    // Test the timezone to confirm it's working
    final now = tz_lib.TZDateTime.now(tz_lib.local);
    print('✅ Current time in Lagos: $now');
  } catch (e) {
    print('❌ Error initializing timezone: $e');
    // Fallback to UTC if there's an issue
    tz.initializeTimeZones();
    tz_lib.setLocalLocation(tz_lib.getLocation('UTC'));
    print('⚠️ Using UTC timezone as fallback');
  }

  // Initialize AlarmManager for notifications
  try {
    await AlarmManager.initialize();
    print('✅ AlarmManager initialized');
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
