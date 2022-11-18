import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:flutter/material.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/pet/pet_add.dart';
import 'package:pet_buddy/screen/user/pet/pet_detail.dart';
import 'package:pet_buddy/screen/user/pet/pet_edit.dart';

class PetList extends StatefulWidget {
  final UserModel my_account;

  const PetList({
    Key? key,
    required this.my_account,
  }) : super(key: key);
  @override
  _PetList createState() => _PetList();
}

class _PetList extends State<PetList> {
  // ประกาศตัวแปร
  String? keyword = '', type = '';

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
  }

  // โหลดข้อมูล SharedPreferences
  // Future load() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     type = prefs.getString('type');
  //   });
  // }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (AppBar(
          title: Text('สัตว์เลี้ยงทั้งหมด',
              style: GoogleFonts.kanit(
                textStyle:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              )),
        )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: TextFormField(
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
              StreamBuilder<List<Pet>>(
                stream: keyword == ''
                    ? FirebaseFirestore.instance
                        .collection('pet')
                        .orderBy(PetField.createdTime, descending: true)
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

                                  return PetAdminWidget(pet, widget.my_account);
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PetAdd(my_account: widget.my_account)),
          ),
          child: const Icon(Icons.add),
        ));
  }

  goBack(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  Widget PetAdminWidget(Pet pet, UserModel my_account) => SizedBox(
      width: 260,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
              onTap: () async {
                bool like = await CloudFirestoreApi.checkLikePet(
                    pet.pet_id, my_account.user_id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PetDetail(
                          pet: pet, like: like, my_account: my_account)),
                );
              },
              onLongPress: () => editDeleteMethod(context, pet, my_account),
              child: Card(
                child: Column(
                  children: [
                    CachedNetworkImage(
                        imageUrl: pet.photo,
                        imageBuilder: (context, imageProvider) =>
                            Image.network(
                              pet.photo,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            ),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset(
                              'assets/no_image.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            )),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pet.name,
                                overflow: TextOverflow.ellipsis,
                                style: Myconstant().textStyle5(),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color:
                                          Color.fromARGB(255, 255, 230, 67)),
                                  Text(
                                    ' (${pet.rating}/5)',
                                    style: Myconstant().textStyle1(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  pet.address,
                                  overflow: TextOverflow.ellipsis,
                                  style: Myconstant().textStyle6(),
                                ),
                              )
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     Icon(Icons.calendar_month),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Flexible(
                          //       child: Text(
                          //         pet.day,
                          //         overflow: TextOverflow.ellipsis,
                          //         style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             color: Color.fromARGB(255, 201, 171, 5)),
                          //       ),
                          //     )
                          //   ],
                          // ),
                          const Divider(),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('user')
                                .doc(pet.user_id)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError &&
                                  (snapshot.hasData &&
                                      !snapshot.data!.exists)) {
                                return const Text("");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'by ${data['name']}',
                                      style: Myconstant().textStyle1(),
                                    ),
                                  ],
                                );
                              }

                              return const Text("");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))));
}

editDeleteMethod(BuildContext context, Pet pet, UserModel my_account) async {
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            '⭐ กรุณาเลือกรายการ',
            style: GoogleFonts.kanit(
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          PetEdit(pet: pet, my_account: my_account),
                    ));
              },
              child: Text(
                'แก้ไขสัตว์เลี้ยง',
                style: GoogleFonts.kanit(
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop(false);
                await FirebaseFirestore.instance
                    .collection('pet')
                    .doc(pet.pet_id)
                    .delete()
                    .whenComplete(() async =>
                        await FireStorageApi.removePhoto(pet.photo));
              },
              child: Text(
                'ลบสัตว์เลี้ยง',
                style: GoogleFonts.kanit(
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        );
      });
}
