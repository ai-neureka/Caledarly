import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/notifications/alarm_manager.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  const ScheduleDetailScreen({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

final _scheduleController = Get.put(SchedulesController());

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  final Set<ReminderOption> selectedReminders = {};
  bool isLoadingReminders = false;
  bool showReminderOptions = false;

  @override
  void initState() {
    super.initState();
    _scheduleController.getActivityDetailController(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(widget.title),
      ),
      body: Obx(() {
        if (_scheduleController.getting.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        final data = _scheduleController.loadedDetails.value.data;
        if (data == null || data.isEmpty) {
          return const Center(child: Text('Error fetching details'));
        }

        final detail = data.first;

        // ✅ Parse times - API sends times with Z but they're already in local time
        DateTime? startTime;
        DateTime? endTime;

        if (detail.startTime is String) {
          // Parse the string but treat it as local time (ignore the Z)
          final timeStr = (detail.startTime as String).replaceAll('Z', '');
          startTime = DateTime.parse(timeStr);
          print('🕐 Start time from API: ${detail.startTime}');
          print('🕐 Start time parsed: $startTime');
        } else if (detail.startTime is DateTime) {
          startTime = detail.startTime as DateTime;
        }

        if (detail.endTime is String) {
          // Parse the string but treat it as local time (ignore the Z)
          final timeStr = (detail.endTime as String).replaceAll('Z', '');
          endTime = DateTime.parse(timeStr);
          print('🕐 End time from API: ${detail.endTime}');
          print('🕐 End time parsed: $endTime');
        } else if (detail.endTime is DateTime) {
          endTime = detail.endTime as DateTime;
        }

        // Get current time
        final nowTz = tz.TZDateTime.now(tz.local);
        final now = DateTime(
          nowTz.year,
          nowTz.month,
          nowTz.day,
          nowTz.hour,
          nowTz.minute,
          nowTz.second,
        );
        print('🕐 Current time: $now');

        final bool isPast = endTime != null && endTime.isBefore(now);
        final bool isFutureStart = startTime != null && startTime.isAfter(now);

        // Helper for formatted display
        String formatDateTime(DateTime? dt) {
          if (dt == null) return '';

          final dateFormat = DateFormat('d MMM, yyyy');
          final timeFormat = DateFormat('h:mm a');

          return '${dateFormat.format(dt)} at ${timeFormat.format(dt)} (WAT)';
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Schedule Card
                Opacity(
                  opacity: isPast ? 0.5 : 1.0,
                  child: Card(
                    color: isPast ? Colors.grey.shade200 : AppColors.whiteColor,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  detail.activityId?.title ?? '',
                                  style: AppTextStyle().textInter(
                                    size: 18,
                                    weight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Opacity(
                                opacity: isFutureStart ? 1.0 : 0.5,
                                child: IconButton(
                                  tooltip: isFutureStart
                                      ? (showReminderOptions
                                            ? 'Hide reminders'
                                            : 'Show reminders')
                                      : 'Reminders available only for future events',
                                  icon: Icon(
                                    showReminderOptions
                                        ? Icons.alarm_on
                                        : Icons.alarm_add,
                                  ),
                                  color: isFutureStart
                                      ? AppColors.blue
                                      : Colors.grey,
                                  onPressed: () {
                                    if (!isFutureStart) {
                                      Get.snackbar(
                                        'Unavailable',
                                        'You can only set reminders for future events',
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      showReminderOptions =
                                          !showReminderOptions;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Display WAT times
                          Text(
                            'Start time: ${formatDateTime(startTime)}',
                            style: AppTextStyle().textInter(
                              size: 15,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'End time: ${formatDateTime(endTime)}',
                            style: AppTextStyle().textInter(
                              size: 15,
                              weight: FontWeight.w500,
                            ),
                          ),

                          // Show time until event
                          if (isFutureStart && startTime != null) ...[
                            const SizedBox(height: 8),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 12,
                            //     vertical: 6,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: AppColors.blue.withOpacity(0.1),
                            //     borderRadius: BorderRadius.circular(20),
                            //   ),
                            //   child: Text(
                            //     _getTimeUntil(startTime),
                            //     style: AppTextStyle().textInter(
                            //       size: 13,
                            //       weight: FontWeight.w500,
                            //       color: AppColors.blue,
                            //     ),
                            //   ),
                            // ),
                          ],

                          const SizedBox(height: 10),
                          Divider(color: AppColors.blue),
                          Text(
                            'Description',
                            style: AppTextStyle().textInter(
                              size: 15,
                              weight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            detail.activityId?.description ?? '',
                            style: AppTextStyle().textInter(
                              size: 15,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Reminders Section (only for future events)
                if (showReminderOptions &&
                    isFutureStart &&
                    startTime != null) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 24,
                                color: AppColors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Set Reminders',
                                style: AppTextStyle().textInter(
                                  size: 18,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get notified before your schedule starts',
                            style: AppTextStyle().textInter(
                              size: 13,
                              weight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reminder options
                          ...ReminderOption.values.map((option) {
                            final reminderTime = _calculateReminderTime(
                              startTime!,
                              option,
                            );

                            // Get current time properly
                            final nowTz = tz.TZDateTime.now(tz.local);
                            final currentTime = DateTime(
                              nowTz.year,
                              nowTz.month,
                              nowTz.day,
                              nowTz.hour,
                              nowTz.minute,
                              nowTz.second,
                            );

                            final isValidTime =
                                reminderTime?.isAfter(currentTime) ?? false;

                            return Opacity(
                              opacity: isValidTime ? 1.0 : 0.5,
                              child: CheckboxListTile(
                                value: selectedReminders.contains(option),
                                onChanged: isValidTime
                                    ? (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedReminders.add(option);
                                          } else {
                                            selectedReminders.remove(option);
                                          }
                                        });
                                      }
                                    : null,
                                title: Text(
                                  option.label,
                                  style: AppTextStyle().textInter(
                                    size: 15,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: isValidTime
                                    ? Text(
                                        'At ${formatDateTime(reminderTime)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      )
                                    : Text(
                                        'Not available (time has passed)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                activeColor: AppColors.blue,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 16),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoadingReminders
                                  ? null
                                  : () => _saveReminders(
                                      detail.activityId?.title ?? 'Schedule',
                                      startTime!,
                                    ),
                              icon: isLoadingReminders
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(Icons.save),
                              label: Text(
                                isLoadingReminders
                                    ? 'Saving...'
                                    : 'Save Reminders',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          if (selectedReminders.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '${selectedReminders.length} reminder(s) selected',
                                style: AppTextStyle().textInter(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // Calculate reminder time
  DateTime? _calculateReminderTime(DateTime startTime, ReminderOption option) {
    switch (option) {
      case ReminderOption.fiveMinutes:
        return startTime.subtract(const Duration(minutes: 5));
      case ReminderOption.tenMinutes:
        return startTime.subtract(const Duration(minutes: 10));
      case ReminderOption.thirtyMinutes:
        return startTime.subtract(const Duration(minutes: 30));
      case ReminderOption.oneHour:
        return startTime.subtract(const Duration(hours: 1));
      case ReminderOption.oneDay:
        return startTime.subtract(const Duration(days: 1));
    }
  }

  // Get human-readable time until event
  // String _getTimeUntil(DateTime eventTime) {
  //   final nowTz = tz.TZDateTime.now(tz.local);
  //   final now = DateTime(
  //     nowTz.year,
  //     nowTz.month,
  //     nowTz.day,
  //     nowTz.hour,
  //     nowTz.minute,
  //     nowTz.second,
  //   );
  //   final difference = eventTime.difference(now);

  //   if (difference.isNegative) return 'Event passed';

  //   if (difference.inDays > 0) {
  //     final days = difference.inDays;
  //     return 'Starts in $days ${days == 1 ? 'day' : 'days'}';
  //   } else if (difference.inHours > 0) {
  //     final hours = difference.inHours;
  //     return 'Starts in $hours ${hours == 1 ? 'hour' : 'hours'}';
  //   } else if (difference.inMinutes > 0) {
  //     final minutes = difference.inMinutes;
  //     return 'Starts in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  //   } else {
  //     return 'Starting soon!';
  //   }
  // }

  Future<void> _saveReminders(String title, DateTime startTime) async {
    if (selectedReminders.isEmpty) {
      Get.snackbar(
        'No Reminders Selected',
        'Please select at least one reminder option',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoadingReminders = true;
    });

    try {
      // Ensure timezone is initialized (should be done in main.dart)
      try {
        tz.TZDateTime.now(tz.local);
        print('✅ Timezone already initialized');
      } catch (e) {
        print('⚠️ Timezone not initialized, initializing now...');
        try {
          tz.initializeTimeZones();
          tz.setLocalLocation(tz.getLocation('Africa/Lagos'));
          print('✅ Timezone initialized successfully');
        } catch (tzError) {
          print('❌ Failed to initialize timezone: $tzError');
        }
      }

      // Initialize AlarmManager
      await AlarmManager.initialize();

      // Request permissions
      final hasPermissions = await AlarmManager.requestAlarmPermissions();
      if (!hasPermissions) {
        Get.snackbar(
          'Permissions Required',
          'Please grant notification and alarm permissions to set reminders',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        setState(() {
          isLoadingReminders = false;
        });
        return;
      }

      // Cancel existing reminders for this schedule
      await AlarmManager.cancelRemindersForSchedule(widget.id);

      int reminderIndex = 0;
      int successCount = 0;

      // Get current time
      final nowTz = tz.TZDateTime.now(tz.local);
      final now = DateTime(
        nowTz.year,
        nowTz.month,
        nowTz.day,
        nowTz.hour,
        nowTz.minute,
        nowTz.second,
      );

      for (final option in selectedReminders) {
        final reminderTime = _calculateReminderTime(startTime, option);

        if (reminderTime != null && reminderTime.isAfter(now)) {
          // Convert to TZDateTime properly - don't use .from() as it causes issues
          final tzReminderTime = tz.TZDateTime(
            tz.local,
            reminderTime.year,
            reminderTime.month,
            reminderTime.day,
            reminderTime.hour,
            reminderTime.minute,
            reminderTime.second,
          );

          final tzStartTime = tz.TZDateTime(
            tz.local,
            startTime.year,
            startTime.month,
            startTime.day,
            startTime.hour,
            startTime.minute,
            startTime.second,
          );

          print('📅 Scheduling reminder:');
          print('   Option: ${option.label}');
          print('   Reminder time (local): $reminderTime');
          print('   TZ Reminder time: $tzReminderTime');
          print('   Start time (local): $startTime');
          print('   TZ Start time: $tzStartTime');

          await AlarmManager.scheduleReminderWithAlarm(
            widget.id,
            title,
            tzReminderTime,
            tzStartTime,
            option.label,
            reminderIndex,
          );

          successCount++;
          reminderIndex++;
        } else {
          print('⚠️ Skipping ${option.label} - time has passed');
        }
      }

      setState(() {
        isLoadingReminders = false;
        if (successCount > 0) {
          showReminderOptions = false;
        }
      });

      if (successCount > 0) {
        Get.snackbar(
          'Reminders Set Successfully',
          '$successCount reminder(s) scheduled for "$title"',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'No Valid Reminders',
          'All selected reminder times have passed',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        isLoadingReminders = false;
      });

      print('❌ Error saving reminders: $e');
      Get.snackbar(
        'Error',
        'Failed to set reminders: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
      );
    }
  }
}

// Enum for reminder options
enum ReminderOption { fiveMinutes, tenMinutes, thirtyMinutes, oneHour, oneDay }

extension ReminderOptionExtension on ReminderOption {
  String get label {
    switch (this) {
      case ReminderOption.fiveMinutes:
        return '5 minutes before';
      case ReminderOption.tenMinutes:
        return '10 minutes before';
      case ReminderOption.thirtyMinutes:
        return '30 minutes before';
      case ReminderOption.oneHour:
        return '1 hour before';
      case ReminderOption.oneDay:
        return '1 day before';
    }
  }
}
