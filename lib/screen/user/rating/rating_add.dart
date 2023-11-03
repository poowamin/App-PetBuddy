// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/rating/thank_review.dart';
import 'package:pet_buddy/utils.dart';

import '../../../constants.dart';

class RatingAdd extends StatefulWidget {
  final Pet pet;
  final UserModel my_account;

  const RatingAdd({
    Key? key,
    required this.pet,
    required this.my_account,
  }) : super(key: key);
  @override
  _RatingAdd createState() => _RatingAdd();
}

class _RatingAdd extends State<RatingAdd> {
  double? _ratingValue;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'หน้าแสดงความคิดเห็น',
              style: GoogleFonts.kanit(
                textStyle: const TextStyle(
                    fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CircleAvatar(
              radius: 40, backgroundImage: NetworkImage(widget.pet.photo)),
          Text(
            widget.pet.name,
            style: GoogleFonts.kanit(
              textStyle: const TextStyle(fontSize: 20.0),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'ให้คะแนนพวกเราหน่อย',
            style: GoogleFonts.kanit(
              textStyle: const TextStyle(fontSize: 16.0),
            ),
          ),
          Text('คะแนนของคุณคือกำลังใจของเรา',
              style: GoogleFonts.kanit(
                textStyle: const TextStyle(color: Colors.grey),
              )),
          RatingBar(
              initialRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              ratingWidget: RatingWidget(
                  full: const Icon(Icons.star, color: Colors.orange),
                  half: const Icon(
                    Icons.star_half,
                    color: Colors.orange,
                  ),
                  empty: const Icon(
                    Icons.star_outline,
                    color: Colors.grey,
                  )),
              onRatingUpdate: (value) {
                setState(() {
                  _ratingValue = value;
                });
              }),
          const SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              SizedBox(
                  height: 40,
                  child: TextFormField(
                    maxLines: 1,
                    controller: commentController,
                    textAlignVertical: TextAlignVertical.top,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'ความคิดเห็น...',
                      labelStyle: Myconstant().textStyle1(),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? value) {
                      print(value);
                      value != ''
                          ? Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => commentController.clear(),
                              ))
                          : Container();
                      return null;
                    },
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => save_data(),
                child: Text('ให้คะแนน',
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(fontSize: 16),
                    )),
              ))
        ],
      ),
    )));
  }

  void save_data() async {
    if (_ratingValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'กรุณาให้คะแนนก่อน',
          style: GoogleFonts.kanit(),
        ),
      ));
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docComment = FirebaseFirestore.instance.collection('comment').doc();
    await docComment.set({
      'comment': commentController.text.trim(),
      'comment_id': docComment.id,
      'time': DateTime.now(),
      'like': 0,
      'pet_id': widget.pet.pet_id,
      'rating': _ratingValue,
      'user_id': widget.my_account.user_id,
      'who_like': []
    });

    await CloudFirestoreApi.setAverageRating(widget.pet.pet_id)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'ให้คะแนนสำเร็จ',
                style: GoogleFonts.kanit(),
              ),
            )));

    Utils.sendPushNotifications(context,
        title: 'แจ้งเตือนรายงาน',
        body: 'สัตว์เลี้ยงของคุณได้รับคะแนนแล้ว',
        token: await CloudFirestoreApi.getTokenFromUserId(widget.pet.user_id));

    pd.dismiss();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ThankyouReview(
                my_account: widget.my_account,
              )),
    );
  }
}
