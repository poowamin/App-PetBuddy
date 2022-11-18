import '../utils.dart';

class MessageField {
  static const String createdAt = 'createdAt';
}

class Message {
  final String user_id;
  final String username;
  final String message;
  final String type;
  final String time;
  final String day;
  final String seen;
  final DateTime createdAt;

  const Message({
    required this.user_id,
    required this.username,
    required this.message,
    required this.type,
    required this.time,
    required this.day,
    required this.seen,
    required this.createdAt,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
        user_id: json['user_id'],
        username: json['username'],
        message: json['message'],
        type: json['type'],
        time: json['time'],
        day: json['day'],
        seen: json['seen'],
        createdAt: Utils.toDateTime(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'username': username,
        'message': message,
        'type': type,
        'time': time,
        'day': day,
        'seen': seen,
        'createdAt': Utils.fromDateTimeToJson(createdAt),
      };
}
