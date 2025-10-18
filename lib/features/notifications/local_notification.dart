import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  print("🔧 Initializing notifications...");

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Lagos'));

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("📱 Notification tapped: ${response.actionId}");
      _handleNotificationTap(response);
    },
  );

  print("✅ Notifications initialized: $initialized");

  // Create notification channels
  await _createNotificationChannels();

  // Test notification permissions
  await _checkAndRequestPermissions();
}

Future<void> _checkAndRequestPermissions() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation != null) {
    final bool? granted = await androidImplementation
        .requestNotificationsPermission();
    print("📳 Notification permission granted: $granted");

    final bool? exactAlarmGranted = await androidImplementation
        .requestExactAlarmsPermission();
    print("⏰ Exact alarm permission granted: $exactAlarmGranted");
  }
}

Future<void> _createNotificationChannels() async {
  print("📢 Creating notification channels...");

  // Create a high-priority alarm channel that uses default alarm sound
  const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
    'schedule_alarm_channel',
    'Schedule Alarms',
    description: 'High priority schedule alarm notifications',
    importance: Importance.max,
    playSound: true,
    // Use default alarm sound instead of custom
    sound: RawResourceAndroidNotificationSound(
      'alarm',
    ), // This will use the default notification sound
    enableVibration: true,
    enableLights: true,
    ledColor: Color(0xFF0000FF),
    showBadge: true,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(alarmChannel);
    print("✅ Notification channel created");
  }
}

// Main function to schedule reminders with alarm
Future<void> scheduleReminderWithAlarm(
  String scheduleId,
  String title,
  tz.TZDateTime reminderDateTime,
  tz.TZDateTime scheduleDateTime,
  String reminderLabel,
  int reminderIndex,
) async {
  print("🔔 Scheduling reminder for: $title");
  print("⏰ Reminder time: $reminderDateTime");
  print("📅 Current time: ${tz.TZDateTime.now(tz.local)}");

  final int notificationId = '${scheduleId}_$reminderIndex'.hashCode.abs();
  print("🆔 Notification ID: $notificationId");

  // Check if reminder time is in the future
  final now = tz.TZDateTime.now(tz.local);
  if (reminderDateTime.isBefore(now)) {
    print("❌ Reminder time is in the past! Cannot schedule.");
    return;
  }

  // Create action buttons for the notification
  const List<AndroidNotificationAction> actions = [
    AndroidNotificationAction(
      'snooze_5',
      'Snooze 5 min',
      showsUserInterface: true,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      'snooze_10',
      'Snooze 10 min',
      showsUserInterface: true,
      cancelNotification: true,
    ),
    AndroidNotificationAction('dismiss', 'Dismiss', cancelNotification: true),
  ];

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "⏰ $title",
      "$reminderLabel - Meeting starts at ${DateFormat('h:mm a').format(scheduleDateTime)}",
      reminderDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_alarm_channel',
          'Schedule Alarms',
          channelDescription: 'High priority schedule alarm notifications',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Schedule Reminder',

          // Alarm-specific settings
          fullScreenIntent: true,
          ongoing: false, // Changed from true to allow dismissal
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,

          // Sound and vibration
          playSound: true,
          sound: null, // Use default notification sound
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),

          // Visual settings
          enableLights: true,
          ledColor: const Color(0xFF0000FF),
          ledOnMs: 1000,
          ledOffMs: 500,

          // Additional settings for visibility
          visibility: NotificationVisibility.public,
          showWhen: true,
          when: reminderDateTime.millisecondsSinceEpoch,
          usesChronometer: false,
          chronometerCountDown: false,

          // Style for expanded notification
          styleInformation: BigTextStyleInformation(
            "$reminderLabel for $title\n\nMeeting starts at ${DateFormat('h:mm a').format(scheduleDateTime)}\nTap to view details or use action buttons below.",
            contentTitle: "⏰ Schedule Reminder: $title",
            summaryText: "ApexScheduler",
          ),

          // Actions
          actions: actions,

          // Icon and color
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF2196F3),
        ),
      ),
      payload: jsonEncode({
        'scheduleId': scheduleId,
        'title': title,
        'reminderLabel': reminderLabel,
        'scheduleDateTime': scheduleDateTime.toIso8601String(),
        'type': 'reminder',
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Reminder scheduled successfully!");

    // Verify the notification was scheduled
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print("📋 Total pending notifications: ${pendingNotifications.length}");

    // Check if our notification is in the list
    final isScheduled = pendingNotifications.any((n) => n.id == notificationId);
    print("✓ Notification verified: $isScheduled");
  } catch (e) {
    print("❌ Error scheduling reminder: $e");
    rethrow;
  }
}

// Test function to verify alarms are working
Future<void> scheduleTestAlarm() async {
  print("🔔 Scheduling test alarm...");

  // Schedule an alarm 10 seconds from now
  final now = tz.TZDateTime.now(tz.local);
  final scheduledDate = now.add(const Duration(seconds: 10));

  print("⏰ Current time: $now");
  print("📅 Scheduled time: $scheduledDate");

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      "🚨 TEST ALARM",
      "This is a test alarm - tap to dismiss or snooze",
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_alarm_channel',
          'Schedule Alarms',
          channelDescription: 'Test alarm notification',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          ongoing: false,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          sound: null, // Use default sound
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          enableLights: true,
          visibility: NotificationVisibility.public,
          actions: const [AndroidNotificationAction('dismiss', 'Dismiss')],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("✅ Test alarm scheduled! Wait 10 seconds...");

    // Show immediate feedback
    Get.snackbar(
      "Test Alarm Scheduled",
      "Alarm will ring in 10 seconds",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  } catch (e) {
    print("❌ Error scheduling test alarm: $e");
    Get.snackbar(
      "Error",
      "Failed to schedule test alarm: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

void _handleNotificationTap(NotificationResponse response) {
  print("📱 Handling notification tap: ${response.actionId}");
  print("📦 Payload: ${response.payload}");

  if (response.actionId != null) {
    final payload = response.payload != null
        ? jsonDecode(response.payload!)
        : <String, dynamic>{};

    switch (response.actionId) {
      case 'snooze_5':
        print("😴 Snoozing for 5 minutes");
        _snoozeReminder(payload, 5);
        break;
      case 'snooze_10':
        print("😴 Snoozing for 10 minutes");
        _snoozeReminder(payload, 10);
        break;
      case 'dismiss':
        print("❌ Dismissing reminder");
        if (response.id != null) {
          _dismissReminder(response.id!);
        }
        break;
    }
  } else {
    print("📖 Opening schedule details");
    _openScheduleDetails(response.payload);
  }
}

Future<void> _snoozeReminder(Map<String, dynamic> payload, int minutes) async {
  print("😴 Snoozing reminder for $minutes minutes");

  if (payload.isEmpty) {
    print("⚠️ No payload data for snooze");
    return;
  }

  final scheduleId = payload['scheduleId'] ?? 'unknown';
  final title = payload['title'] ?? 'Reminder';
  final reminderLabel = payload['reminderLabel'] ?? '';

  // Schedule a new reminder after snooze duration
  final snoozeDateTime = tz.TZDateTime.now(
    tz.local,
  ).add(Duration(minutes: minutes));

  print("⏰ Snooze scheduled for: $snoozeDateTime");

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      '${scheduleId}_snooze_${DateTime.now().millisecondsSinceEpoch}'.hashCode
          .abs(),
      "⏰ Snoozed: $title",
      "Reminder snoozed for $minutes minutes - $reminderLabel",
      snoozeDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_alarm_channel',
          'Schedule Alarms',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          ongoing: false,
          autoCancel: false,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    Get.snackbar(
      "Snoozed",
      "Reminder snoozed for $minutes minutes",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  } catch (e) {
    print("❌ Error snoozing reminder: $e");
  }
}

Future<void> _dismissReminder(int notificationId) async {
  await flutterLocalNotificationsPlugin.cancel(notificationId);
  print("✅ Reminder dismissed");
}

void _openScheduleDetails(String? payload) {
  if (payload != null) {
    try {
      final data = jsonDecode(payload);
      print("📖 Opening schedule: ${data['scheduleId']}");
      // Navigate to schedule details page here
    } catch (e) {
      print("⚠️ Error parsing payload: $e");
    }
  }
}

// Debug function to check pending notifications
Future<void> debugPendingNotifications() async {
  final List<PendingNotificationRequest> pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print("📋 === PENDING NOTIFICATIONS ===");
  print("Total: ${pendingNotifications.length}");

  for (final notification in pendingNotifications) {
    print("ID: ${notification.id}");
    print("Title: ${notification.title}");
    print("Body: ${notification.body}");
    print("Payload: ${notification.payload}");
    print("---");
  }
}
