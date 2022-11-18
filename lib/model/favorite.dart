import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteField {
  static const createdTime = 'time';
}

class Favorite {
  String favorite_id;
  String pet_id;
  String user_id;
  Timestamp time;

  Favorite({
    required this.favorite_id,
    required this.pet_id,
    required this.user_id,
    required this.time,
  });

  static Favorite fromJson(Map<String, dynamic> json) => Favorite(
        favorite_id: json['favorite_id'],
        pet_id: json['pet_id'],
        user_id: json['user_id'],
        time: json['time'],
      );

  Map<String, dynamic> toJson() => {
        'favorite_id': favorite_id,
        'pet_id': pet_id,
        'user_id': user_id,
        'time': time,
      };
}
