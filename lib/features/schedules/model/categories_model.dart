// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

CategoryModel categoryModelFromJson(String str) =>
    CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
  bool? success;
  List<CatDatum>? data;
  Pagination? pagination;

  CategoryModel({this.success, this.data, this.pagination});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    success: json["success"],
    data: json["data"] == null
        ? []
        : List<CatDatum>.from(json["data"]!.map((x) => CatDatum.fromJson(x))),
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

class CatDatum {
  String? id;
  String? name;
  String? description;
  CreatedBy? createdBy;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  CatDatum({
    this.id,
    this.name,
    this.description,
    this.createdBy,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CatDatum.fromJson(Map<String, dynamic> json) => CatDatum(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    createdBy: json["created_by"] == null
        ? null
        : CreatedBy.fromJson(json["created_by"]),
    isActive: json["is_active"],
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
    "name": name,
    "description": description,
    "created_by": createdBy?.toJson(),
    "is_active": isActive,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
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
