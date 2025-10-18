import 'dart:convert';

import 'package:apc_schedular/constants/api.dart';
import 'package:apc_schedular/constants/http_service.dart';
import 'package:apc_schedular/features/profile/model/all_users_model.dart';
import 'package:apc_schedular/features/profile/model/profile_model.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  RxBool loadProfile = RxBool(false);
  RxBool loadingAllUsers = RxBool(false);
  var loadedProfile = UserProfileModel().obs;
  var loadedUsers = AllUsersModel().obs;

  //REPOSITORIES
  Future getProfileRepo() async {
    final response = await BaseHttpClient().get(ApiRoutes.getProfile);
    return jsonEncode(response);
  }

  Future getAllUsersRepo() async {
    final response = await BaseHttpClient.instance.get(ApiRoutes.allUsers);
    return jsonEncode(response);
  }

  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  //CONTROLLERS
  getUserProfile() async {
    try {
      loadProfile.value = true;
      final response = await getProfileRepo();
      loadedProfile.value = userProfileModelFromJson(response);
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      loadProfile.value = false;
    }
  }

  Future getAllUsers() async {
    try {
      loadingAllUsers(true);
      var result = await getAllUsersRepo();
      loadingAllUsers(false);
      loadedUsers.value = allUsersModelFromJson(result);
    } catch (e) {
      loadingAllUsers(false);
    }
  }
}
