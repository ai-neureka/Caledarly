import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class AlarmManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize notifications
  static Future<void> initialize() async {
    print('🔧 Initializing AlarmManager...');

    // ALWAYS recreate the channel to ensure settings are applied
    // This fixes the issue where alarms only work after restart
    await _createNotificationChannel();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    _isInitialized = true;
    print('✅ AlarmManager initialized successfully');
  }

  // Create high priority notification channel with ALARM audio stream
  static Future<void> _createNotificationChannel() async {
    // CRITICAL: Delete the old channel first to ensure new settings are applied
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel('schedule_alarm_channel');

    print('🗑️ Deleted old notification channel');

    // Wait a moment for the deletion to complete
    await Future.delayed(Duration(milliseconds: 100));

    // Create new channel with ALARM audio attributes
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'schedule_alarm_channel',
      'Schedule Alarms',
      description: 'High priority schedule alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      // Use default alarm sound or custom if you added one
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      showBadge: true,
      // CRITICAL: Use ALARM audio attributes for loudest sound
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print('✅ Notification channel created with ALARM audio stream');
  }

  // Handle notification responses
  static void _onNotificationResponse(NotificationResponse response) async {
    print("🔔 Notification response received: ${response.actionId}");
    print("📋 Payload: ${response.payload}");

    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        print("📊 Decoded data: $data");

        switch (response.actionId) {
          case 'snooze_5':
            print("🔄 Snooze 5 minutes triggered");
            await _handleSnooze(data, 5);
            break;
          case 'snooze_10':
            print("🔄 Snooze 10 minutes triggered");
            await _handleSnooze(data, 10);
            break;
          case 'dismiss':
            print("❌ Alarm dismissed by user");
            _showDismissMessage();
            break;
          case null:
          default:
            print("👆 Notification tapped: ${data['title']}");
            _openScheduleDetails(data);
            break;
        }
      } catch (e) {
        print("❌ Error handling notification response: $e");
      }
    }
  }

  // Handle background notification responses
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    print("🔔 Background notification response: ${response.actionId}");
    _onNotificationResponse(response);
  }

  // Handle snooze functionality
  static Future<void> _handleSnooze(
    Map<String, dynamic> data,
    int snoozeMinutes,
  ) async {
    try {
      print("🔄 Handling snooze for $snoozeMinutes minutes");

      final scheduleId = data['scheduleId']?.toString() ?? 'unknown';
      final title = data['title']?.toString() ?? 'Untitled';
      final reminderLabel = data['reminderLabel']?.toString() ?? 'Reminder';
      final originalNotificationId = data['notificationId'] as int?;

      final scheduleDateTimeStr = data['scheduleDateTime']?.toString();
      if (scheduleDateTimeStr == null) {
        print("❌ No schedule datetime found in payload");
        return;
      }

      final scheduleDateTime = DateTime.parse(scheduleDateTimeStr);
      final snoozeDateTime = tz.TZDateTime.now(
        tz.local,
      ).add(Duration(minutes: snoozeMinutes));

      print("⏰ Snooze time set to: $snoozeDateTime");

      // Cancel the original notification
      if (originalNotificationId != null) {
        await flutterLocalNotificationsPlugin.cancel(originalNotificationId);
        print("✅ Cancelled original notification: $originalNotificationId");
      }

      // Generate new unique ID for snooze notification
      final snoozedNotificationId =
          '${scheduleId}_snoozed_${DateTime.now().millisecondsSinceEpoch}'
              .hashCode
              .abs();

      // Convert to TZDateTime properly
      final tzScheduleDateTime = tz.TZDateTime(
        tz.local,
        scheduleDateTime.year,
        scheduleDateTime.month,
        scheduleDateTime.day,
        scheduleDateTime.hour,
        scheduleDateTime.minute,
        scheduleDateTime.second,
      );

      // Schedule new reminder after snooze
      await scheduleReminderWithAlarm(
        scheduleId,
        title,
        snoozeDateTime,
        tzScheduleDateTime,
        "Snoozed ($snoozeMinutes min) - $reminderLabel",
        snoozedNotificationId,
      );

      // Show feedback to user
      Get.snackbar(
        "⏰ Snoozed",
        "Reminder snoozed for $snoozeMinutes minutes",
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );

      print("✅ Snooze reminder scheduled successfully");
    } catch (e) {
      print("❌ Error in snooze handling: $e");
    }
  }

  static void _showDismissMessage() {
    Get.snackbar(
      "✓ Dismissed",
      "Reminder dismissed",
      backgroundColor: Colors.grey.shade700,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  static void _openScheduleDetails(Map<String, dynamic> data) {
    final scheduleId = data['scheduleId']?.toString();
    final title = data['title']?.toString() ?? 'Schedule';

    if (scheduleId != null) {
      print("📖 Opening schedule details for: $scheduleId");
      // Navigate to schedule details if needed
    }
  }

  // Request necessary permissions INCLUDING battery optimization
  static Future<bool> requestAlarmPermissions() async {
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      final alarmStatus = await Permission.scheduleExactAlarm.request();

      print("📳 Notification permission: $notificationStatus");
      print("⏰ Exact alarm permission: $alarmStatus");

      if (!notificationStatus.isGranted) {
        Get.snackbar(
          "Notification Permission Required",
          "Please grant notification permission in Settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      if (!alarmStatus.isGranted) {
        Get.snackbar(
          "Alarm Permission Required",
          "Please grant exact alarm permission in Settings for reminders to work",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
      }

      // Check battery optimization - CRITICAL for alarms to work
      await _checkBatteryOptimization();

      return notificationStatus.isGranted && alarmStatus.isGranted;
    }
    return true;
  }

  // Force re-initialize - call this before scheduling if having issues
  static Future<void> forceReinitialize() async {
    print('🔄 Force re-initializing AlarmManager...');
    _isInitialized = false;
    await initialize();
  }

  // Check and request battery optimization exemption
  static Future<void> _checkBatteryOptimization() async {
    try {
      final batteryOptimizationStatus =
          await Permission.ignoreBatteryOptimizations.status;

      if (!batteryOptimizationStatus.isGranted) {
        print("⚠️ Battery optimization is enabled - this may prevent alarms!");

        // Get.snackbar(
        //   "Battery Optimization Detected",
        //   "Tap here to disable battery optimization for reliable alarms",
        //   backgroundColor: Colors.orange,
        //   colorText: Colors.white,
        //   duration: Duration(seconds: 6),
        //   snackPosition: SnackPosition.TOP,
        //   onTap: (_) async {
        //     await Permission.ignoreBatteryOptimizations.request();
        //   },
        // );
      } else {
        print("✅ Battery optimization is disabled - alarms will work reliably");
      }
    } catch (e) {
      print("❌ Error checking battery optimization: $e");
    }
  }

  // Schedule reminder with alarm - FIXED VERSION
  static Future<void> scheduleReminderWithAlarm(
    String scheduleId,
    String title,
    tz.TZDateTime reminderDateTime,
    tz.TZDateTime scheduleDateTime,
    String reminderLabel,
    dynamic reminderIndex,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    print("🔔 Scheduling reminder for: $title");
    print("⏰ Reminder time: $reminderDateTime");
    print("📅 Current time: $now");
    print(
      "⏱️ Time until alarm: ${reminderDateTime.difference(now).inMinutes} minutes",
    );

    // Generate unique notification ID
    int notificationId;
    if (reminderIndex is int) {
      notificationId = '${scheduleId}_$reminderIndex'.hashCode.abs();
    } else {
      notificationId = reminderIndex as int;
    }

    print("🆔 Notification ID: $notificationId");

    // Check if reminder time is in the future
    if (reminderDateTime.isBefore(now) ||
        reminderDateTime.isAtSameMomentAs(now)) {
      print("❌ Reminder time is in the past or now! Cannot schedule.");
      return;
    }

    // Request permissions before scheduling
    final hasPermissions = await requestAlarmPermissions();
    if (!hasPermissions) {
      print("❌ Required permissions not granted");
      return;
    }

    // Create action buttons
    const List<AndroidNotificationAction> actions = [
      AndroidNotificationAction(
        'snooze_5',
        'Snooze 5min',
        showsUserInterface: false,
        cancelNotification: false,
      ),
      AndroidNotificationAction(
        'snooze_10',
        'Snooze 10min',
        showsUserInterface: false,
        cancelNotification: false,
      ),
      AndroidNotificationAction('dismiss', 'Dismiss', cancelNotification: true),
    ];

    try {
      // Cancel any existing notification with the same ID
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      print("🗑️ Cancelled any existing notification with ID: $notificationId");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        "⏰ $title",
        "$reminderLabel - Starts at ${DateFormat('h:mm a').format(scheduleDateTime)}",
        reminderDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'schedule_alarm_channel',
            'Schedule Alarms',
            channelDescription: 'High priority schedule alarm notifications',
            importance: Importance.max,
            priority: Priority.max,

            // CRITICAL FIXES for alarm to ring
            fullScreenIntent: true,
            ongoing: true, // Keep notification visible
            autoCancel: false,
            category: AndroidNotificationCategory.alarm,

            // CRITICAL: Use alarm sound with ALARM audio stream
            playSound: true,
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            audioAttributesUsage: AudioAttributesUsage.alarm,

            // Vibration - stronger pattern
            enableVibration: true,
            vibrationPattern: Int64List.fromList([
              0,
              1000,
              500,
              1000,
              500,
              1000,
              500,
              1000,
            ]),

            // Lights
            enableLights: true,
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            ledOnMs: 1000,
            ledOffMs: 500,

            // Visibility - CRITICAL
            visibility: NotificationVisibility.public,
            showWhen: true,
            when: reminderDateTime.millisecondsSinceEpoch,

            // Big text style
            styleInformation: BigTextStyleInformation(
              "$reminderLabel for $title\n\nStarts at ${DateFormat('h:mm a').format(scheduleDateTime)}\n\nTap to view details or use buttons below.",
              contentTitle: "⏰ $title",
              summaryText: "ApexScheduler Reminder",
              htmlFormatContent: false,
              htmlFormatContentTitle: false,
            ),

            // Actions
            actions: actions,

            // Icon and color
            icon: '@mipmap/launcher_icon',
            color: const Color(0xFF2196F3),

            // Longer timeout - 10 minutes
            timeoutAfter: 600000,
            ticker: 'Reminder: $title',

            // CRITICAL: Channel ID must match
            channelShowBadge: true,
            onlyAlertOnce: false,
          ),
        ),
        payload: jsonEncode({
          'scheduleId': scheduleId,
          'title': title,
          'reminderLabel': reminderLabel,
          'scheduleDateTime': scheduleDateTime.toIso8601String(),
          'type': 'reminder',
          'notificationId': notificationId,
        }),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("✅ Reminder scheduled successfully!");
      await _verifyNotificationScheduled(notificationId);
    } catch (e) {
      print("❌ Error scheduling reminder: $e");
      print("Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  // Verify that notification was actually scheduled
  static Future<void> _verifyNotificationScheduled(int notificationId) async {
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    print("📋 Total pending notifications: ${pendingNotifications.length}");

    final isScheduled = pendingNotifications.any((n) => n.id == notificationId);
    print("✓ Notification verified in pending list: $isScheduled");

    if (!isScheduled) {
      print("⚠️ WARNING: Notification was not properly scheduled!");
      print(
        "⚠️ This might be due to battery optimization or system restrictions",
      );
    } else {
      // Find and print details
      final notification = pendingNotifications.firstWhere(
        (n) => n.id == notificationId,
      );
      print("📝 Scheduled notification details:");
      print("   Title: ${notification.title}");
      print("   Body: ${notification.body}");
    }
  }

  // Cancel all reminders for a specific schedule
  static Future<void> cancelRemindersForSchedule(String scheduleId) async {
    final pendingNotifications = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    int canceledCount = 0;
    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['scheduleId'] == scheduleId) {
            await flutterLocalNotificationsPlugin.cancel(notification.id);
            canceledCount++;
            print("✅ Cancelled notification: ${notification.id}");
          }
        } catch (e) {
          print("❌ Error checking notification payload: $e");
        }
      }
    }

    if (canceledCount > 0) {
      print(
        "📝 Cancelled $canceledCount reminder(s) for schedule: $scheduleId",
      );
    }
  }

  // Get all pending notifications for debugging
  static Future<void> debugPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    print("📋 === PENDING NOTIFICATIONS ===");
    print("Total: ${pendingNotifications.length}");

    for (final notification in pendingNotifications) {
      print("---");
      print("ID: ${notification.id}");
      print("Title: ${notification.title}");
      print("Body: ${notification.body}");
      print("Payload: ${notification.payload}");
    }
    print("================================");
  }

  // Test notification (schedules in 10 seconds)
  static Future<void> testNotification() async {
    await initialize();

    final testTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 10));

    await scheduleReminderWithAlarm(
      'test_id',
      'Test Alarm',
      testTime,
      testTime.add(const Duration(minutes: 30)),
      'Test reminder in 10 seconds',
      999999,
    );

    print("🧪 Test notification scheduled for 10 seconds from now");

    Get.snackbar(
      "Test Alarm Scheduled",
      "Alarm will ring in 10 seconds",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Cancel all pending notifications
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("🗑️ All notifications cancelled");
  }
}
