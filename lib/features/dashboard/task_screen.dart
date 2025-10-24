import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/all_activity_instances_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  final SchedulesController _controller = Get.put(SchedulesController());

  @override
  void initState() {
    super.initState();
    _controller.getTaskController();
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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProgressOverview(),
            const SizedBox(height: 20),
            Expanded(child: _buildAllTasksList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          "All tasks at a glance",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
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
            // CircularPercentIndicator(
            //   radius: 40.0,
            //   lineWidth: 8.0,
            //   percent: 10,
            //   animation: true,
            //   center: Text(
            //     "${(0.1 * 100).toInt()}%",
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   progressColor: Colors.white,
            //   backgroundColor: Colors.white30,
            // ),
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
                    " ${_controller.loadedTasks.value.data!.length} tasks ",
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

  Widget _buildAllTasksList() {
    return Obx(() {
      if (_controller.fetchingTasks.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.loadedTasks.value.data!.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No tasks available",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: _controller.loadedTasks.value.data!.length,
        itemBuilder: (context, index) {
          final task = _controller.loadedTasks.value.data![index];
          final isDone = task.status?.toLowerCase() == 'completed';

          // Color priorityColor;
          // switch (task.activityInstanceId.!.priorityLevel?.toLowerCase()) {
          //   case 'high':
          //     priorityColor = Colors.redAccent;
          //     break;
          //   case 'medium':
          //     priorityColor = Colors.orangeAccent;
          //     break;
          //   default:
          //     priorityColor = Colors.greenAccent;
          // }

          String timeDisplay = '';
          if (task.activityInstanceId!.createdAt != null) {
            timeDisplay = DateFormat(
              'hh:mm a',
            ).format(task.activityInstanceId!.createdAt!);
          }

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.flag, color: AppColors.blue),
              ),
              title: Text(
                task.notes ?? 'Untitled Task',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Assigned to you by:${task.assignedBy?.username}' ??
                    'Untitled Task',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms);
        },
      );
    });
  }
}
