import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pet_buddy/api/cloudfirestore_api.dart';

import 'package:pet_buddy/model/comment.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/direction/map_direction.dart';
import 'package:pet_buddy/screen/full_image.dart';
import 'package:pet_buddy/screen/report_add.dart';
import 'package:pet_buddy/screen/user/chat/chat_page.dart';
import 'package:pet_buddy/screen/user/rating/rating_add.dart';
import 'package:pet_buddy/utils.dart';

import 'package:pet_buddy/widget/comment_widget.dart';
import 'package:pet_buddy/widget/heart_animation_widget.dart';

class PetDetail extends StatefulWidget {
  final Pet pet;
  bool like;
  final UserModel my_account;

  PetDetail(
      {Key? key,
      required this.pet,
      required this.like,
      required this.my_account})
      : super(key: key);
  @override
  _PetDetail createState() => _PetDetail();
}

class _PetDetail extends State<PetDetail> {
  final commentController = TextEditingController();
  bool? limitComment;

  @override
  void initState() {
    super.initState();
  }

  void checkLimit() async {
    final ref = await FirebaseFirestore.instance
        .collection('comment')
        .where('pet_id', isEqualTo: widget.pet.pet_id)
        .get();
    int size = ref.size;
    setState(() {
      if (size == 0) {
        limitComment = false;
      } else if (size > 2) {
        limitComment = true;
      } else {
        limitComment = false;
      }
    });
    print(limitComment);
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.like ? Icons.favorite : Icons.favorite_outline;
    final color = widget.like ? Colors.red : Colors.white;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pet.name,
            style: GoogleFonts.kanit(),
          ),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportAdd(
                        pet: widget.pet,
                        my_account: widget.my_account,
                      ),
                    )),
                icon: const Icon(Icons.report))
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImage(
                            photo: widget.pet.photo,
                          ),
                        )),
                    child: Center(
                      child: Builder(
                        builder: (BuildContext context) => CachedNetworkImage(
                            imageUrl: widget.pet.photo,
                            imageBuilder: (context, imageProvider) =>
                                Image.network(
                                  widget.pet.photo,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                                  'assets/no_image.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                )),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          decoration: const BoxDecoration(color: Colors.green),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.pet.name,
                                        style: GoogleFonts.kanit(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Icon(Icons.star,
                                          color:
                                              Color.fromARGB(255, 201, 171, 5)),
                                      Text(
                                        ' (${widget.pet.rating}/5)',
                                        style: GoogleFonts.kanit(
                                          textStyle: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      widget.my_account.type != 'admin'
                                          ? HeartAnimationWidget(
                                              alwaysAnimate: true,
                                              isAnimating: widget.like,
                                              child: IconButton(
                                                  onPressed: () => setState(() {
                                                        widget.like =
                                                            !widget.like;

                                                        widget.like
                                                            ? CloudFirestoreApi
                                                                .addFavoritePet(
                                                                    widget.pet
                                                                        .pet_id,
                                                                    widget
                                                                        .my_account
                                                                        .user_id,
                                                                    'add')
                                                            : CloudFirestoreApi
                                                                .addFavoritePet(
                                                                    widget.pet
                                                                        .pet_id,
                                                                    widget
                                                                        .my_account
                                                                        .user_id,
                                                                    'delete');
                                                      }),
                                                  icon: Icon(
                                                    icon,
                                                    color: color,
                                                    size: 28,
                                                  )),
                                            )
                                          : Container(),
                                      GestureDetector(
                                        child: const Icon(
                                          Icons.directions,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MapDirection(
                                                pet: widget.pet,
                                                my_account: widget.my_account,
                                              ),
                                            )),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      child: Text(
                                    widget.pet.address,
                                    style: GoogleFonts.kanit(
                                      textStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16.0),
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text('เจ้าของ',
                              textAlign: TextAlign.start,
                              style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ))),
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('user')
                              .doc(widget.pet.user_id)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError ||
                                (snapshot.hasData && !snapshot.data!.exists)) {
                              return const Text("");
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
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
                                leading: widget.my_account.photo == ''
                                    ? CircleAvatar(
                                        radius: 20,
                                        child: Center(
                                          child: Text(
                                            widget.my_account.name
                                                .substring(0, 1),
                                            style: GoogleFonts.kanit(
                                                textStyle: const TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            widget.my_account.photo),
                                      ),
                                title: Text(user.name,
                                    style: const TextStyle(fontSize: 16.0)),
                                trailing: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(widget.pet.user_id)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError ||
                                        (snapshot.hasData &&
                                            !snapshot.data!.exists)) {
                                      return const Text("");
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> data = snapshot.data!
                                          .data() as Map<String, dynamic>;
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

                                      return ElevatedButton(
                                          onPressed: () {
                                            if (user.user_id ==
                                                widget.my_account.user_id) {
                                              Utils.showToast(
                                                  context,
                                                  'ไม่สามารถแชทกับบัญชีเดียวกันได้',
                                                  Colors.red);
                                              return;
                                            } else {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                          user: user,
                                                          my_account: widget
                                                              .my_account),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Icon(Icons.chat));
                                    }
                                    return const Text("");
                                  },
                                ),
                              );
                            }
                            return const Text("");
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: const Divider(),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            'ข้อมูล',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.kanit(
                                textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(
                            widget.pet.detail,
                            style: GoogleFonts.kanit(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: const Divider(),
                        ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ความคิดเห็น ',
                                  style: GoogleFonts.kanit(
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                StreamBuilder<List<Comment>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('comment')
                                      .where('pet_id',
                                          isEqualTo: widget.pet.pet_id)
                                      .orderBy(CommentField.createdTime,
                                          descending: true)
                                      .snapshots()
                                      .map((snapshot) => snapshot.docs
                                          .map((doc) =>
                                              Comment.fromJson(doc.data()))
                                          .toList()),
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      default:
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              'ไม่มีความคิดเห็น',
                                              style: GoogleFonts.kanit(
                                                textStyle: const TextStyle(
                                                    fontSize: 24),
                                              ),
                                            ),
                                          );
                                        } else {
                                          final comments = snapshot.data;

                                          return comments!.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    'ไม่มีความคิดเห็น',
                                                    style: GoogleFonts.kanit(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 24),
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: comments.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final comment =
                                                        comments[index];

                                                    return CommentWidget(
                                                        comment: comment,
                                                        my_account:
                                                            widget.my_account);
                                                  },
                                                );
                                        }
                                    }
                                  },
                                ),
                                limitComment == true
                                    ? GestureDetector(
                                        onTap: () => setState(() {
                                              limitComment = false;
                                            }),
                                        child: Center(
                                          child: Text(
                                            'โหลดความคิดเห็นเพิ่ม',
                                            style: GoogleFonts.kanit(
                                              textStyle: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ))
                                    : Container()
                              ],
                            )),
                        const SizedBox(height: 120)
                      ],
                    ),
                  )
                ],
              ),
            ),
            widget.my_account.type != 'admin'
                ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RatingAdd(
                                      pet: widget.pet,
                                      my_account: widget.my_account),
                                ),
                              ),
                          child: Text(
                            'แสดงความคิดเห็นและให้คะแนน',
                            style: GoogleFonts.kanit(),
                          )),
                    )
                  ])
                : Container(),
          ],
        ));
  }
}

// Container(
              //     color: Colors.white,
              //     padding: EdgeInsets.all(10),
              //     child: Column(
              //       children: [
              //         Text('ตอบกลับความเห็น'),
              //         Row(
              //           children: [
              //             CachedImageUser(
              //                 radius: 25, photo: widget.my_account.photo),
              //             SizedBox(
              //               width: 5,
              //             ),
              //             Expanded(
              //                 child: SizedBox(
              //                     height: 40,
              //                     child: TextFormField(
              //                       maxLines: 1,
              //                       controller: commentController,
              //                       textAlignVertical: TextAlignVertical.top,
              //                       textInputAction: TextInputAction.done,
              //                       decoration: InputDecoration(
              //                         border: OutlineInputBorder(),
              //                         labelText: 'Comment...',
              //                       ),
              //                       autovalidateMode: AutovalidateMode.always,
              //                       // validator: (String? value) {
              //                       //   return (value != null &&
              //                       //           value.contains('@'))
              //                       //       ? 'Do not use the @ char.'
              //                       //       : null;
              //                       // },
              //                     ))),
              //             SizedBox(
              //               width: 5,
              //             ),
              //             GestureDetector(
              //               onTap: () async {
              //                 FocusScope.of(context).unfocus();
              //                 print(commentController.text +
              //                     ' ' +
              //                     widget.my_account.name +
              //                     ' ' +
              //                     widget.my_account.photo);

              //                 // Map map = {
              //                 //   'comment': commentController.text,
              //                 //   'name': widget.my_account.name,
              //                 //   'photo': widget.my_account.photo,
              //                 //   'time': DateTime.now()
              //                 // };
              //                 // widget.comment.sub.add(map);
              //                 // await FirebaseFirestore.instance
              //                 //     .collection('comment')
              //                 //     .doc('YmOb2nCHPwsYm4qRGJJR')
              //                 //     .update({'sub': comment.sub});

              //                 commentController.text = '';
              //               },
              //               child: Icon(Icons.send, color: Colors.blue),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ))