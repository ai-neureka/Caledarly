// To parse this JSON data, do
//
//     final allUsersModel = allUsersModelFromJson(jsonString);

import 'dart:convert';

AllUsersModel allUsersModelFromJson(String str) =>
    AllUsersModel.fromJson(json.decode(str));

String allUsersModelToJson(AllUsersModel data) => json.encode(data.toJson());

class AllUsersModel {
  bool? success;
  List<AllUsers>? data;
  Pagination? pagination;

  AllUsersModel({this.success, this.data, this.pagination});

  factory AllUsersModel.fromJson(Map<String, dynamic> json) => AllUsersModel(
    success: json["success"],
    data: json["data"] == null
        ? []
        : List<AllUsers>.from(json["data"]!.map((x) => AllUsers.fromJson(x))),
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

class AllUsers {
  String? id;
  String? username;
  String? email;
  Role? role;
  bool? isActive;
  DateTime? createdAt;
  int? v;

  AllUsers({
    this.id,
    this.username,
    this.email,
    this.role,
    this.isActive,
    this.createdAt,
    this.v,
  });

  factory AllUsers.fromJson(Map<String, dynamic> json) => AllUsers(
    id: json["_id"],
    username: json["username"],
    email: json["email"],
    role: roleValues.map[json["role"]]!,
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
    "role": roleValues.reverse[role],
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}

enum Role { ADMIN, USER }

final roleValues = EnumValues({"admin": Role.ADMIN, "user": Role.USER});

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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
