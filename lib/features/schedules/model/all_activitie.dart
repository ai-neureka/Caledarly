// To parse this JSON data, do
//
//     final allScheduleModel = allScheduleModelFromJson(jsonString);

import 'dart:convert';

AllScheduleModel allScheduleModelFromJson(String str) =>
    AllScheduleModel.fromJson(json.decode(str));

String allScheduleModelToJson(AllScheduleModel data) =>
    json.encode(data.toJson());

class AllScheduleModel {
  bool? success;
  List<ScheduleDatum>? data;
  Pagination? pagination;

  AllScheduleModel({this.success, this.data, this.pagination});

  factory AllScheduleModel.fromJson(Map<String, dynamic> json) =>
      AllScheduleModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<ScheduleDatum>.from(json["data"]!.map((x) => ScheduleDatum.fromJson(x))),
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

class ScheduleDatum {
  String? id;
  String? title;
  String? description;
  CreatedBy? createdBy;
  CreatedBy? focalPerson;
  CategoryId? categoryId;
  String? priorityLevel;
  int? duration;
  String? status;
  DateTime? createdAt;
  int? v;

  ScheduleDatum({
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

  factory ScheduleDatum.fromJson(Map<String, dynamic> json) => ScheduleDatum(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    createdBy: json["created_by"] == null
        ? null
        : CreatedBy.fromJson(json["created_by"]),
    focalPerson: json["focal_person"] == null
        ? null
        : CreatedBy.fromJson(json["focal_person"]),
    categoryId: json["category_id"] == null
        ? null
        : CategoryId.fromJson(json["category_id"]),
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
    "created_by": createdBy?.toJson(),
    "focal_person": focalPerson?.toJson(),
    "category_id": categoryId?.toJson(),
    "priority_level": priorityLevel,
    "duration": duration,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "__v": v,
  };
}

class CategoryId {
  String? id;
  String? name;

  CategoryId({this.id, this.name});

  factory CategoryId.fromJson(Map<String, dynamic> json) =>
      CategoryId(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class CreatedBy {
  Id? id;
  Username? username;
  Email? email;

  CreatedBy({this.id, this.username, this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: idValues.map[json["_id"]]!,
    username: usernameValues.map[json["username"]]!,
    email: emailValues.map[json["email"]]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "username": usernameValues.reverse[username],
    "email": emailValues.reverse[email],
  };
}

enum Email { ITSIRPRAISE_GMAIL_COM, TEST_EXAMPLE_COM }

final emailValues = EnumValues({
  "itsirpraise@gmail.com": Email.ITSIRPRAISE_GMAIL_COM,
  "test@example.com": Email.TEST_EXAMPLE_COM,
});

enum Id { THE_68_BE62_A082684_BFEA9_E54_BA9, THE_68_C5_D678_C78_E4303151566_C1 }

final idValues = EnumValues({
  "68be62a082684bfea9e54ba9": Id.THE_68_BE62_A082684_BFEA9_E54_BA9,
  "68c5d678c78e4303151566c1": Id.THE_68_C5_D678_C78_E4303151566_C1,
});

enum Username { GANDALF, TESTUSER }

final usernameValues = EnumValues({
  "Gandalf": Username.GANDALF,
  "testuser": Username.TESTUSER,
});

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
