

class BookQr {
  bool? success;
  Data? data;
  String? message;

  BookQr({
    this.success,
    this.data,
    this.message,
  });

  factory BookQr.fromJson(Map<String, dynamic> json) => BookQr(
    success: json["success"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data!.toJson(),
    "message": message,
  };
}

class Data {
  int? subsId;
  int? userId;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.subsId,
    this.userId,
    this.startDate,
    this.endDate,
    this.status,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    subsId: json["subs_id"],
    userId: json["user_id"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    status: json["status"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "subs_id": subsId,
    "user_id": userId,
    "start_date": startDate!.toIso8601String(),
    "end_date": endDate!.toIso8601String(),
    "status": status,
    "updated_at": updatedAt!.toIso8601String(),
    "created_at": createdAt!.toIso8601String(),
    "id": id,
  };
}
