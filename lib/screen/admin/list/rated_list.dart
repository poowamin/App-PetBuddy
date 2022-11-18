// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pet_buddy/api/cloudfirestore_api.dart';
// import 'package:pet_buddy/model/favorite.dart';
// import 'package:pet_buddy/model/history.dart';
// import 'package:pet_buddy/model/category.dart';
// import 'package:flutter/material.dart';
// import 'package:pet_buddy/model/place.dart';
// import 'package:pet_buddy/model/user_model.dart';
// import 'package:pet_buddy/page/admin/place/place_add.dart';
// import 'package:pet_buddy/widget/place_widget.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RatedList extends StatelessWidget {
//   final String category;
//   final UserModel my_account;

//   RatedList({Key? key, required this.category, required this.my_account})
//       : super(key: key);

//   @override // แสดง UI
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: (AppBar(
//           title: Text('$categoryทั้งหมด'),
//           // actions: [
//           //   GestureDetector(
//           //       onTap: () => print('object'),
//           //       child: Center(
//           //           child: Container(
//           //               margin: const EdgeInsets.only(right: 10),
//           //               child: const Text(
//           //                 'เรียงจากมากไปน้อย',
//           //                 style: TextStyle(fontSize: 16),
//           //               ))))
//           // ],
//         )),
//         body: Container(
//             margin: EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('รายการจัดอันดับ$category',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 StreamBuilder<List<Place>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('place')
//                       .where('category', isEqualTo: category)
//                       //.orderBy('rating', descending: true)
//                       .limit(3)
//                       .snapshots()
//                       .map((snapshot) => snapshot.docs
//                           .map((doc) => Place.fromJson(doc.data()))
//                           .toList()),
//                   builder: (context, snapshot) {
//                     switch (snapshot.connectionState) {
//                       case ConnectionState.waiting:
//                         return const Center(child: CircularProgressIndicator());
//                       default:
//                         if (snapshot.hasError) {
//                           return const Center(
//                             child: Text(
//                               'ไม่มีข้อมูล',
//                               style: TextStyle(fontSize: 24),
//                             ),
//                           );
//                         } else {
//                           final places = snapshot.data;

//                           return places!.isEmpty
//                               ? const Center(
//                                   child: Text(
//                                     'ไม่มีข้อมูล',
//                                     style: TextStyle(fontSize: 24),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: places.length,
//                                   itemBuilder: (context, index) {
//                                     final place = places[index];

//                                     return PlaceWidget(
//                                         place: place, my_account: my_account);
//                                   },
//                                 );
//                         }
//                     }
//                   },
//                 )
//               ],
//             )));
//   }

//   goBack(BuildContext context) {
//     Navigator.of(context).pop(false);
//   }
// }
