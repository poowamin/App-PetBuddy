import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/auth_utils.dart';
import 'package:pet_buddy/api/authentication_google.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/tab/main_admin.dart';
import 'package:pet_buddy/screen/forget_password.dart';
import 'package:pet_buddy/screen/user/tab/main_user.dart';
import 'package:pet_buddy/screen/register.dart';
import 'package:pet_buddy/utils.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final formKey = GlobalKey<FormState>();
  late String email = 'admin@gmail.com';
  late String password = '000000';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSigningIn = false, isLoggedIn = false, hidePassword = false;
  Map userObj = {};

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    signOut();
  }

  signOut() async {
    await AuthenticationGoogle.signOut(context: context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 50, 35, 0),
          child: Form(
            child: Column(
              children: [
                Image.asset(
                  'assets/logo3.png',
                  height: 250,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: 'อีเมล',
                      hintStyle: GoogleFonts.kanit(
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: 'รหัสผ่าน',
                      hintStyle: GoogleFonts.kanit(
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: FloatingActionButton.extended(
                        backgroundColor:
                            const Color.fromARGB(255, 231, 151, 151),
                        onPressed: () => login(),
                        label: Text(
                          'เข้าสู่ระบบ',
                          style: GoogleFonts.kanit(
                              textStyle: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        //Navigator.pushNamed(context, 'Register');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Registerscreen()),
                        );
                      },
                      child: Text('สร้างบัญชี',
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.grey),
                          )),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgetPassword()),
                      ),
                      child: Text('ลืมรหัสผ่าน?',
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.grey),
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                // Column(
                //   children: [
                //     // SignInButton(
                //     //   Buttons.Google,
                //     //   text: "เข้าสู่ระบบผ่าน Google",
                //     //   onPressed: () {},
                //     // ),
                //     FutureBuilder(
                //       future: AuthenticationGoogle.initializeFirebase(
                //           context: context),
                //       builder: (context, snapshot) {
                //         if (snapshot.hasError) {
                //           return const Text('Error initializing Firebase');
                //         } else if (snapshot.connectionState ==
                //             ConnectionState.done) {
                //           return GoogleSignInButton();
                //         }
                //         return const CircularProgressIndicator(
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             Color(0xFFF57C00),
                //           ),
                //         );
                //       },
                //     ),
                //     // SignInButton(Buttons.FacebookNew,
                //     //     text: "เข้าสู่ระบบผ่าน Facebook", onPressed: () {
                //     //   FacebookAuth.instance
                //     //       .login(permissions: ["public_profile", "email"]).then(
                //     //           (value) {
                //     //     FacebookAuth.instance
                //     //         .getUserData()
                //     //         .then((userData) async {
                //     //       _isLoggedIn = true;
                //     //       _userObj = userData;
                //     //       print(_userObj["id"] +
                //     //           ' ' +
                //     //           _userObj["name"] +
                //     //           ' ' +
                //     //           _userObj["email"] +
                //     //           ' ' +
                //     //           _userObj['picture']['data']['url']);

                //     //       bool docExists =
                //     //           await checkIfDocExists(_userObj["id"]);
                //     //       print("Document exists in Firestore? " +
                //     //           docExists.toString());

                //     //       ProgressDialog pd = ProgressDialog(
                //     //         loadingText: 'Loading...',
                //     //         context: context,
                //     //         backgroundColor: Colors.white,
                //     //         textColor: Colors.black,
                //     //       );
                //     //       pd.show();

                //     //       if (docExists) {
                //     //         await FirebaseFirestore.instance
                //     //             .collection('user')
                //     //             .where('user_id', isEqualTo: _userObj["id"])
                //     //             .limit(1)
                //     //             .get()
                //     //             .then((querySnapshot) {
                //     //           querySnapshot.docs.forEach((result) async {
                //     //             // รับค่าจาก Firestore
                //     //             final user_id = result.data()['user_id'];
                //     //             final email = result.data()['email'];
                //     //             final password = result.data()['password'];
                //     //             final name = result.data()['name'];
                //     //             final surname = result.data()['surname'];
                //     //             final tel = result.data()['tel'];
                //     //             final type = result.data()['type'];
                //     //             final gender = result.data()['gender'];
                //     //             final stay = result.data()['stay'];
                //     //             final photo = result.data()['photo'];

                //     //             final prefs = await SharedPreferences
                //     //                 .getInstance(); // ประกาศ SharedPreferences
                //     //             prefs.setBool('check', true); // เก็บค่า boolean
                //     //             prefs.setString('user_id', user_id);
                //     //             prefs.setString('email', email);
                //     //             prefs.setString('password', password);
                //     //             prefs.setString('name', name);
                //     //             prefs.setString('surname', surname);
                //     //             prefs.setString('tel', tel);
                //     //             prefs.setString('type', type);
                //     //             prefs.setString('gender', gender);
                //     //             prefs.setString('stay', stay);
                //     //             prefs.setString('photo', photo);

                //     //             pd.dismiss();

                //     //             final my_account = UserModel(
                //     //                 user_id: user_id,
                //     //                 email: email,
                //     //                 name: name,
                //     //                 password: password,
                //     //                 tel: tel,
                //     //                 type: type,
                //     //                 token: '',
                //     //                 stay: stay,
                //     //                 photo: photo);
                //     //             Navigator.pushAndRemoveUntil(
                //     //               context,
                //     //               MaterialPageRoute(
                //     //                   builder: (context) => MainUser(
                //     //                         my_account: my_account,
                //     //                         from: 'login',
                //     //                       )),
                //     //               (Route<dynamic> route) => false,
                //     //             );
                //     //           });
                //     //         }).catchError((e) {
                //     //           pd.dismiss();
                //     //           Utils.showToast(
                //     //               context,
                //     //               'เกิดข้อผิดพลาด กรุณาลองใหม่',
                //     //               Colors.red); // แสดงข้อความ
                //     //         });
                //     //       } else {
                //     //         await FirebaseFirestore.instance
                //     //             .collection('user')
                //     //             .doc(_userObj["id"])
                //     //             .set({
                //     //           'time': DateTime.now(),
                //     //           'email': _userObj["email"],
                //     //           'gender': '',
                //     //           'name': _userObj["name"],
                //     //           'password': '******',
                //     //           'photo': _userObj['picture']['data']['url'],
                //     //           'stay': '',
                //     //           'surname': '',
                //     //           'tel': '',
                //     //           'token': '',
                //     //           'type': 'user',
                //     //           'user_id': _userObj["id"],
                //     //         });

                //     //         final prefs = await SharedPreferences
                //     //             .getInstance(); // ประกาศ SharedPreferences
                //     //         prefs.setBool('check', true);
                //     //         prefs.setString('user_id', _userObj["id"]);
                //     //         prefs.setString('email', _userObj["email"]);
                //     //         prefs.setString('name', _userObj["name"]);
                //     //         prefs.setString('surname', '');
                //     //         prefs.setString('password', '******');
                //     //         prefs.setString('tel', '');
                //     //         prefs.setString('type', 'user');
                //     //         prefs.setString('stay', '');
                //     //         prefs.setString(
                //     //             'photo', _userObj['picture']['data']['url']);

                //     //         final my_account = UserModel(
                //     //             user_id: _userObj["id"],
                //     //             email: _userObj["email"],
                //     //             name: _userObj["name"],
                //     //             password: '******',
                //     //             tel: '',
                //     //             type: 'user',
                //     //             token: '',
                //     //             stay: '',
                //     //             photo: _userObj['picture']['data']['url']);
                //     //         pd.dismiss();
                //     //         Navigator.pushAndRemoveUntil(
                //     //           context,
                //     //           MaterialPageRoute(
                //     //               builder: (context) => MainUser(
                //     //                     my_account: my_account,
                //     //                     from: 'login',
                //     //                   )),
                //     //           (Route<dynamic> route) => false,
                //     //         );
                //     //       }
                //     //     });
                //     //   });
                //     // }),
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    FocusScope.of(context).unfocus();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
      return;
    }

    if (password.isEmpty) {
      Utils.showToast(context, 'กรุณากรอกรหัสผ่านก่อน', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    User? user = await EPAuthentication.signInUsingEmailPassword(
        context: context, email: email, password: password, pd: pd);

    if (user == null) {
      pd.dismiss();
      return;
    } else {
      // print("${user.uid} ${user.email!}");
      await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          pd.dismiss();
          var user_id = result.data()['user_id'];
          var email = result.data()['email'];
          var password = result.data()['password'];
          var name = result.data()['name'];
          var tel = result.data()['tel'];
          var type = result.data()['type'];
          var stay = result.data()['stay'];
          var photo = result.data()['photo'];
          var age = result.data()['age'];
          var address = result.data()['address'];
          var gender = result.data()['gender'];
          var idcard = result.data()['idcard'];
          var surname = result.data()['surname'];

          var province = result.data()['province'];
          var amphure = result.data()['amphure'];
          var district = result.data()['district'];

          final prefs =
              await SharedPreferences.getInstance(); // ประกาศ SharedPreferences
          prefs.setBool('check', true); // เก็บค่า boolean
          prefs.setString('user_id', user_id);
          prefs.setString('email', email!);
          prefs.setString('name', name);
          prefs.setString('password', password);
          prefs.setString('stay', stay);
          prefs.setString('tel', tel);
          prefs.setString('type', type);
          prefs.setString('photo', photo);
          prefs.setString('age', age);
          prefs.setString('address', address);
          prefs.setString('gender', gender);
          prefs.setString('idcard', idcard);
          prefs.setString('surname', surname);
          prefs.setString('province', province);
          prefs.setString('amphure', amphure);
          prefs.setString('district', district);

          final my_account = UserModel(
            user_id: user_id,
            email: email!,
            name: name,
            password: password,
            tel: tel,
            token: '',
            type: type,
            stay: stay,
            photo: photo,
            address: address,
            age: age,
            gender: gender,
            idcard: idcard,
            surname: surname,
            province: province,
            amphure: amphure,
            district: district,
          );

          if (type == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MainAdmin(
                        my_account: my_account,
                        from: 'login',
                      )),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MainUser(
                        my_account: my_account,
                        from: 'login',
                      )),
              (Route<dynamic> route) => false,
            );
          }
        });
      }).catchError((e) {
        pd.dismiss();
        Utils.showToast(
            context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red); // แสดงข้อความ
      });
      }

      if (pd.isShowing) {
        // นับเวลา 3 วิ
        Timer(const Duration(seconds: 3), () {
          pd.dismiss(); // ซ่อน Loading
          Utils.showToast(context, 'ข้อมูลไม่ถูกต้อง กรุณาลองใหม่',
              Colors.red); // แสดงข้อความ
        });
    }
  }
}
