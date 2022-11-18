import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/widget/pet_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  final UserModel my_account;

  // รับค่ามาจากหน้าก่อน
  const HomeUser({
    Key? key,
    required this.my_account,
  }) : super(key: key);
  @override
  _HomeUser createState() => _HomeUser();
}

class _HomeUser extends State<HomeUser> {
  // ประกาศตัวแปรก่อนเข้าหน้า UI
  String? keyword = '', category = '';
  SharedPreferences? prefs;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //print('user');
    //load();
  }

  void popupMethod() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '⭐ กรองข้อมูล',
              style: GoogleFonts.kanit(),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              RadioListTile(
                groupValue: category,
                title: Text(
                  'สุนัข',
                  style: GoogleFonts.kanit(),
                ),
                value: 'สุนัข',
                onChanged: (String? val) {
                  setState(() {
                    category = val!;
                    print(category);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
              RadioListTile(
                groupValue: category,
                title: Text(
                  'แมว',
                  style: GoogleFonts.kanit(),
                ),
                value: 'แมว',
                onChanged: (String? val) {
                  setState(() {
                    category = val;
                    print(category);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
              RadioListTile(
                groupValue: category,
                title: Text(
                  'นก',
                  style: GoogleFonts.kanit(),
                ),
                value: 'นก',
                onChanged: (String? val) {
                  setState(() {
                    category = val;
                    print(category);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
              RadioListTile(
                groupValue: category,
                title: Text(
                  'กระต่าย',
                  style: GoogleFonts.kanit(),
                ),
                value: 'กระต่าย',
                onChanged: (String? val) {
                  setState(() {
                    category = val;
                    print(category);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
              RadioListTile(
                groupValue: category,
                title: Text(
                  'ไม่กรอง',
                  style: GoogleFonts.kanit(),
                ),
                value: '',
                onChanged: (String? val) {
                  setState(() {
                    category = '';
                    print(category);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
            ]),
          );
        });
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'กรุณาใส่คำค้นหา',
                        hintStyle: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          keyword = val;
                        });
                      },
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                          onPressed: popupMethod,
                          icon: const Icon(Icons.filter_list)),
                      category != ''
                          ? Positioned(
                              bottom: 15,
                              right: 15,
                              child: Container(
                                width: 5,
                                height: 5,
                                color: Colors.pink,
                              ))
                          : Container()
                    ],
                  )
                ],
              ),
            ),
            StreamBuilder<List<Pet>>(
              stream: keyword == ''
                  ? category != ''
                      ? FirebaseFirestore.instance
                          .collection('pet')
                          .where('category', isEqualTo: category)
                          .orderBy('time', descending: true)
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => Pet.fromJson(doc.data()))
                              .toList())
                      : FirebaseFirestore.instance
                          .collection('pet')
                          .orderBy('time', descending: true)
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => Pet.fromJson(doc.data()))
                              .toList())
                  : category != ''
                      ? FirebaseFirestore.instance
                          .collection('pet')
                          .where('category', isEqualTo: category)
                          .orderBy('name')
                          .startAt([keyword])
                          .endAt(['${keyword!}\uf8ff'])
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => Pet.fromJson(doc.data()))
                              .toList())
                      : FirebaseFirestore.instance
                          .collection('pet')
                          .orderBy('name')
                          .startAt([keyword])
                          .endAt(['${keyword!}\uf8ff'])
                          .snapshots()
                          .map((snapshot) => snapshot.docs
                              .map((doc) => Pet.fromJson(doc.data()))
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
                      final pets = snapshot.data;

                      return pets!.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่มีข้อมูล',
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: pets.length,
                              itemBuilder: (context, index) {
                                final pet = pets[index];

                                return PetWidget(
                                    pet: pet, my_account: widget.my_account);
                              },
                            );
                    }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  logoutMethod(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '⭐ แจ้งเตือน',
            style: GoogleFonts.kanit(),
          ),
          content: Text(
            "คุณต้องการออกจากระบบ ใช่หรือไม่?",
            style: GoogleFonts.kanit(),
          ),
          actions: <Widget>[
            TextButton(
              // ปิด popup
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ไม่ใช่',
                style: GoogleFonts.kanit(),
              ),
            ),
            TextButton(
              onPressed: () async {
                // เคลียร์ SharedPreferences และไปหน้า LoginPage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
              },
              child: Text(
                'ใช่',
                style: GoogleFonts.kanit(),
              ),
            ),
          ],
        );
      },
    );
  }
}
