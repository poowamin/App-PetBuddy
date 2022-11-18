class ChatLinkField {
  static const createdTime = 'createdTime';
}

class ChatLink {
  final String id;
  final String receiver_id;
  final String sender_id;
  final String message;
  final int unseen;
  final String type;
  final String time;
  final String day;

  const ChatLink({
    required this.id,
    required this.receiver_id,
    required this.sender_id,
    required this.message,
    required this.unseen,
    required this.type,
    required this.time,
    required this.day,
  });

  static ChatLink fromJson(Map<String, dynamic> json) => ChatLink(
        id: json['id'],
        receiver_id: json['receiver_id'],
        sender_id: json['sender_id'],
        message: json['message'],
        unseen: json['unseen'],
        type: json['type'],
        time: json['time'],
        day: json['day'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'receiver_id': receiver_id,
        'sender_id': sender_id,
        'message': message,
        'unseen': unseen,
        'type': type,
        'time': time,
        'day': day,
      };
}
