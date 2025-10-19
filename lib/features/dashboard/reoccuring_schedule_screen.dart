import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ReoccuringScheduleScreen extends StatefulWidget {
  const ReoccuringScheduleScreen({super.key});

  @override
  State<ReoccuringScheduleScreen> createState() =>
      _ReoccuringScheduleScreenState();
}

final _activityController = Get.put(SchedulesController());

class _ReoccuringScheduleScreenState extends State<ReoccuringScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(children: [

    ],),
    );
  }
}
