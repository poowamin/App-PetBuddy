import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:pet_buddy/utils.dart';

class AdminWrite extends StatefulWidget {
  const AdminWrite({super.key});

  @override
  State<AdminWrite> createState() => _AdminWriteState();
}

class _AdminWriteState extends State<AdminWrite> {
  final _formKey = GlobalKey<FormState>();
  String? breeding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "คำแนะนำ",
          style: GoogleFonts.kanit(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    buildTextBox(),
                    const SizedBox(
                      height: 8,
                    ),
                    buildSaveButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextBox() => Column(
        children: <Widget>[
          Card(
              key: _formKey,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  maxLines: 14, //or null
                  initialValue: breeding,
                  onChanged: (breeding) =>
                      setState(() => this.breeding = breeding),
                  decoration: InputDecoration.collapsed(
                    hintText: "ใส่ข้อมูลที่นี่",
                    hintStyle: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300)),
                  ),
                ),
              ))
        ],
      );

  Widget buildSaveButton() => SizedBox(
        width: 140,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink),
          ),
          onPressed: () => savebreeding(),
          child: Text('บันทึกข้อมูล',
              style: GoogleFonts.kanit(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5))),
        ),
      );

  // ฟังก์ชัน save_data
  void savebreeding() async {
    FocusScope.of(context).unfocus();

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docPetbreed =
        FirebaseFirestore.instance.collection('breeding').doc('breddguide');
    await docPetbreed.set({
      'breeding': breeding,
    }).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'เพิ่มข้อมูลสำเร็จ',
            style: GoogleFonts.kanit(),
          ),
        )));

    Navigator.of(context).pop(false);
    pd.dismiss();

    if (pd.isShowing) {
      // นับเวลา 3 วิ
      Timer(const Duration(seconds: 3), () {
        pd.dismiss(); // ซ่อน Loading
        Utils.showToast(
            context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red); // แสดงข้อความ
      });
    }
  }
}
