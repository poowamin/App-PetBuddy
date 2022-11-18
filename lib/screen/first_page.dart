// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';
// import 'package:pet_buddy/screen/login.dart';

// enum LanguagesActions { english, chinese }

// class FirstPage extends StatelessWidget {
//   const FirstPage({super.key});

//   @override // แสดง UI
//   Widget build(BuildContext context) => Scaffold(
//           body: Center(
//               child: SizedBox(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: SingleChildScrollView(
//             // แสดงจากยนลงล่าง
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 buildHeader(),
//                 const SizedBox(height: 26),
//                 buildImage(),
//                 const SizedBox(height: 26),
//                 // buildButton1(context),
//                 buildButton2(context),
//                 const SizedBox(height: 26),
//               ],
//             ),
//           ),
//         ),
//       )));

//   Widget buildHeader() => const Align(
//         alignment: Alignment.center,
//         child: Text(
//           'ท่องเที่ยวจังหวัดลพบุรี',
//           style: TextStyle(
//               fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
//         ),
//       );
//   Widget buildImage() => Image.asset(
//         'assets/wall1.png',
//         width: 350,
//       );

//   // Widget buildButton1(BuildContext context) => FutureBuilder(
//   //       future: AuthenticationGoogle.initializeFirebase(context: context),
//   //       builder: (context, snapshot) {
//   //         if (snapshot.hasError) {
//   //           return const Text('Error initializing Firebase');
//   //         } else if (snapshot.connectionState == ConnectionState.done) {
//   //           return GoogleSignInButton();
//   //         }
//   //         return const CircularProgressIndicator(
//   //           valueColor: AlwaysStoppedAnimation<Color>(
//   //             CustomColors.firebaseOrange,
//   //           ),
//   //         );
//   //       },
//   //     );

//   Widget buildButton2(BuildContext context) => SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           style: ButtonStyle(
//             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18.0))),
//             backgroundColor:
//                 MaterialStateProperty.all(const Color.fromARGB(255, 0, 109, 4)),
//           ),
//           onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const Loginscreen()),
//           ),
//           child: const Text(
//             'ล็อกอินด้วยอีเมลล์',
//             maxLines: 1,
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//       );

//   // Widget buildButton3() => SizedBox(
//   //       width: double.infinity,
//   //       child: ElevatedButton(
//   //         style: ButtonStyle(
//   //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//   //               RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(18.0))),
//   //           backgroundColor: MaterialStateProperty.all(Colors.white),
//   //         ),
//   //         onPressed: () => Navigator.push(
//   //           context,
//   //           MaterialPageRoute(builder: (context) => RegisterPage()),
//   //         ),
//   //         child: const Text(
//   //           'สร้างบัญชี',
//   //           style: TextStyle(
//   //               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
//   //         ),
//   //       ),
//   //     );
// }

// Future<bool> checkIfDocExists(String docId) async {
//   try {
//     // Get reference to Firestore collection
//     var collectionRef = FirebaseFirestore.instance.collection('user');

//     var doc = await collectionRef.doc(docId).get();
//     return doc.exists;
//   } catch (e) {
//     rethrow;
//   }
// }
