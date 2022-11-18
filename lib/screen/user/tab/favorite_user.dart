// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/favorite.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/widget/favorite_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteUser extends StatelessWidget {
  UserModel my_account;
  FavoriteUser({
    Key? key,
    required this.my_account,
  }) : super(key: key);

  final formKey = GlobalKey<FormState>();
  late String email = '', tel = '', password = '';
  String user_id = '', keyword = '';
  SharedPreferences? prefs;

  @override // แสดง UI
  Widget build(BuildContext context) {
    print(my_account.user_id);
    return Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            StreamBuilder<List<Favorite>>(
              stream: FirebaseFirestore.instance
                  .collection('favorite')
                  .where('user_id', isEqualTo: my_account.user_id)
                  .orderBy(FavoriteField.createdTime, descending: true)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => Favorite.fromJson(doc.data()))
                      .toList()),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'ไม่มีข้อมูล',
                          style: GoogleFonts.kanit(
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    } else {
                      final favorites = snapshot.data;

                      return favorites!.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                          : GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 180,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 5),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final favorite = favorites[index];

                                return FavoriteWidget(
                                    favorite: favorite, my_account: my_account);
                              },
                            );
                    }
                }
              },
            ),
          ],
        ));
  }
}
