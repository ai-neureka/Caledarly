// To parse this JSON data, do
//
//     final scheduleDetailModel = scheduleDetailModelFromJson(jsonString);

import 'dart:convert';

ScheduleDetailModel scheduleDetailModelFromJson(String str) =>
    ScheduleDetailModel.fromJson(json.decode(str));

String scheduleDetailModelToJson(ScheduleDetailModel data) =>
    json.encode(data.toJson());

class ScheduleDetailModel {
  bool? success;
  Data? data;

  ScheduleDetailModel({this.success, this.data});

  factory ScheduleDetailModel.fromJson(Map<String, dynamic> json) =>
      ScheduleDetailModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  String? id;
  ActivityId? activityId;
  DateTime? startTime;
  DateTime? endTime;
  String? status;
  CreatedBy? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Data({
    this.id,
    this.activityId,
    this.startTime,
    this.endTime,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    activityId: json["activity_id"] == null
        ? null
        : ActivityId.fromJson(json["activity_id"]),
    startTime: json["start_time"] == null
        ? null
        : DateTime.parse(json["start_time"]),
    endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
    status: json["status"],
    createdBy: json["created_by"] == null
        ? null
        : CreatedBy.fromJson(json["created_by"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "activity_id": activityId?.toJson(),
    "start_time": startTime?.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
    "status": status,
    "created_by": createdBy?.toJson(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ActivityId {
  String? id;
  String? title;
  String? description;
  String? createdBy;
  String? focalPerson;
  String? categoryId;
  String? priorityLevel;
  int? duration;
  String? status;
  DateTime? createdAt;
  int? v;

  ActivityId({
    this.id,
    this.title,
    this.description,
    this.createdBy,
    this.focalPerson,
    this.categoryId,
    this.priorityLevel,
    this.duration,
    this.status,
    this.createdAt,
    this.v,
  });

  factory ActivityId.fromJson(Map<String, dynamic> json) => ActivityId(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    createdBy: json["created_by"],
    focalPerson: json["focal_person"],
    categoryId: json["category_id"],
    priorityLevel: json["priority_level"],
    duration: json["duration"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "created_by": createdBy,
    "focal_person": focalPerson,
    "category_id": categoryId,
    "priority_level": priorityLevel,
    "duration": duration,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "__v": v,
  };
}

class CreatedBy {
  String? id;
  String? username;
  String? email;

  CreatedBy({this.id, this.username, this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"],
    username: json["username"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "email": email,
  };
}
