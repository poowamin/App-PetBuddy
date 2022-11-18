import 'package:cloud_firestore/cloud_firestore.dart';

class ReportField {
  static const String createdAt = 'time';
}

class Report {
  final String detail;
  final String report_id;
  final String photo;
  final String pet_id;
  final String pet_name;
  final Timestamp time;
  final String user_id;
  final String description;
  bool isCheck1;
  bool isCheck2;
  bool isCheck3;
  bool isCheck4;

  Report({
    required this.time,
    required this.detail,
    required this.photo,
    required this.pet_id,
    required this.pet_name,
    required this.report_id,
    required this.user_id,
    required this.description,
    this.isCheck1 = false,
    this.isCheck2 = false,
    this.isCheck3 = false,
    this.isCheck4 = false,
  });

  static Report fromJson(Map<String, dynamic> json) => Report(
        time: json['time'],
        detail: json['detail'],
        photo: json['photo'],
        pet_id: json['pet_id'],
        pet_name: json['pet_name'],
        report_id: json['report_id'],
        user_id: json['user_id'],
        description: json['description'],
        isCheck1: json['isCheck1'],
        isCheck2: json['isCheck2'],
        isCheck3: json['isCheck3'],
        isCheck4: json['isCheck4'],
      );

  Map<String, dynamic> toJson() => {
        'time': time,
        'detail': detail,
        'photo': photo,
        'pet_id': pet_id,
        'pet_name': pet_name,
        'report_id': report_id,
        'user_id': user_id,
        'description': description,
        'isCheck1': isCheck1,
        'isCheck2': isCheck2,
        'isCheck3': isCheck3,
        'isCheck4': isCheck4,
      };
}
