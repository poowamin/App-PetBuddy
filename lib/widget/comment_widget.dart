import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/comment.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final UserModel my_account;

  const CommentWidget({
    Key? key,
    required this.comment,
    required this.my_account,
  }) : super(key: key);

  @override
  _CommentWidget createState() => _CommentWidget();
}

class _CommentWidget extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('user')
              .doc(widget.comment.user_id)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError ||
                (snapshot.hasData && !snapshot.data!.exists)) {
              return const Text("");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              final user = UserModel(
                user_id: data['user_id'],
                email: data['email'],
                name: data['name'],
                password: data['password'],
                tel: data['tel'],
                token: data['token'],
                type: data['type'],
                stay: data['stay'],
                photo: data['photo'],
                address: data['address'],
                age: data['age'],
                gender: data['gender'],
                idcard: data['idcard'],
                surname: data['surname'],
                province: data['province'],
                amphure: data['amphure'],
                district: data['district'],
              );

              return ListTile(
                onLongPress: () => deleteComment(context, widget.comment),
                leading: user.photo == ''
                    ? CircleAvatar(
                        radius: 25,
                        child: Text(
                          user.name.substring(0, 1),
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(fontSize: 25),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(user.photo),
                      ),
                title: Row(
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.kanit(
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.star,
                        color: Color.fromARGB(255, 201, 171, 5)),
                    Text(
                      ' (${widget.comment.rating}/5)',
                      style: GoogleFonts.kanit(),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.comment.comment,
                      style: GoogleFonts.kanit(),
                    ),
                    Row(
                      children: [
                        Text(
                          Utils.differenceTime(widget.comment.time.toDate()),
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        FutureBuilder<bool>(
                          future: CloudFirestoreApi.whoLikeComment(
                              widget.comment.comment_id,
                              widget.my_account.user_id),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // Map<String, dynamic> data =
                              //     snapshot.data! as Map<String, dynamic>;
                              bool like = snapshot.data!;

                              return Row(
                                children: [
                                  like
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 18,
                                        )
                                      : const Icon(
                                          Icons.favorite_outline,
                                          size: 18,
                                        ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  widget.comment.like == 0
                                      ? const Text('')
                                      : Text(
                                          widget.comment.like.toString(),
                                          style: GoogleFonts.kanit(
                                            textStyle:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  snapshot.data!
                                      ? GestureDetector(
                                          onTap: () async {
                                            widget.comment.who_like.removeWhere(
                                                (item) =>
                                                    item ==
                                                    widget.my_account.user_id);

                                            await FirebaseFirestore.instance
                                                .collection('comment')
                                                .doc(widget.comment.comment_id)
                                                .update({
                                              'like': widget.comment.like - 1,
                                              'who_like':
                                                  widget.comment.who_like
                                            });
                                          },
                                          child: Text(
                                            'ยกเลิก',
                                            style: GoogleFonts.kanit(
                                              textStyle:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            // widget.comment.who_like
                                            //     .add(widget.my_account.user_id);

                                            widget.comment.who_like
                                                .add(widget.my_account.user_id);
                                            await FirebaseFirestore.instance
                                                .collection('comment')
                                                .doc(widget.comment.comment_id)
                                                .update({
                                              'like': widget.comment.like + 1,
                                              'who_like':
                                                  widget.comment.who_like
                                            });
                                          },
                                          child: Text(
                                            'ถูกใจ',
                                            style: GoogleFonts.kanit(),
                                          ),
                                        ),
                                ],
                              );
                            }

                            return const Text("");
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const Text("");
          },
        ),
        const Divider()
      ],
    );
  }
}

Future deleteComment(BuildContext context, Comment comment) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '⭐ แจ้งเตือน',
          style: GoogleFonts.kanit(),
        ),
        content: Text(
          'คุณต้องการลบคอมเม้น ใช่หรือไม่?',
          style: GoogleFonts.kanit(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ไม่ใช่',
              style: GoogleFonts.kanit(),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await FirebaseFirestore.instance
                  .collection('zcomment')
                  .doc(comment.comment_id)
                  .delete()
                  .whenComplete(() => null);

              await CloudFirestoreApi.setAverageRating(comment.pet_id)
                  .whenComplete(() => print('Deleted Comment'));
            },
            child: Text(
              'ใช่',
              style: GoogleFonts.kanit(),
            ),
          ),
        ],
      );
    },
  );
}
