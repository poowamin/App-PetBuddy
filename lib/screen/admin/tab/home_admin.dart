import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/list/pet_list.dart';
import 'package:pet_buddy/screen/admin/list/report_list.dart';
import 'package:pet_buddy/screen/admin/list/user_list.dart';
import 'package:pet_buddy/screen/admin/tab/writeby_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdmin extends StatefulWidget {
  final UserModel my_account;

  const HomeAdmin({
    Key? key,
    required this.my_account,
  }) : super(key: key);
  @override
  _HomeAdmin createState() => _HomeAdmin();
}

class _HomeAdmin extends State<HomeAdmin> {
  // ประกาศตัวแปรก่อนเข้าหน้า UI
  final formKey = GlobalKey<FormState>();
  late String email = '',
      tel = '',
      password = '',
      username = '',
      user_id = '',
      SumRequest = '';
  late SharedPreferences prefs;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
    //loadRequestAmount();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('user_id')!;
      print(prefs.getString('photo'));
    });
  }

  Future loadRequestAmount() async {
    final ref = await FirebaseFirestore.instance
        .collection('request')
        .where('approve', isEqualTo: 'wait')
        .get();

    if (ref.size == 0) {
      setState(() {
        SumRequest = '';
      });
    } else {
      setState(() {
        SumRequest = ref.size.toString();
      });
    }
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Align(
              child: Text('แอดมิน',
                  style: GoogleFonts.kanit(
                    textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.green),
                  )),
              alignment: Alignment.center,
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const UserList(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/man.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      Text(
                        'ข้อมูลสมาชิก',
                        style: Myconstant().textStyle1(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetList(my_account: widget.my_account),
                              ),
                            ),
                            child: Image.asset(
                              'assets/pets.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      Text(
                        'สัตว์เลี้ยงทั้งหมด',
                        style: Myconstant().textStyle1(),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ReportList(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/paper.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      Text(
                        'รายงาน',
                        style: Myconstant().textStyle1(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdminWrite(),
                              ),
                            ),
                            child: Image.asset(
                              'assets/paper.png',
                              width: 100,
                              height: 100,
                            ),
                          )),
                      Text(
                        'คำแนะนำ',
                        style: Myconstant().textStyle1(),
                      ),
                    ],
                  ),
                ),
                // Opacity(
                //     opacity: 0,
                //     child: SizedBox(
                //       width: 120,
                //       child: Column(
                //         children: [
                //           Container(
                //               width: 100,
                //               height: 100,
                //               padding: const EdgeInsets.all(8),
                //               child: ElevatedButton(
                //                 style: ButtonStyle(
                //                   shape: MaterialStateProperty.all<
                //                           RoundedRectangleBorder>(
                //                       RoundedRectangleBorder(
                //                           borderRadius:
                //                               BorderRadius.circular(18.0))),
                //                   backgroundColor:
                //                       MaterialStateProperty.all(Colors.white),
                //                 ),
                //                 onPressed: () => print('object'),
                //                 //  Navigator.of(context).push(
                //                 //   MaterialPageRoute(
                //                 //     builder: (context) =>
                //                 //         PetList(my_account: widget.my_account),
                //                 //   ),
                //                 // ),
                //                 child: Image.asset(
                //                   'assets/logo3.png',
                //                   width: 100,
                //                   height: 100,
                //                 ),
                //               )),
                //           const Text(
                //             'สัตว์เลี้ยงทั้งหมด',
                //             style: TextStyle(fontSize: 16, color: Colors.black),
                //           ),
                //         ],
                //       ),
                //     ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ));
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
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //       builder: (BuildContext context) => FirstPage(),
                //     ),
                //     (route) => false);
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
