import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/notifications/alarm_manager.dart';
import 'package:apc_schedular/features/profile/controller/profile_controller.dart';
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
final _profileCotroller = Get.put(ProfileController());

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
        if (_scheduleController.getting.value ||
            _profileCotroller.loadedProfile.value.data?.user?.id == null) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }

        final userId = _profileCotroller.loadedProfile.value.data?.user?.id;
        final data = _scheduleController.loadedDetails.value.data;

        if (data == null || data.isEmpty) {
          return const Center(child: Text('Error fetching details'));
        }

        final detail = data.first;

        // Check if current user is the creator
        // Handle both object and string cases for created_by
        String? creatorId;
        if (detail.createdBy is Map || detail.createdBy is Object) {
          // If created_by is an object, get the _id field
          creatorId = detail.createdBy?.id ?? detail.createdBy?.id;
        } else if (detail.createdBy is String) {
          // If created_by is a string, use it directly
          creatorId = detail.createdBy as String;
        }

        // Also check activity's created_by
        String? activityCreatorId;
        if (detail.activityId?.createdBy is Map ||
            detail.activityId?.createdBy is Object) {
          activityCreatorId =
              detail.activityId?.createdBy ?? detail.activityId?.createdBy;
        } else if (detail.activityId?.createdBy is String) {
          activityCreatorId = detail.activityId?.createdBy as String;
        }

        final isCreator = creatorId == userId || activityCreatorId == userId;

        print('🔍 Creator Check:');
        print('   Current User ID: $userId');
        print('   Activity Instance Creator ID: $creatorId');
        print('   Activity Creator ID: $activityCreatorId');
        print('   Is Creator: $isCreator');

        DateTime? startTime;
        DateTime? endTime;

        if (detail.startTime is String) {
          final timeStr = (detail.startTime as String).replaceAll('Z', '');
          startTime = DateTime.parse(timeStr);
          print('🕐 Start time from API: ${detail.startTime}');
          print('🕐 Start time parsed: $startTime');
        } else if (detail.startTime is DateTime) {
          startTime = detail.startTime as DateTime;
        }

        if (detail.endTime is String) {
          final timeStr = (detail.endTime as String).replaceAll('Z', '');
          endTime = DateTime.parse(timeStr);
          print('🕐 End time from API: ${detail.endTime}');
          print('🕐 End time parsed: $endTime');
        } else if (detail.endTime is DateTime) {
          endTime = detail.endTime as DateTime;
        }

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

                              // Edit button (only if creator)
                              if (isCreator) ...[
                                IconButton(
                                  tooltip: 'Edit schedule',
                                  icon: Icon(Icons.edit),
                                  color: AppColors.blue,
                                  onPressed: () => _showEditBottomSheet(
                                    context,

                                    detail,
                                    detail.id ?? '',
                                    startTime,
                                    endTime,
                                  ),
                                ),
                              ],

                              // Delete button (only if creator)
                              if (isCreator) ...[
                                IconButton(
                                  tooltip: 'Delete schedule',
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _showDeleteConfirmation(
                                    context,
                                    detail.id,
                                  ),
                                ),
                              ],

                              // Reminder button
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

                          if (isFutureStart && startTime != null) ...[
                            const SizedBox(height: 8),
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

                          ...ReminderOption.values.map((option) {
                            final reminderTime = _calculateReminderTime(
                              startTime!,
                              option,
                            );

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

  void _showEditBottomSheet(
    BuildContext context,
    dynamic detail,
    String id,
    DateTime? currentStartTime,
    DateTime? currentEndTime,
  ) {
    DateTime selectedStartDate = currentStartTime ?? DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(selectedStartDate);
    DateTime selectedEndDate = currentEndTime ?? DateTime.now();
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(selectedEndDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Schedule',
                        style: AppTextStyle().textInter(
                          size: 20,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Start Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_today, color: AppColors.blue),
                    title: Text('Start Date'),
                    subtitle: Text(
                      DateFormat('d MMM, yyyy').format(selectedStartDate),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedStartDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            selectedStartDate.hour,
                            selectedStartDate.minute,
                          );
                        });
                      }
                    },
                  ),

                  // Start Time
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: AppColors.blue),
                    title: Text('Start Time'),
                    subtitle: Text(selectedStartTime.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime,
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedStartTime = picked;
                          selectedStartDate = DateTime(
                            selectedStartDate.year,
                            selectedStartDate.month,
                            selectedStartDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),

                  Divider(),

                  // End Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_today, color: Colors.red),
                    title: Text('End Date'),
                    subtitle: Text(
                      DateFormat('d MMM, yyyy').format(selectedEndDate),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate,
                        firstDate: selectedStartDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedEndDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            selectedEndDate.hour,
                            selectedEndDate.minute,
                          );
                        });
                      }
                    },
                  ),

                  // End Time
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: Colors.red),
                    title: Text('End Time'),
                    subtitle: Text(selectedEndTime.format(context)),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedEndTime,
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedEndTime = picked;
                          selectedEndDate = DateTime(
                            selectedEndDate.year,
                            selectedEndDate.month,
                            selectedEndDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Save Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _scheduleController.editingActivityInstance.value
                            ? null
                            : () async {
                                if (selectedEndDate.isBefore(
                                  selectedStartDate,
                                )) {
                                  Get.snackbar(
                                    'Invalid Time',
                                    'End time must be after start time',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                await _scheduleController
                                    .editingActivityInstanceController(
                                      // detail.activityId?.id ?? widget.id,
                                      id,
                                      selectedStartDate.toIso8601String(),
                                      selectedEndDate.toIso8601String(),
                                    );

                                Navigator.pop(context);
                                _scheduleController.getActivityDetailController(
                                  widget.id,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _scheduleController.editingActivityInstance.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Update Schedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text('Delete Schedule'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ,this schedule? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: _scheduleController.deletingActivity.value
                    ? null
                    : () async {
                        await _scheduleController
                            .deleteActivityInstanceController(detail);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to previous screen
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _scheduleController.deletingActivity.value
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text('Delete'),
              ),
            ),
          ],
        );
      },
    );
  }

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

      await AlarmManager.initialize();

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

      await AlarmManager.cancelRemindersForSchedule(widget.id);

      int reminderIndex = 0;
      int successCount = 0;

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
