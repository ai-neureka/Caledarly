import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
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
            : _activityController.reoccuringModel.value.data == null ||
                  _activityController.reoccuringModel.value.data!.isEmpty
            ? Center(
                child: Text(
                  'No activities',
                  style: AppTextStyle().textInter(
                    size: 18,
                    weight: FontWeight.w600,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final data =
                            _activityController.reoccuringModel.value.data ??
                            [];

                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: data.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8, // smaller cards
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final item = data[index];
                            final isSelected = selectedIndex.value == index;

                            return GestureDetector(
                              onTap: () {
                                selectedIndex.value = index;
                                _showScheduleModal(context, item.id ?? '');
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.blue.withOpacity(0.9)
                                      : AppColors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    item.title ?? '',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle().textInter(
                                      size: 14,
                                      color: AppColors.whiteColor,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
