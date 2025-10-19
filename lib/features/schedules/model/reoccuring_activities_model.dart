// To parse this JSON data, do
//
//     final reoccuringActivitiesModel = reoccuringActivitiesModelFromJson(jsonString);

import 'dart:convert';

ReoccuringActivitiesModel reoccuringActivitiesModelFromJson(String str) => ReoccuringActivitiesModel.fromJson(json.decode(str));

String reoccuringActivitiesModelToJson(ReoccuringActivitiesModel data) => json.encode(data.toJson());

class ReoccuringActivitiesModel {
    bool? success;
    List<Datum>? data;
    Pagination? pagination;

    ReoccuringActivitiesModel({
        this.success,
        this.data,
        this.pagination,
    });

    factory ReoccuringActivitiesModel.fromJson(Map<String, dynamic> json) => ReoccuringActivitiesModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
    };
}

class Datum {
    String? id;
    String? title;
    String? description;
    CreatedBy? createdBy;
    CreatedBy? focalPerson;
    CategoryId? categoryId;
    PriorityLevel? priorityLevel;
    int? duration;
    Status? status;
    DateTime? createdAt;
    int? v;

    Datum({
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

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        title: json["title"],
        description: json["description"],
        createdBy: json["created_by"] == null ? null : CreatedBy.fromJson(json["created_by"]),
        focalPerson: json["focal_person"] == null ? null : CreatedBy.fromJson(json["focal_person"]),
        categoryId: json["category_id"] == null ? null : CategoryId.fromJson(json["category_id"]),
        priorityLevel: priorityLevelValues.map[json["priority_level"]]!,
        duration: json["duration"],
        status: statusValues.map[json["status"]]!,
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "created_by": createdBy?.toJson(),
        "focal_person": focalPerson?.toJson(),
        "category_id": categoryId?.toJson(),
        "priority_level": priorityLevelValues.reverse[priorityLevel],
        "duration": duration,
        "status": statusValues.reverse[status],
        "created_at": createdAt?.toIso8601String(),
        "__v": v,
    };
}

class CategoryId {
    CategoryIdId? id;
    Name? name;

    CategoryId({
        this.id,
        this.name,
    });

    factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
        id: categoryIdIdValues.map[json["_id"]]!,
        name: nameValues.map[json["name"]]!,
    );

    Map<String, dynamic> toJson() => {
        "_id": categoryIdIdValues.reverse[id],
        "name": nameValues.reverse[name],
    };
}

enum CategoryIdId {
    THE_68_C028651276_FBDB9_D7_DF69_F
}

final categoryIdIdValues = EnumValues({
    "68c028651276fbdb9d7df69f": CategoryIdId.THE_68_C028651276_FBDB9_D7_DF69_F
});

enum Name {
    MEETNG
}

final nameValues = EnumValues({
    "Meetng": Name.MEETNG
});

class CreatedBy {
    CreatedById? id;
    Username? username;
    Email? email;

    CreatedBy({
        this.id,
        this.username,
        this.email,
    });

    factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: createdByIdValues.map[json["_id"]]!,
        username: usernameValues.map[json["username"]]!,
        email: emailValues.map[json["email"]]!,
    );

    Map<String, dynamic> toJson() => {
        "_id": createdByIdValues.reverse[id],
        "username": usernameValues.reverse[username],
        "email": emailValues.reverse[email],
    };
}

enum Email {
    ITSIRPRAISE_GMAIL_COM,
    TALK2_KAYCEENOW_GMAIL_COM,
    TEST_EXAMPLE_COM
}

final emailValues = EnumValues({
    "itsirpraise@gmail.com": Email.ITSIRPRAISE_GMAIL_COM,
    "talk2kayceenow@gmail.com": Email.TALK2_KAYCEENOW_GMAIL_COM,
    "test@example.com": Email.TEST_EXAMPLE_COM
});

enum CreatedById {
    THE_68_BE62_A082684_BFEA9_E54_BA9,
    THE_68_BE631982684_BFEA9_E54_BAC,
    THE_68_C5_D678_C78_E4303151566_C1
}

final createdByIdValues = EnumValues({
    "68be62a082684bfea9e54ba9": CreatedById.THE_68_BE62_A082684_BFEA9_E54_BA9,
    "68be631982684bfea9e54bac": CreatedById.THE_68_BE631982684_BFEA9_E54_BAC,
    "68c5d678c78e4303151566c1": CreatedById.THE_68_C5_D678_C78_E4303151566_C1
});

enum Username {
    GANDALF,
    KAYCEEMANI,
    TESTUSER
}

final usernameValues = EnumValues({
    "Gandalf": Username.GANDALF,
    "kayceemani": Username.KAYCEEMANI,
    "testuser": Username.TESTUSER
});

enum PriorityLevel {
    LOW,
    MEDIUM
}

final priorityLevelValues = EnumValues({
    "Low": PriorityLevel.LOW,
    "Medium": PriorityLevel.MEDIUM
});

enum Status {
    SCHEDULED
}

final statusValues = EnumValues({
    "Scheduled": Status.SCHEDULED
});

class Pagination {
    int? page;
    int? limit;
    int? total;
    int? pages;

    Pagination({
        this.page,
        this.limit,
        this.total,
        this.pages,
    });

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
