import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/Profile.dart';
import 'package:pet_buddy/screen/user/pet/pet_detail.dart';
import 'package:pet_buddy/screen/user/pet/pet_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  _ProfileUser createState() => _ProfileUser();
}

class _ProfileUser extends State<ProfileUser> {
  SharedPreferences? prefs;
  String? user_id = '',
      email = '',
      name = '',
      password = '',
      tel = '',
      type = '',
      stay = '',
      photo_before = '',
      address = '',
      age = '',
      gender = '',
      idcard = '',
      surname = '',
      province = '',
      amphure = '',
      district = '';
  UserModel? my_account;

  final provinceController = TextEditingController();
  final amphureController = TextEditingController();
  final districtController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      address = prefs?.getString('address');
      age = prefs?.getString('age');
      gender = prefs?.getString('gender');
      idcard = prefs?.getString('idcard');
      surname = prefs?.getString('surname');
      user_id = prefs?.getString('user_id');
      email = prefs?.getString('email');
      name = prefs?.getString('name');
      password = prefs?.getString('password');
      tel = prefs?.getString('tel');
      type = prefs?.getString('type');
      photo_before = prefs?.getString('photo');
      province = prefs?.getString('province');
      amphure = prefs?.getString('amphure');
      district = prefs?.getString('district');

      my_account = UserModel(
        user_id: user_id!,
        email: email!,
        name: name!,
        password: password!,
        tel: tel!,
        token: '',
        type: type!,
        stay: stay!,
        photo: photo_before!,
        address: address!,
        age: age!,
        gender: gender!,
        idcard: idcard!,
        surname: surname!,
        province: provinceController.text.trim(),
        amphure: amphureController.text.trim(),
        district: districtController.text.trim(),
      );
    });
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Column(
      children: [
        user_id != ''
            ? Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: ListTile(
                  leading: photo_before == ''
                      ? CircleAvatar(
                          radius: 25,
                          child: Text(
                            name!.substring(0, 1),
                            style: GoogleFonts.kanit(
                              textStyle: const TextStyle(fontSize: 25),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(photo_before!),
                        ),
                  title: Text(
                    name!,
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        email!,
                      )
                    ],
                  ),
                  trailing: Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0))),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Profile()),
                      ),
                      child: Text(
                        'Profile',
                        style: GoogleFonts.kanit(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: const Divider(),
        ),
        StreamBuilder<List<Pet>>(
          stream: FirebaseFirestore.instance
              .collection('pet')
              .where('user_id', isEqualTo: user_id)
              .orderBy('time', descending: true)
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
                            'ไม่มีข้อมูลสัตว์เลี้ยง',
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

                            return PetUserWidget(pet, my_account!);
                          },
                        );
                }
            }
          },
        )
      ],
    )));
  }

  Widget PetUserWidget(Pet pet, UserModel myAccount) => SizedBox(
      width: 260,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
              onTap: () async {
                bool like = await CloudFirestoreApi.checkLikePet(
                    pet.pet_id, myAccount.user_id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PetDetail(
                          pet: pet, like: like, my_account: myAccount)),
                );
              },
              onLongPress: () => editDeleteMethod(context, pet, myAccount),
              child: Card(
                child: Column(
                  children: [
                    CachedNetworkImage(
                        imageUrl: pet.photo,
                        imageBuilder: (context, imageProvider) => Image.network(
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
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                  Text(
                                    ' (${pet.rating}/5)',
                                    style: GoogleFonts.kanit(),
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
                                  style: GoogleFonts.kanit(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 201, 171, 5)),
                                  ),
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
                                      style: GoogleFonts.kanit(
                                        textStyle:
                                            const TextStyle(fontSize: 18),
                                      ),
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

editDeleteMethod(BuildContext context, Pet pet, UserModel myAccount) async {
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
                          PetEdit(pet: pet, my_account: myAccount),
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
