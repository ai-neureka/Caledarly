import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/presentation/create_schdeule_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReoccuringScheduleScreen extends StatefulWidget {
  const ReoccuringScheduleScreen({super.key});

  @override
  State<ReoccuringScheduleScreen> createState() =>
      _ReoccuringScheduleScreenState();
}

final _activityController = Get.put(SchedulesController());

class _ReoccuringScheduleScreenState extends State<ReoccuringScheduleScreen> {
  final RxInt selectedIndex = (-1).obs;

  @override
  void initState() {
    _activityController.getReoccuringActivitiesController();
    super.initState();
  }

  Future<void> _showScheduleModal(
    BuildContext context,
    String activityId,
  ) async {
    DateTime? startDate;
    DateTime? endDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final dateFormat = DateFormat('yyyy-MM-dd');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set Schedule",
                    style: AppTextStyle().textInter(
                      size: 16,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start Date
                  ListTile(
                    title: const Text("Start Date"),
                    subtitle: Text(
                      startDate == null
                          ? "Select start date"
                          : dateFormat.format(startDate!),
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),

                  // End Date
                  ListTile(
                    title: Text(
                      "End Date",
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      endDate == null
                          ? "Select end date"
                          : dateFormat.format(endDate!),
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),

                  // Start Time
                  ListTile(
                    title: Text(
                      "Start Time",
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      startTime == null
                          ? "Select start time"
                          : startTime!.format(context),
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.access_time_outlined),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),

                  // End Time
                  ListTile(
                    title: const Text("End Time"),
                    subtitle: Text(
                      endTime == null
                          ? "Select end time"
                          : endTime!.format(context),
                      style: AppTextStyle().textInter(
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.access_time_outlined),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        if (startDate == null ||
                            endDate == null ||
                            startTime == null ||
                            endTime == null) {
                          Get.snackbar(
                            "Error",
                            "Please select all fields",
                            backgroundColor: Colors.redAccent.withOpacity(0.2),
                          );
                          return;
                        }

                        final startDateTime = DateTime(
                          startDate!.year,
                          startDate!.month,
                          startDate!.day,
                          startTime!.hour,
                          startTime!.minute,
                        );

                        final endDateTime = DateTime(
                          endDate!.year,
                          endDate!.month,
                          endDate!.day,
                          endTime!.hour,
                          endTime!.minute,
                        );

                        await _activityController
                            .createActivityInstanceController(
                              activityId,
                              startDateTime.toIso8601String(),
                              endDateTime.toIso8601String(),
                            );

                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Activity created successfully",
                          backgroundColor: Colors.green.withOpacity(0.2),
                        );
                      },
                      child: _activityController.createActivityInstance.value
                          ? Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            )
                          : Text(
                              "Create",
                              style: AppTextStyle().textInter(
                                size: 18,
                                color: AppColors.whiteColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddActivityModal(BuildContext context) async {
    Get.to(() => CreateSchdeuleScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(
          'Reoccuring',
          style: AppTextStyle().textInter(size: 15, weight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: Obx(
        () => _activityController.loadingReoccuring.value
            ? Center(child: CircularProgressIndicator(color: AppColors.blue))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // GridView with Add Button as First Item
                    Expanded(
                      child: GridView.builder(
                        itemCount:
                            (_activityController
                                    .reoccuringModel
                                    .value
                                    .data
                                    ?.length ??
                                0) +
                            1,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          // First item is the Add button
                          if (index == 0) {
                            return GestureDetector(
                              onTap: () => _showAddActivityModal(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      // AppColors.blue.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blue.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.blue,
                                            AppColors.blue.withValues(
                                              alpha: 0.3,
                                            ),
                                          ],
                                        ),
                                        color: AppColors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Add Activity',
                                      style: AppTextStyle().textInter(
                                        size: 14,
                                        color: AppColors.blue,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Subsequent items are activities
                          final item = _activityController
                              .reoccuringModel
                              .value
                              .data?[index - 1];
                          return GestureDetector(
                            onTap: () {
                              _showScheduleModal(context, item.id!);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.blue,
                                    AppColors.blue.withValues(alpha: 0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF667eea,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    // Decorative circles
                                    Positioned(
                                      top: -20,
                                      right: -20,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -10,
                                      left: -10,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Category badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item?.categoryId?.name ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Title
                                          Text(
                                            item!.title!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          // Description
                                          Expanded(
                                            child: Text(
                                              item.description ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.85,
                                                ),
                                                fontSize: 13,
                                                height: 1.3,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Author info
                                          Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  item.createdBy?.username ??
                                                      'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
