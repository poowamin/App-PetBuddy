import 'package:cloud_firestore/cloud_firestore.dart';

class CommentField {
  static const createdTime = 'time';
}

class Comment {
  String comment;
  String comment_id;
  Timestamp time;
  int like;
  String pet_id;
  double rating;
  String user_id;
  //String user;
  List who_like;

  Comment({
    required this.comment,
    required this.comment_id,
    required this.time,
    required this.like,
    required this.pet_id,
    required this.rating,
    required this.user_id,
    required this.who_like,
  });

  static Comment fromJson(Map<String, dynamic> json) => Comment(
        comment: json['comment'],
        comment_id: json['comment_id'],
        time: json['time'],
        like: json['like'],
        pet_id: json['pet_id'],
        rating: json['rating'],
        user_id: json['user_id'],
        who_like: json['who_like'],
      );

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'comment_id': comment_id,
        'time': time,
        'like': like,
        'pet_id': pet_id,
        'rating': rating,
        'user_id': user_id,
        'who_like': who_like,
      };
}
