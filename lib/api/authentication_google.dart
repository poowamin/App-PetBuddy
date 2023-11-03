import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:pet_buddy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationGoogle {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool docExists = await checkIfDocExists(user.uid);
      print("Document exists in Firestore? " + docExists.toString());

      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();

      if (docExists) {
        await FirebaseFirestore.instance
            .collection('user')
            .where('user_id', isEqualTo: user.uid)
            .limit(1)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((result) async {
            // รับค่าจาก Firestore
            var userId = result.data()['user_id'];
            var email = result.data()['email'];
            var name = result.data()['name'];
            var password = result.data()['password'];
            var tel = result.data()['tel'];
            var type = result.data()['type'];
            var photo = result.data()['photo'];

            final prefs = await SharedPreferences
                .getInstance(); // ประกาศ SharedPreferences
            prefs.setBool('check', true); // เก็บค่า boolean
            prefs.setString('user_id', userId);
            prefs.setString('email', email);
            prefs.setString('name', name);
            prefs.setString('password', password);
            prefs.setString('tel', tel);
            prefs.setString('type', type);
            prefs.setString('photo', photo);

            // final my_account = UserModel(
            //     user_id: user_id,
            //     email: email!,
            //     name: name,
            //     password: password,
            //     tel: tel,
            //     token: '',
            //     type: type,
            //     gender: '',
            //     stay: '',
            //     photo: photo);

            pd.dismiss();
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => MainUser(
            //             my_account: my_account,
            //             from: 'login',
            //           )),
            //   (Route<dynamic> route) => false,
            // );
          });
        }).catchError((e) {
          pd.dismiss();
          Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่',
              Colors.red); // แสดงข้อความ
        });
      } else {
        await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
          'user_id': user.uid,
          'email': user.email,
          'password': '******',
          'username': user.displayName,
          'tel': '',
          'token': '',
          'type': 'ผู้ใช้ทั่วไป',
          'photo': user.photoURL,
          'createdTime': DateTime.now(),
        });

        final prefs =
            await SharedPreferences.getInstance(); // ประกาศ SharedPreferences
        prefs.setBool('check', true);
        prefs.setString('user_id', user.uid);
        prefs.setString('email', user.email!);
        prefs.setString('username', user.displayName!);
        prefs.setString('password', '******');
        prefs.setString('tel', '');
        prefs.setString('type', 'ผู้ใช้ทั่วไป');
        prefs.setString('photo', user.photoURL!);

        // final my_account = UserModel(
        //     user_id: user.uid,
        //     email: user.email!,
        //     name: user.displayName!,
        //     password: '',
        //     tel: '',
        //     token: '',
        //     type: 'ผู้ใช้ทั่วไป',
        //     gender: '',
        //     stay: '',
        //     photo: user.photoURL!);

        pd.dismiss();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => MainUser(
        //             my_account: my_account,
        //             from: 'login',
        //           )),
        //   (Route<dynamic> route) => false,
        // );
      }
    }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              AuthenticationGoogle.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              AuthenticationGoogle.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            AuthenticationGoogle.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance
          .signOut()
          .whenComplete(() => print('Google Sign Out'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        AuthenticationGoogle.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static Future<void> testfunction() async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('addMessage');
    final response = await callable.call();

    if (response.data != null) {
      print(response.data);
    }
  }
}

Future<bool> checkIfDocExists(String docId) async {
  try {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('user');

    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    rethrow;
  }
}
