// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) =>
    UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) =>
    json.encode(data.toJson());

class UserProfileModel {
  bool? success;
  Data? data;

  UserProfileModel({this.success, this.data});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  User? user;

  Data({this.user});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(user: json["user"] == null ? null : User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"user": user?.toJson()};
}

class User {
  String? id;
  String? username;
  String? email;
  String? role;
  bool? isActive;
  DateTime? createdAt;
  int? v;

  User({
    this.id,
    this.username,
    this.email,
    this.role,
    this.isActive,
    this.createdAt,
    this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    username: json["username"],
    email: json["email"],
    role: json["role"],
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "email": email,
    "role": role,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}
