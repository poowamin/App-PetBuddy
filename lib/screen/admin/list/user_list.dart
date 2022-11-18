import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/user/user_add.dart';
import 'package:pet_buddy/widget/user_widget.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserList createState() => _UserList();
}

class FruitsList {
  String name;
  int index;
  FruitsList({required this.name, required this.index});
}

class _UserList extends State<UserList> {
  // ประกาศตัวแปร
  int selectedIndex = 1;
  String? keyword = '';

  // Group Value for Radio Button.
  int id = 1;

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'สมาชิกทั้งหมด',
        style: GoogleFonts.kanit(),
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'กรุณาใส่คำค้นหา...',
                        hintStyle: GoogleFonts.kanit(
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          keyword = val;
                          print(keyword);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<UserModel>>(
              stream: keyword == ''
                  ? FirebaseFirestore.instance
                      .collection('user')
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => UserModel.fromJson(doc.data()))
                          .toList())
                  : FirebaseFirestore.instance
                      .collection('user')
                      .orderBy('name')
                      .startAt([keyword])
                      .endAt([keyword! + '\uf8ff'])
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => UserModel.fromJson(doc.data()))
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
                      final users = snapshot.data;

                      return users!.isEmpty
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
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];

                                return user.type != 'admin'
                                    ? UserWidget(user: user)
                                    : Container();
                              },
                            );
                    }
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserAdd(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
