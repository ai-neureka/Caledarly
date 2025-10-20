import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/dashboard/reoccuring_schedule_screen.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activitie.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.getAllUserActivitiesController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
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
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(Icons.repeat, color: Colors.blue),
                      title: const Text("Recurring"),
                      onTap: () {
                        Navigator.pop(context); // close the sheet
                        Get.to(() => const ReoccuringScheduleScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
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
                          color: isActive ? AppColors.blue : Colors.transparent,
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

            // Calendar / Header based on view
            _buildCalendarView(),

            const SizedBox(height: 20),

            // Schedule List or Day View
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

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.blue.withOpacity(0.3),
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
                    color: isSelected ? Colors.white : Colors.grey[600],
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
                            : (isToday ? Colors.blue : Colors.black),
                      ),
                    ),
                    if (hasSchedule && !isSelected)
                      Positioned(
                        bottom: -4,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
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
        // Check if there's a schedule on this day
        final schedulesOnDay = _getSchedulesForDate(day);
        if (schedulesOnDay.isNotEmpty) {
          // If there's only one schedule, go directly to detail
          if (schedulesOnDay.length == 1) {
            Get.to(
              () => ScheduleDetailScreen(
                id: schedulesOnDay[0].id ?? '',
                title: schedulesOnDay[0].title ?? '',
              ),
            );
          } else {
            // If multiple schedules, show a bottom sheet to choose
            _showScheduleSelectionSheet(schedulesOnDay);
          }
        } else {
          // No schedule, navigate to create screen with preselected date
          Get.to(
            () => CreateSchdeuleScreen(),
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
          color: AppColors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.blue,
          shape: BoxShape.circle,
        ),
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
            ? AppColors.blue
            : (isToday ? AppColors.blue.withOpacity(0.5) : Colors.transparent),
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
                color: isSelected || isToday ? Colors.white : AppColors.blue,
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
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = month);
              // Show schedules for this month
              final schedulesInMonth = _getSchedulesForMonth(month);
              if (schedulesInMonth.isNotEmpty) {
                _showScheduleSelectionSheet(schedulesInMonth);
              } else {
                // Navigate to create screen
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
                color: isSelected ? AppColors.blue : Colors.white,
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
                      color: isSelected ? Colors.white : Colors.black87,
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
                          color: AppColors.blue,
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

  // New method to build day timeline view like Google Calendar
  Widget _buildDayTimelineView() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final schedulesForDay = _getSchedulesForDate(_selectedDate);

      return ListView.builder(
        itemCount: 24, // 24 hours in a day
        itemBuilder: (context, hour) {
          final schedulesInHour = schedulesForDay.where((schedule) {
            if (schedule.createdAt == null) return false;
            return schedule.createdAt!.hour == hour;
          }).toList();

          return InkWell(
            onTap: () {
              if (schedulesInHour.isEmpty) {
                // Navigate to create schedule with preselected time
                final preselectedDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  hour,
                );
                Get.to(
                  () => CreateSchdeuleScreen(),
                  arguments: {'preselectedDate': preselectedDateTime},
                )?.then((_) {
                  _controller.getAllUserActivitiesController();
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hour label
                  SizedBox(
                    width: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('ha').format(DateTime(2000, 1, 1, hour)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Schedule(s) or empty space
                  Expanded(
                    child: schedulesInHour.isEmpty
                        ? Container(
                            height: 60,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Tap to add schedule',
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
                                      title: schedule.title ?? '',
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
                                    color: AppColors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                      left: BorderSide(
                                        color: _getPriorityColor(
                                          schedule.priorityLevel ?? 'low',
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
                                              schedule.title ?? 'Untitled',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (schedule.description != null &&
                                                schedule
                                                    .description!
                                                    .isNotEmpty)
                                              Text(
                                                schedule.description!,
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
                                              ).format(schedule.createdAt!),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (schedule.priorityLevel != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(
                                              schedule.priorityLevel!,
                                            ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            schedule.priorityLevel!
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: _getPriorityColor(
                                                schedule.priorityLevel!,
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

  // Helper method to check if a date has schedules
  bool _hasScheduleOnDate(DateTime date) {
    final activities = _controller.loadedActivities.value.data ?? [];
    return activities.any((activity) {
      if (activity.createdAt == null) return false;
      return DateUtils.isSameDay(activity.createdAt!, date);
    });
  }

  // Helper method to check if a month has schedules
  bool _hasScheduleInMonth(DateTime month) {
    final activities = _controller.loadedActivities.value.data ?? [];
    return activities.any((activity) {
      if (activity.createdAt == null) return false;
      return activity.createdAt!.year == month.year &&
          activity.createdAt!.month == month.month;
    });
  }

  // Get schedules for a specific date
  List<ScheduleDatum> _getSchedulesForDate(DateTime date) {
    final activities = _controller.loadedActivities.value.data ?? [];
    return activities.where((activity) {
      if (activity.createdAt == null) return false;
      return DateUtils.isSameDay(activity.createdAt!, date);
    }).toList();
  }

  // Get schedules for a specific month
  List<ScheduleDatum> _getSchedulesForMonth(DateTime month) {
    final activities = _controller.loadedActivities.value.data ?? [];
    return activities.where((activity) {
      if (activity.createdAt == null) return false;
      return activity.createdAt!.year == month.year &&
          activity.createdAt!.month == month.month;
    }).toList();
  }

  // Show bottom sheet with schedule selection
  void _showScheduleSelectionSheet(List<ScheduleDatum> schedules) {
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
                          schedule.priorityLevel ?? 'low',
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.schedule,
                          color: _getPriorityColor(
                            schedule.priorityLevel ?? 'low',
                          ),
                        ),
                      ),
                      title: Text(schedule.title ?? 'Untitled'),
                      subtitle: Text(
                        schedule.createdAt != null
                            ? DateFormat('hh:mm a').format(schedule.createdAt!)
                            : '',
                      ),
                      trailing: schedule.priorityLevel != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  schedule.priorityLevel!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schedule.priorityLevel!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(
                                    schedule.priorityLevel!,
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
                            title: schedule.title ?? '',
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
                    backgroundColor: AppColors.blue,
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

  // Filter activities based on selected view and date
  List<ScheduleDatum> _getFilteredActivities() {
    final activities = _controller.loadedActivities.value.data ?? [];

    return activities.where((activity) {
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
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
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

      return ListView.builder(
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = filteredActivities[index];

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
                  title: activity.title ?? '',
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
                  backgroundColor: AppColors.blue.withOpacity(0.2),
                  child: const Icon(Icons.schedule, color: AppColors.blue),
                ),
                title: Text(
                  activity.title ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.description ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activity.categoryId?.name != null)
                      Text(
                        activity.categoryId!.name!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                trailing: activity.priorityLevel != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            activity.priorityLevel!,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.priorityLevel!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(activity.priorityLevel!),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
