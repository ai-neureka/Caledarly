import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/schedules/controller/schedules_controller.dart';
import 'package:apc_schedular/features/schedules/model/categories_model.dart';
import 'package:apc_schedular/features/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateSchdeuleScreen extends StatefulWidget {
  const CreateSchdeuleScreen({super.key});

  @override
  State<CreateSchdeuleScreen> createState() => _CreateSchdeuleScreenState();
}

TextEditingController titleController = TextEditingController();
final scheduleCats = Get.put(SchedulesController());
CatDatum? selectedCategory;
CatDatum? selectedCatID;
var initailPriority = 'Low';
List<String> priority = ['Low', 'Medium', 'High'];
TextEditingController descriptionController = TextEditingController();
DateTime? selectedStartDateTime;
DateTime? selectedEndDateTime;

class _CreateSchdeuleScreenState extends State<CreateSchdeuleScreen> {
  // Track if activity has been created
  String? createdActivityId;
  bool isActivityCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text(
          'Create a task or schedule',
          style: AppTextStyle().textInter(size: 22, weight: FontWeight.w600),
        ),
      ),
      body: Obx(
        () => scheduleCats.loadingCats.value
            ? Center(child: CircularProgressIndicator(color: AppColors.blue))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Title',
                        controller: titleController,
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 190,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textColor.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Description',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Category',
                        style: AppTextStyle().textInter(
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textColor.withValues(alpha: 0.2),
                          ),
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(16),
                        child: DropdownButton<CatDatum>(
                          isExpanded: true,
                          isDense: true,
                          underline: const SizedBox(),
                          value: selectedCategory,
                          hint: const Text("Select Schedule Category"),
                          items: scheduleCats.loadedCats.value.data!
                              .map<DropdownMenuItem<CatDatum>>((cat) {
                                return DropdownMenuItem<CatDatum>(
                                  value: cat,
                                  child: Text(cat.name ?? ''),
                                );
                              })
                              .toList(),
                          onChanged: (CatDatum? val) {
                            setState(() {
                              selectedCategory = val;
                              selectedCatID = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Priority Level',
                        style: AppTextStyle().textInter(
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textColor.withValues(alpha: 0.2),
                          ),
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: initailPriority,
                          items: priority
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? val) {
                            setState(() {
                              if (val != null) initailPriority = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 40),

                      // Show Continue button only if activity is NOT created
                      if (!isActivityCreated)
                        Obx(
                          () => CustomButtonWidget(
                            btnText: 'Continue',
                            onPressed: () async {
                              // Validate inputs
                              if (titleController.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a title',
                                  backgroundColor: AppColors.blue,
                                  colorText: AppColors.whiteColor,
                                );
                                return;
                              }
                              if (selectedCatID == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please select a category',
                                );
                                return;
                              }

                              // Create activity
                              var result = await scheduleCats
                                  .createActivityController(
                                    titleController.text,
                                    descriptionController.text,
                                    selectedCatID?.id,
                                    initailPriority,
                                  );

                              // Check if activity was created successfully
                              if (result != null && result['success'] == true) {
                                setState(() {
                                  createdActivityId = result['data']['_id'];
                                  isActivityCreated = true;
                                });
                                Get.snackbar(
                                  'Success',
                                  'Activity created! Now set the start and end time.',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to create activity',
                                );
                              }
                            },
                            isLoading: scheduleCats.creatingActivity.value,
                          ),
                        ),

                      // Show Start and End time fields only after activity is created
                      if (isActivityCreated) ...[
                        SizedBox(height: 20),
                        Text(
                          'Start',
                          style: AppTextStyle().textInter(
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            DateTime temp =
                                selectedStartDateTime ?? DateTime.now();
                            final DateTime? picked =
                                await showCupertinoModalPopup<DateTime>(
                                  context: context,
                                  builder: (ctx) => Container(
                                    height: 300,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 220,
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode
                                                .dateAndTime,
                                            initialDateTime:
                                                selectedStartDateTime ??
                                                DateTime.now(),
                                            use24hFormat: false,
                                            onDateTimeChanged: (val) =>
                                                temp = val,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              child: Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                            ),
                                            CupertinoButton(
                                              child: Text('Done'),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(temp),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                            if (picked != null) {
                              setState(() {
                                selectedStartDateTime = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              selectedStartDateTime != null
                                  ? selectedStartDateTime!
                                        .toLocal()
                                        .toString()
                                        .split('.')
                                        .first
                                  : 'Select start date & time',
                              style: AppTextStyle().textInter(size: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'End',
                          style: AppTextStyle().textInter(
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            DateTime temp =
                                selectedEndDateTime ?? DateTime.now();
                            final DateTime? picked =
                                await showCupertinoModalPopup<DateTime>(
                                  context: context,
                                  builder: (ctx) => Container(
                                    height: 300,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 220,
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode
                                                .dateAndTime,
                                            initialDateTime:
                                                selectedEndDateTime ??
                                                DateTime.now(),
                                            use24hFormat: false,
                                            onDateTimeChanged: (val) =>
                                                temp = val,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              child: Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                            ),
                                            CupertinoButton(
                                              child: Text('Done'),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(temp),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                            if (picked != null) {
                              setState(() {
                                selectedEndDateTime = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              selectedEndDateTime != null
                                  ? selectedEndDateTime!
                                        .toLocal()
                                        .toString()
                                        .split('.')
                                        .first
                                  : 'Select end date & time',
                              style: AppTextStyle().textInter(size: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Obx(
                          () => CustomButtonWidget(
                            btnText: 'Create Activity Instance',
                            onPressed: () async {
                              // Validate times
                              if (selectedStartDateTime == null ||
                                  selectedEndDateTime == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please select both start and end times',
                                );
                                return;
                              }
                              if (selectedEndDateTime!.isBefore(
                                selectedStartDateTime!,
                              )) {
                                Get.snackbar(
                                  'Error',
                                  'End time must be after start time',
                                );
                                return;
                              }

                              // Create activity instance
                              var result = await scheduleCats
                                  .createActivityInstanceController(
                                    createdActivityId,
                                    selectedStartDateTime!.toIso8601String(),
                                    selectedEndDateTime!.toIso8601String(),
                                  );

                              if (result != null && result['success'] == true) {
                                Get.snackbar(
                                  'Success',
                                  'Activity instance created successfully!',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                // Navigate back or to schedule list
                                Navigator.pop(context);
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to create activity instance',
                                );
                              }
                            },
                            isLoading:
                                scheduleCats.createActivityInstance.value,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.blackColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.blackColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.blackColor, width: 2),
        ),
      ),
    );
  }
}
