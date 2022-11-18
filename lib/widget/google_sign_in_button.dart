// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
// import 'package:pet_buddy/api/authentication_google.dart';
// import 'package:pet_buddy/model/user_model.dart';
// import 'package:pet_buddy/screen/user/tab/main_user.dart';
// import 'package:pet_buddy/utils.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class GoogleSignInButton extends StatefulWidget {
//   @override
//   _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
// }

// class _GoogleSignInButtonState extends State<GoogleSignInButton> {
//   bool _isSigningIn = false;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       child: _isSigningIn
//           ? const CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             )
//           : SignInButton(
//               Buttons.Google,
//               text: "เข้าสู่ระบบผ่าน Google",
//               onPressed: () async {
//                 setState(() {
//                   _isSigningIn = true;
//                 });
//                 User? user = await AuthenticationGoogle.signInWithGoogle(
//                     context: context);

//                 setState(() {
//                   _isSigningIn = false;
//                 });

//                 if (user != null) {
//                   bool docExists = await checkIfDocExists(user.uid);
//                   print(
//                       "Document exists in Firestore? " + docExists.toString());

//                   ProgressDialog pd = ProgressDialog(
//                     loadingText: 'กรุณารอสักครู่...',
//                     context: context,
//                     backgroundColor: Colors.white,
//                     textColor: Colors.black,
//                   );
//                   pd.show();

//                   if (docExists) {
//                     await FirebaseFirestore.instance
//                         .collection('user')
//                         .where('user_id', isEqualTo: user.uid)
//                         .limit(1)
//                         .get()
//                         .then((querySnapshot) {
//                       querySnapshot.docs.forEach((result) async {
//                         // รับค่าจาก Firestore
//                         var user_id = result.data()['user_id'];
//                         var email = result.data()['email'];
//                         var name = result.data()['name'];
//                         var password = result.data()['password'];
//                         var tel = result.data()['tel'];
//                         var type = result.data()['type'];
//                         var photo = result.data()['photo'];
//                         var age = result.data()['age'];
//                         var stay = result.data()['stay'];
//                         var address = result.data()['address'];
//                         var gender = result.data()['gender'];
//                         var idcard = result.data()['idcard'];
//                         var surname = result.data()['surname'];

//                         final prefs = await SharedPreferences
//                             .getInstance(); // ประกาศ SharedPreferences
//                         prefs.setBool('check', true); // เก็บค่า boolean
//                         prefs.setString('user_id', user_id);
//                         prefs.setString('email', email);
//                         prefs.setString('name', name);
//                         prefs.setString('password', password);
//                         prefs.setString('tel', tel);
//                         prefs.setString('type', type);
//                         prefs.setString('photo', photo);
//                         prefs.setString('age', age);
//                         prefs.setString('address', address);
//                         prefs.setString('gender', gender);
//                         prefs.setString('idcard', idcard);
//                         prefs.setString('stay', stay);
//                         prefs.setString('surname', surname);

//                         final my_account = UserModel(
//                           user_id: user_id,
//                           email: email!,
//                           name: name,
//                           password: password,
//                           tel: tel,
//                           token: '',
//                           type: type,
//                           stay: stay,
//                           photo: photo,
//                           age: age,
//                           address: address,
//                           gender: gender,
//                           idcard: idcard,
//                           surname: surname,

//                           // province: province,
//                           // amphure: amphure,
//                           // district: district,
//                         );

//                         pd.dismiss();
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => MainUser(
//                                     my_account: my_account,
//                                     from: 'login',
//                                   )),
//                           (Route<dynamic> route) => false,
//                         );
//                       });
//                     }).catchError((e) {
//                       pd.dismiss();
//                       Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่',
//                           Colors.red); // แสดงข้อความ
//                     });
//                   } else {
//                     await FirebaseFirestore.instance
//                         .collection('user')
//                         .doc(user.uid)
//                         .set({
//                       'user_id': user.uid,
//                       'email': user.email,
//                       'password': '******',
//                       'username': user.displayName ?? '',
//                       'tel': user.phoneNumber ?? '',
//                       'token': '',
//                       'type': 'user',
//                       'photo': user.photoURL,
//                       'age': '',
//                       'address': '',
//                       'gender': '',
//                       'idcard': '',
//                       'stay': '',
//                       'surname': '',
//                       'time': DateTime.now(),
//                     });

//                     final prefs = await SharedPreferences
//                         .getInstance(); // ประกาศ SharedPreferences
//                     prefs.setBool('check', true);
//                     prefs.setString('user_id', user.uid);
//                     prefs.setString('email', user.email!);
//                     prefs.setString('username', user.displayName ?? '');
//                     prefs.setString('password', '******');
//                     prefs.setString('tel', user.phoneNumber ?? '');
//                     prefs.setString('type', 'user');
//                     prefs.setString('photo', user.photoURL!);

//                     final my_account = UserModel(
//                       user_id: user.uid,
//                       email: user.email!,
//                       name: user.displayName ?? '',
//                       password: '',
//                       tel: user.phoneNumber ?? '',
//                       token: '',
//                       type: 'user',
//                       stay: '',
//                       photo: user.photoURL!,
//                       gender: '',
//                       age: '',
//                       address: '',
//                       idcard: '',
//                       surname: '',

//                       // province: '',
//                       // amphure: '',
//                       // district: '',
//                     );

//                     pd.dismiss();
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => MainUser(
//                                 my_account: my_account,
//                                 from: 'login',
//                               )),
//                       (Route<dynamic> route) => false,
//                     );
//                   }
//                 }
//               },

//               // Padding(
//               //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
//               //   child: Row(
//               //     mainAxisSize: MainAxisSize.max,
//               //     mainAxisAlignment: MainAxisAlignment.center,
//               //     children: <Widget>[
//               //       Image(
//               //         image: AssetImage("assets/google.png"),
//               //         height: 25.0,
//               //       ),
//               //       Padding(
//               //         padding: const EdgeInsets.only(left: 10),
//               //         child: Text(
//               //           'Sign in with Google',
//               //           style: TextStyle(
//               //             fontSize: 16,
//               //             color: Colors.orange,
//               //             fontWeight: FontWeight.w600,
//               //           ),
//               //         ),
//               //       )
//               //     ],
//               //   ),
//               // ),
//             ),
//     );
//   }
// }
