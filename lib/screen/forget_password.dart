// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/utils.dart';

import '../constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  _ForgetPassword createState() => _ForgetPassword();
}

class _ForgetPassword extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  //final group_id = TextEditingController();
  String email = '', password = '', tel = '';
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override // หน้า UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('ลืมรหัสผ่าน',
              style: GoogleFonts.kanit(
                textStyle:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              )),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'กรุณาใส่อีเมลล์ของคุณในช่อง',
                    // 'กรุณาใส่อีเมลล์ของคุณ\nหรือเบอร์โทรในช่อง',
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  buildKey(),
                  const SizedBox(height: 10),
                  buildButton(),
                  const SizedBox(height: 10),
                  buildPasscheck(),
                  const SizedBox(height: 10),
                  buildButton2(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildKey() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: TextFormField(
                maxLines: 1,
                // initialValue: email,
                controller: emailController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  labelStyle: Myconstant().textStyle1(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (email) => setState(() => this.email = email),
                validator: (email) {
                  RegExp emailRegExp = RegExp(
                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
                  );
                  if (email!.isEmpty) {
                    return 'กรุณาใส่อีเมลก่อน';
                  } else {
                    if (!emailRegExp.hasMatch(email)) {
                      return 'กรุณาตรวจสอบอีเมลก่อน';
                    } else {
                      return null;
                    }
                  }
                }),
          ),
        ],
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          // onPressed: () => saveTodo(),
          onPressed: () => resetPassword(),
          label: Text(
            'ตั้งรหัสผ่านใหม่',
            style: Myconstant().textStyle4(),
          ),
          icon: const Icon(Icons.email_outlined),
        ),
      );

  // void saveTodo() async {
  //   print(email);

  //   FocusScope.of(context).unfocus();
  //   final isValid = _formKey.currentState!.validate();

  //   if (!isValid) {
  //     return;
  //   } else {
  //     RegExp emailRegExp = RegExp(
  //         r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  //     if (email.isEmpty) {
  //       Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
  //       return;
  //     } else if (!emailRegExp.hasMatch(email)) {
  //       Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
  //       return;
  //     }

  //     final password_test = await CloudFirestoreApi.getPasswordFromEmail(
  //       email.trim(),
  //     );
  //     print(password_test);

  //     setState(() {
  //       if (password_test == '******') {
  //         password = 'กรุณาล็อกอินบัญชี Google';
  //       } else {
  //         password = 'รหัสของคุณคือ $password_test';
  //       }
  //     });
  //   }
  // }

  Widget buildPasscheck() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              child: TextFormField(
            maxLines: 1,
            initialValue: tel,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'เบอร์โทร',
              labelStyle: Myconstant().textStyle1(),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (tel) => setState(() => this.tel = tel),
            validator: (tel) {
              if (tel!.isEmpty) {
                return 'กรุณาใส่เบอร์โทร';
              } else if (tel.length < 6) {
                return 'เบอร์โทรต้องมากว่า 6 ตัว';
              } else if (tel.length >= 11) {
                return 'เบอร์โทรต้องไม่เกิน 10 ตัว';
              }
            },
          )),
          password != ''
              ? SizedBox(
                  child: Container(
                    child: Text(
                      password,
                      style: GoogleFonts.kanit(fontSize: 20),
                    ),
                  ),
                )
              : Container()
        ],
      );

  Widget buildButton2() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => saveTocheck(),
        label: Text(
          'แสดงอีเมล',
          style: Myconstant().textStyle4(),
        ),
        icon: const Icon(Icons.email),
      ));

  Future saveTocheck() async {
    print(tel);
    final element = await CloudFirestoreApi.getEmailFormtel(
      tel.trim(),
    );
    print(element);
    Utils.showToast(
      context,
      'อีเมลของคุณคือ\f\f$element\nกรุณาจดอีเมลของท่านก่อนข้อความหาย',
      Colors.indigo,
    );
  }

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim())
          .then(
            (value) => Navigator.of(context).pop(),
          );

      Utils.showToast(context, 'ลิงค์ถูกส่งไปยังอีเมล', Colors.pink);
      Navigator.of(context).popUntil((route) => route.isCurrent);
    } on FirebaseAuthException catch (e) {
      print(e);
      if (email != null) {
        Navigator.of(context).pop();
      }

      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลก่อน', Colors.pink);
    }
  }
}
