import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/chat_link.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/chat/chat_page.dart';
import 'package:pet_buddy/utils.dart';
import 'package:pet_buddy/widget/cached_image_user.dart';

class MyChatPage extends StatelessWidget {
  UserModel my_account;

  MyChatPage({
    Key? key,
    required this.my_account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          'การสนทนา',
          style: GoogleFonts.kanit(),
        )),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_link')
                  .where('user', arrayContains: my_account.user_id)
                  .orderBy(ChatLinkField.createdTime, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'เกิดข้อผิดพลาด กรุณาลองใหม่',
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                                fontSize: 24, color: Colors.black),
                          ),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text(
                        "ยังไม่มีข้อความแชท",
                        style: GoogleFonts.kanit(
                          textStyle: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ));
                    } else {
                      return ListView(
                        padding: const EdgeInsets.all(10),
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((doc) {
                          ChatLink chatLink = ChatLink(
                            id: doc.data().toString().contains('id')
                                ? doc.get('id')
                                : 0,
                            receiver_id:
                                doc.data().toString().contains('receiver_id')
                                    ? doc.get('receiver_id')
                                    : 0,
                            sender_id:
                                doc.data().toString().contains('sender_id')
                                    ? doc.get('sender_id')
                                    : 0,
                            message: doc.data().toString().contains('message')
                                ? doc.get('message')
                                : 0,
                            unseen: doc.data().toString().contains('unseen')
                                ? doc.get('unseen')
                                : 0,
                            type: doc.data().toString().contains('type')
                                ? doc.get('type')
                                : 0,
                            time: doc.data().toString().contains('time')
                                ? doc.get('time')
                                : 0,
                            day: doc.data().toString().contains('day')
                                ? doc.get('day')
                                : 0,
                          );

                          return chatLink.sender_id == my_account.user_id
                              ? chatLink.day != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: GestureDetector(
                                          onTap: () async {
                                            UserModel user =
                                                await CloudFirestoreApi
                                                    .getUserModelFromUserId(
                                                        chatLink.receiver_id);

                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  user: user,
                                                  my_account: my_account),
                                            ));
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 0),
                                              child: ListTile(
                                                  leading: SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: FutureBuilder<
                                                          UserModel>(
                                                        future: CloudFirestoreApi
                                                            .getUserModelFromUserId(
                                                          chatLink.receiver_id,
                                                        ),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    UserModel>
                                                                snapshot) {
                                                          return snapshot
                                                                      .data ==
                                                                  null
                                                              ? const Text('')
                                                              : CachedImageUser(
                                                                  radius: 25,
                                                                  user: snapshot
                                                                      .data!);
                                                        },
                                                      )),
                                                  title: FutureBuilder<String>(
                                                    future: CloudFirestoreApi
                                                        .getDataFromUserId(
                                                            chatLink
                                                                .receiver_id,
                                                            'name'),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      return snapshot.data ==
                                                              null
                                                          ? const Text('')
                                                          : Text(
                                                              '${snapshot.data}',
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            );
                                                    },
                                                  ),
                                                  subtitle:
                                                      chatLink.type == 'photo'
                                                          ? Text(
                                                              'You : Sent Photo',
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            )
                                                          : Text(
                                                              'You : ${chatLink.message}',
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            ),
                                                  trailing: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        Utils.getDateThai() ==
                                                                chatLink.day
                                                            ? chatLink.time
                                                            : chatLink.day,
                                                        style:
                                                            GoogleFonts.kanit(),
                                                      ),
                                                    ],
                                                  )))))
                                  : Container()
                              : chatLink.day != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: GestureDetector(
                                          onTap: () async {
                                            UserModel user =
                                                await CloudFirestoreApi
                                                    .getUserModelFromUserId(
                                                        chatLink.sender_id);

                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  user: user,
                                                  my_account: my_account),
                                            ));
                                          },
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 0),
                                              child: ListTile(
                                                  leading: SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: FutureBuilder<
                                                          UserModel>(
                                                        future: CloudFirestoreApi
                                                            .getUserModelFromUserId(
                                                          chatLink.sender_id,
                                                        ),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    UserModel>
                                                                snapshot) {
                                                          return snapshot
                                                                      .data ==
                                                                  null
                                                              ? const Text('')
                                                              : CachedImageUser(
                                                                  radius: 25,
                                                                  user: snapshot
                                                                      .data!);
                                                        },
                                                      )),
                                                  title: FutureBuilder<String>(
                                                    future: CloudFirestoreApi
                                                        .getDataFromUserId(
                                                            chatLink.sender_id,
                                                            'name'),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<String>
                                                            snapshot) {
                                                      return snapshot.data ==
                                                              null
                                                          ? const Text('')
                                                          : Text(
                                                              '${snapshot.data}',
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            );
                                                    },
                                                  ),
                                                  subtitle:
                                                      chatLink.type == 'photo'
                                                          ? Text(
                                                              'Sent Photo',
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            )
                                                          : Text(
                                                              chatLink.message,
                                                              style: GoogleFonts
                                                                  .kanit(),
                                                            ),
                                                  trailing: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        Utils.getDateThai() ==
                                                                chatLink.day
                                                            ? chatLink.time
                                                            : chatLink.day,
                                                        style:
                                                            GoogleFonts.kanit(),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      chatLink.unseen == 0
                                                          ? const Text('')
                                                          : snapshot.data ==
                                                                  null
                                                              ? const Text('')
                                                              : Expanded(
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(6),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                    child: Text(
                                                                      chatLink
                                                                          .unseen
                                                                          .toString(),
                                                                      style: GoogleFonts
                                                                          .kanit(
                                                                        textStyle:
                                                                            const TextStyle(color: Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                    ],
                                                  )))))
                                  : Container();
                        }).toList(),
                      );
                    }
                }
              },
            ))
          ],
        ));
  }
}
