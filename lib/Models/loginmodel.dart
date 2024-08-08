

class LoginModel {
  bool? success;
  Data? data;
  String? message;

  LoginModel({
    this.success,
    this.data,
    this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  int? id;
  dynamic name;
  dynamic email;
  dynamic emailVerifiedAt;
  String? phone;
  dynamic presentAddress;
  dynamic permanentAddress;
  String? role;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? token;
  bool? userSubscription;
  List<SubscriptionList>? subscriptionList;
  List<Section>? subscriptionListSection;

  Data({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.presentAddress,
    this.permanentAddress,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.userSubscription,
    this.subscriptionList,
    this.subscriptionListSection,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    phone: json["phone"],
    presentAddress: json["present_address"],
    permanentAddress: json["permanent_address"],
    role: json["role"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    token: json["token"],
    userSubscription: json["user_subscription"],
    subscriptionList: json["subscription_list"] == null ? [] : List<SubscriptionList>.from(json["subscription_list"]!.map((x) => SubscriptionList.fromJson(x))),
    subscriptionListSection: json["subscription_list_section"] == null ? [] : List<Section>.from(json["subscription_list_section"]!.map((x) => Section.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "phone": phone,
    "present_address": presentAddress,
    "permanent_address": permanentAddress,
    "role": role,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "token": token,
    "user_subscription": userSubscription,
    "subscription_list": subscriptionList == null ? [] : List<dynamic>.from(subscriptionList!.map((x) => x.toJson())),
    "subscription_list_section": subscriptionListSection == null ? [] : List<dynamic>.from(subscriptionListSection!.map((x) => x.toJson())),
  };
}

class SubscriptionList {
  int? id;
  int? subsId;
  int? userId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  Subs? subs;

  SubscriptionList({
    this.id,
    this.subsId,
    this.userId,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.subs,
  });

  factory SubscriptionList.fromJson(Map<String, dynamic> json) => SubscriptionList(
    id: json["id"],
    subsId: json["subs_id"],
    userId: json["user_id"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    name: json["name"],
    subs: json["subs"] == null ? null : Subs.fromJson(json["subs"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "subs_id": subsId,
    "user_id": userId,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "name": name,
    "subs": subs?.toJson(),
  };
}

class Subs {
  int? id;
  int? sectionId;
  String? name;
  dynamic description;
  int? days;
  int? amount;
  int? active;
  dynamic createdAt;
  dynamic updatedAt;
  String? sectionName;
  Section? section;

  Subs({
    this.id,
    this.sectionId,
    this.name,
    this.description,
    this.days,
    this.amount,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.sectionName,
    this.section,
  });

  factory Subs.fromJson(Map<String, dynamic> json) => Subs(
    id: json["id"],
    sectionId: json["section_id"],
    name: json["name"],
    description: json["description"],
    days: json["days"],
    amount: json["amount"],
    active: json["active"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    sectionName: json["sectionName"],
    section: json["section"] == null ? null : Section.fromJson(json["section"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "section_id": sectionId,
    "name": name,
    "description": description,
    "days": days,
    "amount": amount,
    "active": active,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "sectionName": sectionName,
    "section": section?.toJson(),
  };
}

class Section {
  int? id;
  String? name;
  dynamic description;
  int? active;
  dynamic createdAt;
  dynamic updatedAt;

  Section({
    this.id,
    this.name,
    this.description,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    active: json["active"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "active": active,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

