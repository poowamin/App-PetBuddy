// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/tab/main_user.dart';

class ThankyouReview extends StatelessWidget {
  final UserModel my_account;
  const ThankyouReview({
    Key? key,
    required this.my_account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/thank_you.svg'),
          const SizedBox(
            height: 40,
          ),
          Text(
            '"ขอบคุณสำหรับการให้คะแนนพวกเรา เราจะนำมาปรับปรุงเพื่อให้บริการของเราดียิ่งขึ้น."',
            textAlign: TextAlign.center,
            style: Myconstant().textStyle1(),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainUser(
                            my_account: my_account,
                            from: 'login',
                          )),
                  (Route<dynamic> route) => false,
                ),
                child: Text(
                  'กลับสู่หน้าหลัก',
                  style: Myconstant().textStyle1(),
                ),
              ))
        ],
      ),
    ))));
  }
}
