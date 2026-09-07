import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/features/widget/app_shimmer.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/dashboard/reoccuring_schedule_screen.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activity_instances_model.dart';
import 'package:apc_schedular/features/schedules/presentation/create_schdeule_screen.dart';
import 'package:apc_schedular/features/schedules/presentation/schedule_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScheduleOverviewScreen extends StatefulWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  State<ScheduleOverviewScreen> createState() => _ScheduleOverviewScreenState();
}

class _ScheduleOverviewScreenState extends State<ScheduleOverviewScreen> {
  String _selectedView = 'Day';
  DateTime _selectedDate = DateTime.now();
  final SchedulesController _controller = Get.put(SchedulesController());

  final List<String> _views = ['Day', 'Week', 'Month', 'Year'];

  // Meeting category ID constant
  static const String MEETING_CATEGORY_ID = "68fb9f9fdc27b4a6a649a87d";

  @override
  void initState() {
    super.initState();
    _controller.getAllUserActivitiesController();
  }

  // Helper method to check if activity is a meeting
  bool _isMeeting(ScheduleDatum activity) {
    return activity.activityId?.categoryId == MEETING_CATEGORY_ID;
  }

  // Helper method to get only meetings from activities list
  List<ScheduleDatum> _getOnlyMeetings(List<ScheduleDatum> activities) {
    return activities.where((activity) => _isMeeting(activity)).toList();
  }

  // Helper method to check if a datetime is in the past
  bool _isInPast(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.isBefore(now);
  }

  // Helper method to check if a date is before today
  bool _isDateBeforeToday(DateTime date) {
    final today = DateTime.now();
    return date.year < today.year ||
        (date.year == today.year && date.month < today.month) ||
        (date.year == today.year &&
            date.month == today.month &&
            date.day < today.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: Icon(Icons.add, color: AppColors.whiteColor),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Choose Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(
                        Icons.repeat,
                        color: AppColors.secondary,
                      ),
                      title: const Text("Recurring"),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const ReoccuringScheduleScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.success,
                      ),
                      title: const Text("New"),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const CreateSchdeuleScreen())?.then((_) {
                          _controller.getAllUserActivitiesController();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "My Schedule",
          style: AppTextStyle().textInter(weight: FontWeight.bold, size: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.whiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _views.map((view) {
                  final isActive = view == _selectedView;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedView = view),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          view,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn().slideY(begin: 0.3, duration: 400.ms),
            const SizedBox(height: 20),
            _buildCalendarView(),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedView == 'Day'
                  ? _buildDayTimelineView()
                  : _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    switch (_selectedView) {
      case 'Day':
        return _buildDayHeader();
      case 'Week':
        return _buildWeekCalendar();
      case 'Month':
        return _buildMonthCalendar();
      case 'Year':
        return _buildYearOverview();
      default:
        return const SizedBox();
    }
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return '';

    final dateFormat = DateFormat('d MMM, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return '${dateFormat.format(dt)} at ${timeFormat.format(dt)} (WAT)';
  }

  Widget _buildDayHeader() {
    return Column(
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          "Your schedule for today",
          style: AppTextStyle().textInter(size: 14, weight: FontWeight.w400),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildWeekCalendar() {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isToday = DateUtils.isSameDay(day, DateTime.now());
        final isSelected = DateUtils.isSameDay(day, _selectedDate);
        final hasSchedule = _hasScheduleOnDate(day);
        final isPast = _isDateBeforeToday(day);

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('E').format(day),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isPast ? Colors.grey[400] : Colors.grey[600]),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      DateFormat('d').format(day),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isToday
                                  ? AppColors.secondary
                                  : (isPast ? Colors.grey[400] : Colors.black)),
                      ),
                    ),
                    if (hasSchedule && !isSelected)
                      Positioned(
                        bottom: -4,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildMonthCalendar() {
    return TableCalendar(
      focusedDay: _selectedDate,
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      currentDay: _selectedDate,
      onDaySelected: (day, _) {
        setState(() => _selectedDate = day);

        // Check if the selected date is in the past
        if (_isDateBeforeToday(day)) {
          // Only view schedules, don't allow creation
          final schedulesOnDay = _getSchedulesForDate(day);
          if (schedulesOnDay.isNotEmpty) {
            if (schedulesOnDay.length == 1) {
              Get.to(
                () => ScheduleDetailScreen(
                  id: schedulesOnDay[0].id ?? '',
                  title: schedulesOnDay[0].activityId?.title ?? '',
                ),
              );
            } else {
              _showScheduleSelectionSheet(schedulesOnDay, isPastDate: true);
            }
          } else {
            // Show message that can't create schedule in the past
            Get.snackbar(
              'Cannot Create Schedule',
              'You cannot create schedules for past dates',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
          return;
        }

        // For current and future dates
        final schedulesOnDay = _getSchedulesForDate(day);
        if (schedulesOnDay.isNotEmpty) {
          if (schedulesOnDay.length == 1) {
            Get.to(
              () => ScheduleDetailScreen(
                id: schedulesOnDay[0].id ?? '',
                title: schedulesOnDay[0].activityId?.title ?? '',
              ),
            );
          } else {
            _showScheduleSelectionSheet(schedulesOnDay);
          }
        } else {
          Get.to(
            () => ReoccuringScheduleScreen(),
            arguments: {'preselectedDate': day},
          )?.then((_) {
            _controller.getAllUserActivitiesController();
          });
        }
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (_hasScheduleOnDate(day)) {
            return _buildCalendarDayWithDot(day, false, false);
          }
          return null;
        },
        todayBuilder: (context, day, focusedDay) {
          if (_hasScheduleOnDate(day)) {
            return _buildCalendarDayWithDot(day, true, false);
          }
          return null;
        },
        selectedBuilder: (context, day, focusedDay) {
          if (_hasScheduleOnDate(day)) {
            return _buildCalendarDayWithDot(day, false, true);
          }
          return null;
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
        // Disable past dates visually
        disabledTextStyle: TextStyle(color: Colors.grey[400]),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildCalendarDayWithDot(DateTime day, bool isToday, bool isSelected) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.secondary
            : (isToday
                  ? AppColors.secondary.withOpacity(0.5)
                  : Colors.transparent),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || isToday ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected || isToday
                    ? Colors.white
                    : AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearOverview() {
    final months = List.generate(
      12,
      (i) => DateTime(DateTime.now().year, i + 1, 1),
    );
    return Obx(() {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: months.map((month) {
          final isSelected = _selectedDate.month == month.month;
          final hasSchedule = _hasScheduleInMonth(month);
          final isPastMonth = month.isBefore(
            DateTime(DateTime.now().year, DateTime.now().month, 1),
          );

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = month);

              // Check if month is in the past
              if (isPastMonth) {
                final schedulesInMonth = _getSchedulesForMonth(month);
                if (schedulesInMonth.isNotEmpty) {
                  _showScheduleSelectionSheet(
                    schedulesInMonth,
                    isPastDate: true,
                  );
                } else {
                  Get.snackbar(
                    'Cannot Create Schedule',
                    'You cannot create schedules for past months',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.error.withOpacity(0.8),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                }
                return;
              }

              // For current and future months
              final schedulesInMonth = _getSchedulesForMonth(month);
              if (schedulesInMonth.isNotEmpty) {
                _showScheduleSelectionSheet(schedulesInMonth);
              } else {
                Get.to(
                  () => CreateSchdeuleScreen(),
                  arguments: {'preselectedDate': month},
                )?.then((_) {
                  _controller.getAllUserActivitiesController();
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width / 3.6,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(month),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isPastMonth ? Colors.grey[400] : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasSchedule && !isSelected)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ).animate().fadeIn(duration: 500.ms);
    });
  }

  Widget _buildDayTimelineView() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const AppPageShimmer();
      }

      final schedulesForDay = _getSchedulesForDate(_selectedDate);
      final now = DateTime.now();
      final isToday = DateUtils.isSameDay(_selectedDate, now);
      final isPastDay = _isDateBeforeToday(_selectedDate);

      return ListView.builder(
        itemCount: 24,
        itemBuilder: (context, hour) {
          final schedulesInHour = schedulesForDay.where((schedule) {
            if (schedule.startTime == null) return false;
            return schedule.startTime!.hour == hour;
          }).toList();

          // Check if this hour is in the past
          final hourDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            hour,
          );
          final isPastHour = hourDateTime.isBefore(now);

          return InkWell(
            onTap: schedulesInHour.isEmpty && !isPastHour && !isPastDay
                ? () {
                    final preselectedDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour,
                    );
                    Get.to(
                      () => ReoccuringScheduleScreen(),
                      arguments: {'preselectedDate': preselectedDateTime},
                    )?.then((_) {
                      _controller.getAllUserActivitiesController();
                    });
                  }
                : (isPastHour || isPastDay) && schedulesInHour.isEmpty
                ? () {
                    Get.snackbar(
                      'Cannot Create Schedule',
                      'You cannot create schedules for past times',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.error.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                color: (isPastHour || isPastDay) && schedulesInHour.isEmpty
                    ? Colors.grey[100]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('ha').format(DateTime(2000, 1, 1, hour)),
                        style: TextStyle(
                          fontSize: 12,
                          color: (isPastHour || isPastDay)
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: schedulesInHour.isEmpty
                        ? Container(
                            height: 60,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              (isPastHour || isPastDay)
                                  ? ''
                                  : 'Tap to add schedule',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Column(
                            children: schedulesInHour.map((schedule) {
                              return GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => ScheduleDetailScreen(
                                      id: schedule.id ?? '',
                                      title: schedule.activityId!.title ?? '',
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                      left: BorderSide(
                                        color: _getPriorityColor(
                                          schedule.activityId!.priorityLevel ??
                                              'low',
                                        ),
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule.activityId!.title ??
                                                  'Untitled',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (schedule
                                                        .activityId!
                                                        .description !=
                                                    null &&
                                                schedule
                                                    .activityId!
                                                    .description!
                                                    .isNotEmpty)
                                              Text(
                                                schedule
                                                    .activityId!
                                                    .description!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            Text(
                                              DateFormat(
                                                'hh:mm a',
                                              ).format(schedule.startTime!),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (schedule.activityId!.priorityLevel !=
                                          null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(
                                              schedule
                                                  .activityId!
                                                  .priorityLevel!,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            schedule.activityId!.priorityLevel!
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: _getPriorityColor(
                                                schedule
                                                    .activityId!
                                                    .priorityLevel!,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  bool _hasScheduleOnDate(DateTime date) {
    final activities = _controller.loadedActivities.value.data ?? [];
    // Filter to only meetings
    final meetings = _getOnlyMeetings(activities);
    return meetings.any((activity) {
      if (activity.createdAt == null) return false;
      return DateUtils.isSameDay(activity.createdAt!, date);
    });
  }

  bool _hasScheduleInMonth(DateTime month) {
    final activities = _controller.loadedActivities.value.data ?? [];
    // Filter to only meetings
    final meetings = _getOnlyMeetings(activities);
    return meetings.any((activity) {
      if (activity.createdAt == null) return false;
      return activity.createdAt!.year == month.year &&
          activity.createdAt!.month == month.month;
    });
  }

  List<ScheduleDatum> _getSchedulesForDate(DateTime date) {
    final activities = _controller.loadedActivities.value.data ?? [];
    // Filter to only meetings
    final meetings = _getOnlyMeetings(activities);
    return meetings.where((activity) {
      if (activity.createdAt == null) return false;
      return DateUtils.isSameDay(activity.createdAt!, date);
    }).toList();
  }

  List<ScheduleDatum> _getSchedulesForMonth(DateTime month) {
    final activities = _controller.loadedActivities.value.data ?? [];
    // Filter to only meetings
    final meetings = _getOnlyMeetings(activities);
    return meetings.where((activity) {
      if (activity.createdAt == null) return false;
      return activity.createdAt!.year == month.year &&
          activity.createdAt!.month == month.month;
    }).toList();
  }

  void _showScheduleSelectionSheet(
    List<ScheduleDatum> schedules, {
    bool isPastDate = false,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedules on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(
                          schedule.activityId!.priorityLevel ?? 'low',
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.schedule,
                          color: _getPriorityColor(
                            schedule.activityId!.priorityLevel ?? 'low',
                          ),
                        ),
                      ),
                      title: Text(schedule.activityId!.title ?? 'Untitled'),
                      subtitle: Text(
                        schedule.createdAt != null
                            ? DateFormat('hh:mm a').format(schedule.createdAt!)
                            : '',
                      ),
                      trailing: schedule.activityId!.priorityLevel != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  schedule.activityId!.priorityLevel!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schedule.activityId!.priorityLevel!
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(
                                    schedule.activityId!.priorityLevel!,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(
                          () => ScheduleDetailScreen(
                            id: schedule.id ?? '',
                            title: schedule.activityId!.title ?? '',
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (!isPastDate)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(
                        () => CreateSchdeuleScreen(),
                        arguments: {'preselectedDate': _selectedDate},
                      )?.then((_) {
                        _controller.getAllUserActivitiesController();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<ScheduleDatum> _getFilteredActivities() {
    final activities = _controller.loadedActivities.value.data ?? [];
    // Filter to only meetings first
    final meetings = _getOnlyMeetings(activities);

    return meetings.where((activity) {
      if (activity.createdAt == null) return false;

      final createdDate = activity.createdAt!;

      switch (_selectedView) {
        case 'Day':
          return DateUtils.isSameDay(createdDate, _selectedDate);

        case 'Week':
          final startOfWeek = _selectedDate.subtract(
            Duration(days: _selectedDate.weekday - 1),
          );
          final endOfWeek = startOfWeek.add(
            const Duration(days: 6, hours: 23, minutes: 59),
          );
          return createdDate.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ) &&
              createdDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));

        case 'Month':
          return createdDate.year == _selectedDate.year &&
              createdDate.month == _selectedDate.month;

        case 'Year':
          return createdDate.year == _selectedDate.year;

        default:
          return false;
      }
    }).toList();
  }

  Widget _buildScheduleList() {
    // For Week view, show the new grid layout
    if (_selectedView == 'Week') {
      return _buildWeekGridView();
    }

    // For other views (Month, Year), keep the existing list view
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const AppPageShimmer();
      }

      final filteredActivities = _getFilteredActivities();

      if (filteredActivities.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No schedules for this ${_selectedView.toLowerCase()}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      filteredActivities.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return a.createdAt!.compareTo(b.createdAt!);
      });
      final now = DateTime.now();

      // Sort most recent first
      final reversedActivities = filteredActivities.reversed.toList();

      return ListView.builder(
        itemCount: reversedActivities.length,
        itemBuilder: (context, index) {
          final activity = reversedActivities[index];

          // Determine if the activity is in the past
          final isPast =
              activity.startTime != null && activity.startTime!.isBefore(now);

          String timeDisplay = '';
          if (activity.createdAt != null) {
            if (_selectedView == 'Day') {
              timeDisplay = DateFormat('hh:mm a').format(activity.createdAt!);
            } else {
              timeDisplay = DateFormat(
                'MMM d, hh:mm a',
              ).format(activity.createdAt!);
            }
          }

          return GestureDetector(
            onTap: () {
              Get.to(
                () => ScheduleDetailScreen(
                  id: activity.id ?? '',
                  title: activity.activityId?.title ?? '',
                ),
              );
            },
            child: Card(
              color: AppColors.whiteColor.withValues(alpha: 0.8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPast
                      ? Colors.grey.withOpacity(0.2)
                      : AppColors.secondary.withOpacity(0.2),
                  child: Icon(
                    Icons.schedule,
                    color: isPast ? Colors.grey : AppColors.secondary,
                  ),
                ),
                title: Text(
                  activity.activityId?.title ?? 'Untitled',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityId?.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isPast ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activity.activityId?.categoryId != null)
                      Text(
                        DateFormat('hh:mm a').format(activity.startTime!),
                        style: TextStyle(
                          fontSize: 11,
                          color: isPast ? Colors.grey : AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Visibility(
                      visible: isPast ? true : false,
                      child: Text(
                        'Passed Schedule',
                        style: AppTextStyle().textInter(
                          size: 12,
                          color: AppColors.error.withValues(alpha: 0.2),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: activity.activityId?.priorityLevel != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            activity.activityId!.priorityLevel!,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.activityId!.priorityLevel!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPast
                                ? Colors.grey
                                : _getPriorityColor(
                                    activity.activityId!.priorityLevel!,
                                  ),
                          ),
                        ),
                      )
                    : null,
              ),
            ).animate().fadeIn(delay: (index * 100).ms),
          );
        },
      );
    });
  }

  Widget _buildWeekGridView() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const AppPageShimmer();
      }

      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

      // Define the hours you want to display (e.g., 12 AM to 11 PM or customize as needed)
      final hours = List.generate(24, (i) => i);

      return SingleChildScrollView(
        child: Column(
          children: [
            // Header with day names and dates
            Row(
              children: [
                // Empty cell for time column
                SizedBox(
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                // Day headers
                ...days.map((day) {
                  final isToday = DateUtils.isSameDay(day, DateTime.now());
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(day),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? AppColors.secondary
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d').format(day),
                            style: TextStyle(
                              fontSize: 11,
                              color: isToday
                                  ? AppColors.secondary
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            // Grid with hours and schedule cells
            ...hours.map((hour) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time label
                  SizedBox(
                    width: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('ha').format(DateTime(2000, 1, 1, hour)),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Schedule cells for each day
                  ...days.map((day) {
                    return _buildScheduleCell(day, hour);
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildScheduleCell(DateTime day, int hour) {
    final schedulesInHour = _getSchedulesForDateAndHour(day, hour);
    final hasSchedule = schedulesInHour.isNotEmpty;

    final cellDateTime = DateTime(day.year, day.month, day.day, hour);
    final isPast = cellDateTime.isBefore(DateTime.now());
    final isToday = DateUtils.isSameDay(day, DateTime.now());

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (hasSchedule) {
            // If there are schedules, show the first one or a selection sheet if multiple
            if (schedulesInHour.length == 1) {
              Get.to(
                () => ScheduleDetailScreen(
                  id: schedulesInHour[0].id ?? '',
                  title: schedulesInHour[0].activityId?.title ?? '',
                ),
              );
            } else {
              _showScheduleSelectionSheet(schedulesInHour);
            }
          } else if (!isPast) {
            // If no schedule and not in the past, allow creating a new schedule
            final preselectedDateTime = DateTime(
              day.year,
              day.month,
              day.day,
              hour,
            );
            Get.to(
              () => ReoccuringScheduleScreen(),
              arguments: {'preselectedDate': preselectedDateTime},
            )?.then((_) {
              _controller.getAllUserActivitiesController();
            });
          } else {
            // Show message for past times
            Get.snackbar(
              'Cannot Create Schedule',
              'You cannot create schedules for past times',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: hasSchedule
                ? AppColors.secondary
                : (isPast ? Colors.grey[200] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
          child: hasSchedule
              ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        schedulesInHour[0].activityId?.title ?? 'Untitled',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (schedulesInHour.length > 1)
                        Text(
                          '+${schedulesInHour.length - 1} more',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  List<ScheduleDatum> _getSchedulesForDateAndHour(DateTime date, int hour) {
    final activities = _controller.loadedActivities.value.data ?? [];
    final meetings = _getOnlyMeetings(activities);

    return meetings.where((activity) {
      if (activity.startTime == null) return false;
      return DateUtils.isSameDay(activity.startTime!, date) &&
          activity.startTime!.hour == hour;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.accent;
      case 'low':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }
}
