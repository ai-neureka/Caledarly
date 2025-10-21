import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activitie.dart';
import 'package:apc_schedular/features/schedules/model/all_activity_instances_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  String _selectedView = 'Day';
  final List<String> _views = ['Day', 'Week', 'Month', 'Year'];
  DateTime _selectedDate = DateTime.now();
  final SchedulesController _controller = Get.put(SchedulesController());

  @override
  void initState() {
    super.initState();
    _controller.getAllUserActivitiesController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Task Overview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildToggleTabs(),
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProgressOverview(),
            const SizedBox(height: 20),
            Expanded(child: _buildTaskView()),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
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
                      ? Colors.deepPurpleAccent
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
    ).animate().fadeIn().slideY(begin: 0.3, duration: 400.ms);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          "Your ${_selectedView.toLowerCase()} tasks at a glance",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // Filter tasks (only category = "Task")
  List<ScheduleDatum> _getFilteredTasks() {
    final activities = _controller.loadedActivities.value.data ?? [];

    // First filter: Only activities with category name "Task"
    final taskActivities = activities.where((activity) {
      return activity.activityId!.categoryId?.toLowerCase() == 'task';
    }).toList();

    // Second filter: Based on selected view and date
    return taskActivities.where((activity) {
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

  // Get all tasks for the current view (for progress calculation)
  List<ScheduleDatum> _getAllTasksForView() {
    final activities = _controller.loadedActivities.value.data ?? [];

    return activities.where((activity) {
      if (activity.activityId!.categoryId?.toLowerCase() != 'task')
        return false;
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

  Widget _buildProgressOverview() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff7F7FD5), Color(0xff86A8E7), Color(0xff91EAE4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      final tasks = _getAllTasksForView();
      final completed = tasks
          .where((t) => t.status?.toLowerCase() == 'completed')
          .length;
      final percent = tasks.isEmpty ? 0.0 : completed / tasks.length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff7F7FD5), Color(0xff86A8E7), Color(0xff91EAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 8.0,
              percent: percent,
              animation: true,
              center: Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: Colors.white,
              backgroundColor: Colors.white30,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    " ${tasks.length} tasks ",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
    });
  }

  Widget _buildTaskView() {
    switch (_selectedView) {
      case 'Day':
        return _buildDailyTasks();
      case 'Week':
        return _buildWeeklySummary();
      case 'Month':
        return _buildMonthlyGrid();
      case 'Year':
        return _buildYearlyHeatmap();
      default:
        return _buildDailyTasks();
    }
  }

  Widget _buildDailyTasks() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final tasks = _getFilteredTasks();

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No tasks for today",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      // Sort by created date
      tasks.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isDone = task.status?.toLowerCase() == 'completed';

          Color priorityColor;
          switch (task.activityId!.priorityLevel?.toLowerCase()) {
            case 'high':
              priorityColor = Colors.redAccent;
              break;
            case 'medium':
              priorityColor = Colors.orangeAccent;
              break;
            default:
              priorityColor = Colors.greenAccent;
          }

          String timeDisplay = '';
          if (task.createdAt != null) {
            timeDisplay = DateFormat('hh:mm a').format(task.createdAt!);
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: priorityColor.withOpacity(0.2),
                child: Icon(Icons.flag, color: priorityColor),
              ),
              title: Text(
                task.activityId!.title ?? 'Untitled Task',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (timeDisplay.isNotEmpty) Text(timeDisplay),
                  if (task.activityId!.description != null &&
                      task.activityId!.description!.isNotEmpty)
                    Text(
                      task.activityId!.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              // trailing: Icon(
              //   isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              //   color: isDone ? Colors.green : Colors.grey,
              // ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms);
        },
      );
    });
  }

  Widget _buildWeeklySummary() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );

      final weeks = List.generate(7, (i) {
        final day = startOfWeek.add(Duration(days: i));

        // Get tasks for this specific day
        final allActivities = _controller.loadedActivities.value.data ?? [];
        final dayTasks = allActivities.where((activity) {
          if (activity.activityId!.categoryId?.toLowerCase() != 'task')
            return false;
          if (activity.createdAt == null) return false;
          return DateUtils.isSameDay(activity.createdAt!, day);
        }).toList();

        final completed = dayTasks
            .where((t) => t.status?.toLowerCase() == 'completed')
            .length;
        final progress = dayTasks.isEmpty ? 0.0 : completed / dayTasks.length;

        return {"day": DateFormat('E').format(day), "progress": progress};
      });

      return ListView(
        children: weeks
            .map(
              (w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text(w['day'] as String)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (w['progress'] as double),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.grey[300],
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("${((w['progress'] as double) * 100).toInt()}%"),
                  ],
                ),
              ),
            )
            .toList(),
      ).animate().fadeIn(duration: 600.ms);
    });
  }

  Widget _buildMonthlyGrid() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final daysInMonth = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        0,
      ).day;
      final days = List.generate(daysInMonth, (i) => i + 1);

      return GridView.count(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: days.map((day) {
          final date = DateTime(_selectedDate.year, _selectedDate.month, day);
          final isToday = DateUtils.isSameDay(date, DateTime.now());

          // Get tasks for this day
          final allActivities = _controller.loadedActivities.value.data ?? [];
          final dayTasks = allActivities.where((activity) {
            if (activity.activityId!.categoryId?.toLowerCase() != 'task')
              return false;
            if (activity.createdAt == null) return false;
            return DateUtils.isSameDay(activity.createdAt!, date);
          }).toList();

          final completed = dayTasks
              .where((t) => t.status?.toLowerCase() == 'completed')
              .length;
          final progress = dayTasks.isEmpty ? 0.0 : completed / dayTasks.length;

          return Container(
            decoration: BoxDecoration(
              color: isToday ? Colors.deepPurpleAccent : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$day",
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: isToday
                        ? Colors.white30
                        : Colors.grey.withOpacity(0.2),
                    color: isToday ? Colors.white : Colors.deepPurpleAccent,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ).animate().fadeIn(duration: 600.ms);
    });
  }

  Widget _buildYearlyHeatmap() {
    return Obx(() {
      if (_controller.loadingAllActivities.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final months = List.generate(12, (i) => i + 1);

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: months.map((month) {
          final monthDate = DateTime(_selectedDate.year, month, 1);

          // Get tasks for this month
          final allActivities = _controller.loadedActivities.value.data ?? [];
          final monthTasks = allActivities.where((activity) {
            if (activity.activityId!.categoryId?.toLowerCase() != 'task')
              return false;
            if (activity.createdAt == null) return false;
            return activity.createdAt!.year == _selectedDate.year &&
                activity.createdAt!.month == month;
          }).toList();

          final completed = monthTasks
              .where((t) => t.status?.toLowerCase() == 'completed')
              .length;
          final completion = monthTasks.isEmpty
              ? 0.0
              : completed / monthTasks.length;

          return Container(
            width: MediaQuery.of(context).size.width / 3.5,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.white,
                Colors.deepPurpleAccent,
                completion * 0.8,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMM').format(monthDate),
                  style: TextStyle(
                    color: completion > 0.6 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(completion * 100).toInt()}%",
                  style: TextStyle(
                    color: completion > 0.6 ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ).animate().fadeIn(duration: 600.ms);
    });
  }
}
