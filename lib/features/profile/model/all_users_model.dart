// To parse this JSON data, do
//
//     final allUsersModel = allUsersModelFromJson(jsonString);

import 'dart:convert';

AllUsersModel allUsersModelFromJson(String str) =>
    AllUsersModel.fromJson(json.decode(str));

String allUsersModelToJson(AllUsersModel data) => json.encode(data.toJson());

class AllUsersModel {
  bool? success;
  List<Datum>? data;
  Pagination? pagination;

  AllUsersModel({this.success, this.data, this.pagination});

  factory AllUsersModel.fromJson(Map<String, dynamic> json) => AllUsersModel(
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
  String? username;
  String? email;
  String? role;
  bool? isActive;
  DateTime? createdAt;
  int? v;

  Datum({
    this.id,
    this.username,
    this.email,
    this.role,
    this.isActive,
    this.createdAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
