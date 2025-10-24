import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/app_style.dart';
import 'package:apc_schedular/features/profile/controller/profile_controller.dart';
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
  String? createdActivityId;
  bool isActivityCreated = false;
  bool invitemembers = false;
  String? selectedType; // 'Task' or 'Meeting'

  // Check if selected category is a task
  bool get isTask => selectedCategory?.name?.toLowerCase() == 'task';

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
                              // Reset fields when category changes
                              if (isActivityCreated) {
                                selectedStartDateTime = null;
                                selectedEndDateTime = null;
                                scheduleCats.mails.clear();
                                invitemembers = false;
                              }
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
                                  isTask
                                      ? 'Activity created! Now assign to members.'
                                      : 'Activity created! Now set the start and end time.',
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

                      if (isActivityCreated) ...[
                        // Show time pickers only for NON-TASK categories (i.e., meetings)
                        if (!isTask) ...[
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
                        ],

                        // Member selection section
                        Row(
                          children: [
                            Checkbox(
                              value: invitemembers,
                              onChanged: (val) {
                                setState(() {
                                  invitemembers = val ?? false;
                                });
                                if (invitemembers) {
                                  Get.bottomSheet(
                                    MembersWidget(isTask: isTask),
                                    isScrollControlled: true,
                                  );
                                }
                              },
                            ),
                            Text(
                              isTask
                                  ? 'Assign members'
                                  : 'Invite member via email',
                              style: AppTextStyle().textInter(
                                size: 16,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        if (scheduleCats.mails.isNotEmpty ||
                            scheduleCats.selectedUserIds.isNotEmpty)
                          SizedBox(height: 20),

                        Obx(
                          () => CustomButtonWidget(
                            btnText: isTask
                                ? 'Create Task'
                                : 'Create Activity Instance',
                            onPressed: () async {
                              if (isTask) {
                                // Task creation flow
                                if (scheduleCats.selectedUserIds.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please assign at least one member',
                                  );
                                  return;
                                }

                                // Step 1: Create activity instance with default times
                                // Using current time as start and 1 hour later as end for tasks
                                final now = DateTime.now();
                                final oneHourLater = now.add(
                                  Duration(hours: 1),
                                );

                                var instanceResult = await scheduleCats
                                    .createActivityInstanceController(
                                      createdActivityId,
                                      now.toIso8601String(),
                                      oneHourLater.toIso8601String(),
                                    );

                                if (instanceResult == null ||
                                    instanceResult['success'] != true) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to create activity instance',
                                  );
                                  return;
                                }

                                // Step 2: Extract the instance ID from the response
                                final instanceId =
                                    instanceResult['data']['_id'];

                                if (instanceId == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to get instance ID',
                                  );
                                  return;
                                }

                                // Step 3: Create task with the instance ID
                                var taskResult = await scheduleCats
                                    .createTaskController(
                                      instanceId,
                                      scheduleCats.selectedUserIds.toList(),
                                      descriptionController.text,
                                    );

                                if (taskResult != null &&
                                    taskResult['success'] == true) {
                                  Get.snackbar(
                                    'Success',
                                    'Task created and assigned successfully!',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  Navigator.pop(context);
                                } else {}
                              } else {
                                // Meeting creation flow
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

                                var result = await scheduleCats
                                    .createActivityInstanceController(
                                      createdActivityId,
                                      selectedStartDateTime!.toIso8601String(),
                                      selectedEndDateTime!.toIso8601String(),
                                    );

                                // Send emails if members were invited
                                if (invitemembers &&
                                    scheduleCats.mails.isNotEmpty) {
                                  await scheduleCats.sendEmailController(
                                    scheduleCats.mails,
                                    titleController.text,
                                    descriptionController.text,
                                  );
                                }

                                if (result != null &&
                                    result['success'] == true) {
                                  Get.snackbar(
                                    'Success',
                                    'Activity instance created successfully!',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  Navigator.pop(context);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to create activity instance',
                                  );
                                }
                              }
                            },
                            isLoading: isTask
                                ? scheduleCats.creatingTask.value
                                : scheduleCats.createActivityInstance.value,
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

class MembersWidget extends StatefulWidget {
  final bool isTask;

  const MembersWidget({super.key, this.isTask = false});

  @override
  State<MembersWidget> createState() => _MembersWidgetState();
}

class _MembersWidgetState extends State<MembersWidget> {
  final _profileController = Get.put(ProfileController());
  final _scheduleController = Get.put(SchedulesController());
  final Set<String> tempSelectedEmails = {};
  final Set<String> tempSelectedUserIds = {};
  final TextEditingController _emailController = TextEditingController();
  final List<String> manualEmails = [];

  @override
  void initState() {
    super.initState();
    _profileController.getAllUsers();

    if (widget.isTask) {
      // For tasks, load selected user IDs
      tempSelectedUserIds.addAll(
        _scheduleController.selectedUserIds.map((e) => e.toString()),
      );
    } else {
      // For meetings, load selected emails
      tempSelectedEmails.addAll(
        _scheduleController.mails.map((e) => e.toString()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  void _addManualEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an email address',
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.black,
      );
      return;
    }

    final emailList = email
        .split(RegExp(r'[,;\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    int addedCount = 0;
    int invalidCount = 0;
    int duplicateCount = 0;

    for (final emailItem in emailList) {
      if (!_isValidEmail(emailItem)) {
        invalidCount++;
        continue;
      }

      if (manualEmails.contains(emailItem) ||
          tempSelectedEmails.contains(emailItem)) {
        duplicateCount++;
        continue;
      }

      setState(() {
        manualEmails.add(emailItem);
      });
      addedCount++;
    }

    _emailController.clear();

    if (addedCount > 0) {
      Get.snackbar(
        'Success',
        '$addedCount email(s) added',
        backgroundColor: Colors.green.withOpacity(0.2),
        colorText: Colors.black,
        duration: Duration(seconds: 2),
      );
    }

    if (invalidCount > 0) {
      Get.snackbar(
        'Warning',
        '$invalidCount invalid email(s) skipped',
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.black,
        duration: Duration(seconds: 2),
      );
    }

    if (duplicateCount > 0) {
      Get.snackbar(
        'Info',
        '$duplicateCount duplicate email(s) skipped',
        backgroundColor: Colors.blue.withOpacity(0.2),
        colorText: Colors.black,
        duration: Duration(seconds: 2),
      );
    }
  }

  void _removeManualEmail(String email) {
    setState(() {
      manualEmails.remove(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            widget.isTask ? 'Assign Members' : 'Add Members',
            style: AppTextStyle().textInter(size: 22, weight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          Text(
            widget.isTask
                ? 'Select members to assign this task'
                : 'Select members or add emails manually',
            style: AppTextStyle().textInter(
              size: 14,
              color: AppColors.textColor.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 16),

          // Show email input only for meetings, not tasks
          if (!widget.isTask) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.3),
                  ),
                ),
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppColors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Email Address',
                          style: AppTextStyle().textInter(
                            size: 15,
                            weight: FontWeight.w600,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Enter email(s), separate with commas',
                              hintStyle: TextStyle(fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.textColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.textColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.blue,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _addManualEmail(),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addManualEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Add',
                            style: AppTextStyle().textInter(
                              size: 14,
                              color: AppColors.whiteColor,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (manualEmails.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: manualEmails.map((email) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  email,
                                  style: AppTextStyle().textInter(
                                    size: 13,
                                    color: Colors.white,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _removeManualEmail(email),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.textColor.withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'OR SELECT FROM LIST',
                      style: AppTextStyle().textInter(
                        size: 12,
                        color: AppColors.textColor.withValues(alpha: 0.5),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.textColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],

          Expanded(
            child: Obx(
              () => _profileController.loadingAllUsers.value
                  ? Center(child: CircularProgressIndicator())
                  : _profileController.loadedUsers.value.data == null ||
                        _profileController.loadedUsers.value.data!.isEmpty
                  ? Center(
                      child: Text(
                        'No members available',
                        style: AppTextStyle().textInter(size: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          _profileController.loadedUsers.value.data!.length,
                      itemBuilder: (context, index) {
                        final user =
                            _profileController.loadedUsers.value.data![index];

                        final isSelected = widget.isTask
                            ? tempSelectedUserIds.contains(user.id)
                            : tempSelectedEmails.contains(user.email);

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.blue.withValues(alpha: 0.1)
                                : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.blue
                                  : AppColors.textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (widget.isTask) {
                                  // For tasks, store user IDs
                                  if (value == true) {
                                    tempSelectedUserIds.add(user.id ?? '');
                                  } else {
                                    tempSelectedUserIds.remove(user.id);
                                  }
                                } else {
                                  // For meetings, store emails
                                  if (value == true) {
                                    tempSelectedEmails.add(user.email ?? '');
                                  } else {
                                    tempSelectedEmails.remove(user.email);
                                  }
                                }
                              });
                            },
                            title: Text(
                              user.username ?? 'Unknown',
                              style: AppTextStyle().textInter(
                                size: 16,
                                weight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              user.email ?? '',
                              style: AppTextStyle().textInter(
                                size: 14,
                                color: AppColors.textColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            activeColor: AppColors.blue,
                          ),
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle().textInter(
                        size: 16,
                        color: AppColors.blue,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isTask) {
                        // For tasks, save user IDs
                        _scheduleController.selectedUserIds.clear();
                        _scheduleController.selectedUserIds.addAll(
                          tempSelectedUserIds,
                        );

                        Get.back();
                        Get.snackbar(
                          'Success',
                          '${tempSelectedUserIds.length} member(s) assigned',
                          backgroundColor: Colors.green.withOpacity(0.2),
                          colorText: Colors.black,
                        );
                      } else {
                        // For meetings, save emails (both selected and manual)
                        _scheduleController.mails.clear();
                        _scheduleController.mails.addAll(tempSelectedEmails);
                        _scheduleController.mails.addAll(manualEmails);

                        final totalEmails =
                            tempSelectedEmails.length + manualEmails.length;

                        Get.back();
                        Get.snackbar(
                          'Success',
                          '$totalEmails email(s) selected',
                          backgroundColor: Colors.green.withOpacity(0.2),
                          colorText: Colors.black,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.isTask
                          ? 'Done (${tempSelectedUserIds.length})'
                          : 'Done (${tempSelectedEmails.length + manualEmails.length})',
                      style: AppTextStyle().textInter(
                        size: 16,
                        color: AppColors.whiteColor,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
