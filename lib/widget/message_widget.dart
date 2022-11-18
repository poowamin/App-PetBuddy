import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/message.dart';
import 'package:pet_buddy/screen/full_image.dart';
import 'package:pet_buddy/utils.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageWidget({super.key, 
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final today = Utils.getDateThai();
    const radius = Radius.circular(12);
    const borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          FutureBuilder<String>(
            // กำหนดชนิดข้อมูล
            future: CloudFirestoreApi.getPhotoFromUserId(
              message.user_id,
            ), // ข้อมูล Future

            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data == ''
                    ? CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 16,
                            child: Text(
                              message.username.substring(0, 1),
                              style: GoogleFonts.kanit(
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                            )),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                            radius: 16,
                            child: Text(
                              message.username.substring(0, 1),
                              style: GoogleFonts.kanit(
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                            )),
                      )
                    : CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(snapshot.data!)),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                            radius: 16,
                            child: Text(
                              message.username.substring(0, 1),
                              style: GoogleFonts.kanit(
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                            )),
                      );
              } else if (snapshot.hasError) {
                return const Text('');
              }

              return const CircularProgressIndicator();
            },
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(4),
              constraints: const BoxConstraints(maxWidth: 140),
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[100] : Theme.of(context).accentColor,
                borderRadius: isMe
                    ? borderRadius
                        .subtract(const BorderRadius.only(bottomRight: radius))
                    : borderRadius
                        .subtract(const BorderRadius.only(bottomLeft: radius)),
              ),
              child: buildMessage(context),
            ),
            Container(
              margin: const EdgeInsets.only(left: 9),
              child: Text(
                message.day == today ? message.time : message.day,
                style: GoogleFonts.kanit(
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget buildMessage(BuildContext context) => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          message.type == 'text'
              ? Text(
                  message.message,
                  style: GoogleFonts.kanit(
                    textStyle:
                        TextStyle(color: isMe ? Colors.black : Colors.white),
                  ),
                  textAlign: isMe ? TextAlign.end : TextAlign.start,
                )
              : GestureDetector(
                  child: Image.network(
                    message.message,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImage(photo: message.message),
                    ),
                  ),
                )
        ],
      );
}
