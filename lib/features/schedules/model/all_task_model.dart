// To parse this JSON data, do
//
//     final userTaskResponseModel = userTaskResponseModelFromJson(jsonString);

import 'dart:convert';

UserTaskResponseModel userTaskResponseModelFromJson(String str) =>
    UserTaskResponseModel.fromJson(json.decode(str));

String userTaskResponseModelToJson(UserTaskResponseModel data) =>
    json.encode(data.toJson());

class UserTaskResponseModel {
  bool? success;
  List<Datum>? data;
  Pagination? pagination;

  UserTaskResponseModel({this.success, this.data, this.pagination});

  factory UserTaskResponseModel.fromJson(Map<String, dynamic> json) =>
      UserTaskResponseModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Datum {
  String? id;
  ActivityInstanceId? activityInstanceId;
  AssignedBy? userId;
  String? status;
  AssignedBy? assignedBy;
  String? notes;
  DateTime? assignedAt;
  DateTime? updatedAt;
  int? v;

  Datum({
    this.id,
    this.activityInstanceId,
    this.userId,
    this.status,
    this.assignedBy,
    this.notes,
    this.assignedAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    activityInstanceId: json["activity_instance_id"] == null
        ? null
        : ActivityInstanceId.fromJson(json["activity_instance_id"]),
    userId: json["user_id"] == null
        ? null
        : AssignedBy.fromJson(json["user_id"]),
    status: json["status"],
    assignedBy: json["assigned_by"] == null
        ? null
        : AssignedBy.fromJson(json["assigned_by"]),
    notes: json["notes"],
    assignedAt: json["assigned_at"] == null
        ? null
        : DateTime.parse(json["assigned_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "activity_instance_id": activityInstanceId?.toJson(),
    "user_id": userId?.toJson(),
    "status": status,
    "assigned_by": assignedBy?.toJson(),
    "notes": notes,
    "assigned_at": assignedAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ActivityInstanceId {
  String? id;
  String? activityId;
  DateTime? startTime;
  DateTime? endTime;
  String? status;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ActivityInstanceId({
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

  factory ActivityInstanceId.fromJson(Map<String, dynamic> json) =>
      ActivityInstanceId(
        id: json["_id"],
        activityId: json["activity_id"],
        startTime: json["start_time"] == null
            ? null
            : DateTime.parse(json["start_time"]),
        endTime: json["end_time"] == null
            ? null
            : DateTime.parse(json["end_time"]),
        status: json["status"],
        createdBy: json["created_by"],
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
    "activity_id": activityId,
    "start_time": startTime?.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
    "status": status,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class AssignedBy {
  String? id;
  String? username;
  String? email;

  AssignedBy({this.id, this.username, this.email});

  factory AssignedBy.fromJson(Map<String, dynamic> json) => AssignedBy(
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

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Pagination({this.page, this.limit, this.total, this.pages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    pages: json["pages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "total": total,
    "pages": pages,
  };
}
