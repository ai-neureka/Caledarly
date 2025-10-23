import 'dart:convert';
import 'dart:developer';

import 'package:apc_schedular/constants/api.dart';
import 'package:apc_schedular/constants/app_colors.dart';
import 'package:apc_schedular/constants/http_service.dart';
import 'package:apc_schedular/features/schedules/model/all_activitie.dart';
import 'package:apc_schedular/features/schedules/model/all_activity_instances_model.dart';
import 'package:apc_schedular/features/schedules/model/categories_model.dart';
import 'package:apc_schedular/features/schedules/model/reoccuring_activities_model.dart';
import 'package:apc_schedular/features/schedules/model/schedule_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SchedulesController extends GetxController {
  RxBool loadingCats = RxBool(false);
  var loadedCats = CategoryModel().obs;
  // var loadedActivities = AllScheduleModel().obs;
  var loadedDetails = ScheduleDetailModel().obs;
  var reoccuringModel = ReoccuringActivitiesModel().obs;
  var loadedActivities = AllActivityInstancesModel().obs;

  RxBool creatingActivity = RxBool(false);
  RxBool createActivityInstance = RxBool(false);
  RxBool loadingAllActivities = RxBool(false);
  RxBool getting = RxBool(false);
  RxBool loadProfile = RxBool(false);
  RxBool loadingReoccuring = RxBool(false);
  RxBool editingActivityInstance = RxBool(false);
  RxBool deletingActivity = RxBool(false);
  RxBool sendingEmail = RxBool(false);
    List mails = [];

  //REPOSITORIES
  Future getCategoryRepo() async {
    final response = await BaseHttpClient().get(ApiRoutes.getCategory);
    return jsonEncode(response);
  }

  Future createActivityRepo(title, desc, catId, priorityLvl) async {
    final response = await BaseHttpClient().post(
      ApiRoutes.createActivity,
      body: {
        "title": title,
        "description": desc,
        "focal_person": "68be62a082684bfea9e54ba9",
        "category_id": catId,
        "priority_level": priorityLvl,
        "duration": 2,
      },
    );
    return response;
  }

  Future createActivityInstanceRepo(activityId, startTime, endTime) async {
    final response = await BaseHttpClient().post(
      ApiRoutes.createActivityInstance,
      body: {
        "activity_id": activityId,
        "start_time": startTime,
        "end_time": endTime,
      },
    );
    return response;
  }

  Future editActivityInstanceRepo(activityId, startTime, endTime) async {
    final response = await BaseHttpClient.instance.put(
      '${ApiRoutes.createActivityInstance}/$activityId',
      body: {
        "activity_id": activityId,
        "start_time": startTime,
        "end_time": endTime,
      },
    );
    return response;
  }

  Future deleteActivityInstance(activityId) async {
    final response = await BaseHttpClient.instance.delete(
      '${ApiRoutes.deleteActivity}/$activityId',
    );
    return response;
  }

  Future getAllUserActivitiesRepo() async {
    final response = await BaseHttpClient().get(ApiRoutes.getUserActivity);
    return jsonEncode(response);
  }

  Future getActivityDetailRepo(id) async {
    final response = await BaseHttpClient.instance.get(
      '${ApiRoutes.activityDetail}$id',
    );
    return jsonEncode(response);
  }

  Future getAllReocccuringActivitiesRepo() async {
    final response = await BaseHttpClient.instance.get(
      ApiRoutes.createActivity,
    );
    return jsonEncode(response);
  }

  Future sendEmailRepo(List reciepients, subject, text) async {
    final response = await BaseHttpClient.instance.post(
      ApiRoutes.sendEmail,
      body: {
        "recipients": reciepients,
        "subject": subject,
        "text": text,
        "html": "<p>This is a <strong>message</strong> for all users.</p>",
        "category": "Newsletter",
      },
    );
    return response;
  }

  //CONTROLLERS
  @override
  onInit() async {
    getCatController();
    getReoccuringActivitiesController();
    super.onInit();
  }

  Future getCatController() async {
    try {
      loadingCats(true);
      var result = await getCategoryRepo();
      loadingCats(false);
      loadedCats.value = categoryModelFromJson(result);
    } catch (e) {
      loadingCats(false);
    }
  }

  Future getReoccuringActivitiesController() async {
    try {
      loadingReoccuring(true);
      var result = await getAllReocccuringActivitiesRepo();
      loadingReoccuring(false);
      log(result);
      reoccuringModel.value = reoccuringActivitiesModelFromJson(result);
    } catch (e) {
      loadingReoccuring(false);
    }
  }

  // Future createActivityController(title, desc, catId, priorityLvl) async {
  //   try {
  //     creatingActivity(true);
  //     var result = await createActivityRepo(title, desc, catId, priorityLvl);
  //     creatingActivity(false);
  //     return result;
  //   } catch (e) {
  //     creatingActivity(false);
  //     var err = jsonEncode(e);
  //     Get.snackbar(
  //       'OPPSS',
  //       err,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: AppColors.blue,
  //       colorText: AppColors.whiteColor,
  //     );
  //     rethrow;
  //   }
  // }
  Future createActivityController(title, desc, catId, priorityLvl) async {
    try {
      creatingActivity(true);
      var result = await createActivityRepo(title, desc, catId, priorityLvl);
      creatingActivity(false);
      return result;
    } catch (e) {
      creatingActivity(false);

      // Extract the error message properly
      String errorMessage = 'An error occurred';
      String errorTitle = 'OOPS';

      if (e is ApiException) {
        errorMessage = e.message ?? 'API error occurred';

        // Handle specific status codes
        if (e.statusCode == 403) {
          errorTitle = 'Access Denied';
          errorMessage =
              e.message ?? 'You don\'t have permission to perform this action';
        } else if (e.statusCode == 401) {
          errorTitle = 'Unauthorized';
          errorMessage = 'Please login again';
        }
      } else if (e is http.Response) {
        // Handle http.Response errors
        final statusCode = e.statusCode;

        try {
          final responseBody = jsonDecode(e.body);
          if (responseBody is Map && responseBody['message'] != null) {
            errorMessage = responseBody['message'];
          }
        } catch (_) {
          errorMessage = e.body;
        }

        if (statusCode == 403) {
          errorTitle = 'Access Denied';
        } else if (statusCode == 401) {
          errorTitle = 'Unauthorized';
        }
      } else if (e is http.ClientException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        errorTitle,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: errorTitle == 'Access Denied'
            ? Colors.red
            : AppColors.blue,
        colorText: AppColors.whiteColor,
        duration: Duration(seconds: 3),
      );

      rethrow;
    }
  }

  Future createActivityInstanceController(
    activityId,
    startTime,
    endTime,
  ) async {
    try {
      createActivityInstance(true);
      var result = await createActivityInstanceRepo(
        activityId,
        startTime,
        endTime,
      );
      createActivityInstance(false);
      getAllUserActivitiesRepo();
      return result;
    } catch (e) {
      createActivityInstance(false);
      rethrow;
    }
  }

  Future getAllUserActivitiesController() async {
    try {
      loadingAllActivities(true);
      var result = await getAllUserActivitiesRepo();
      loadingAllActivities(false);
      log(result);
      loadedActivities.value = allActivityInstancesModelFromJson(result);
    } catch (e) {
      loadingAllActivities(false);
      rethrow;
    }
  }

  Future getActivityDetailController(id) async {
    try {
      getting(true);
      var result = await getActivityDetailRepo(id);
      getting(false);
      loadedDetails.value = scheduleDetailModelFromJson(result);
    } catch (e) {
      getting(false);
    }
  }

  Future editingActivityInstanceController(
    activityId,
    startTime,
    endTime,
  ) async {
    try {
      editingActivityInstance(true);
      await editActivityInstanceRepo(activityId, startTime, endTime);
      editingActivityInstance(false);
      Get.snackbar(
        'Success',
        'Update succesful',
        backgroundColor: AppColors.blue,
        colorText: AppColors.whiteColor,
      );
    } catch (e) {
      editingActivityInstance(false);
      Get.snackbar(
        'Opps',
        e.toString(),
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  Future deleteActivityInstanceController(id) async {
    try {
      deletingActivity(true);
      await deleteActivityInstance(id);
      deletingActivity(false);
      Get.snackbar(
        'Success',
        'succesful',
        backgroundColor: AppColors.blue,
        colorText: AppColors.whiteColor,
      );
      getAllUserActivitiesController();
    } catch (e) {
      deletingActivity(false);
      Get.snackbar(
        'Opps',
        e.toString(),
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  Future sendEmailController(reciepients, subject, text) async {
    try {
      sendingEmail(true);
      await sendEmailRepo(reciepients, subject, text);
      sendingEmail(false);
    } catch (e) {
      sendingEmail(false);
      print(e);
      Get.snackbar('Opps', '$e');
    }
  }
}
