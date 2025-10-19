import 'dart:convert';
import 'dart:developer';

import 'package:apc_schedular/constants/api.dart';
import 'package:apc_schedular/constants/http_service.dart';
import 'package:apc_schedular/features/schedules/model/all_activitie.dart';
import 'package:apc_schedular/features/schedules/model/categories_model.dart';
import 'package:apc_schedular/features/schedules/model/reoccuring_activities_model.dart';
import 'package:apc_schedular/features/schedules/model/schedule_detail_model.dart';
import 'package:get/get.dart';

class SchedulesController extends GetxController {
  RxBool loadingCats = RxBool(false);
  var loadedCats = CategoryModel().obs;
  var loadedActivities = AllScheduleModel().obs;
  var loadedDetails = ScheduleDetailModel().obs;
  var reoccuringModel = ReoccuringActivitiesModel().obs;
  var loadedReoccuringActivities = RxBool(false);

  RxBool creatingActivity = RxBool(false);
  RxBool createActivityInstance = RxBool(false);
  RxBool loadingAllActivities = RxBool(false);
  RxBool getting = RxBool(false);
  RxBool loadProfile = RxBool(false);
  RxBool loadingReoccuring = RxBool(false);

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
      ApiRoutes.getUserActivity,
    );
    return jsonEncode(response);
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
      reoccuringModel.value = reoccuringActivitiesModelFromJson(result);
    } catch (e) {
      loadingReoccuring(false);
    }
  }

  Future createActivityController(title, desc, catId, priorityLvl) async {
    try {
      creatingActivity(true);
      var result = await createActivityRepo(title, desc, catId, priorityLvl);
      creatingActivity(false);
      return result;
    } catch (e) {
      creatingActivity(false);
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
      loadedActivities.value = allScheduleModelFromJson(result);
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
}
