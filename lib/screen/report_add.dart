import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';

class ReportAdd extends StatefulWidget {
  final Pet pet;
  final UserModel my_account;
  const ReportAdd({
    Key? key,
    required this.pet,
    required this.my_account,
  }) : super(key: key);

  @override
  State<ReportAdd> createState() => _ReportAdd();
}

class _ReportAdd extends State<ReportAdd> {
  final reason1Controller = TextEditingController(text: '(รายงาน ผู้ใช้งาน) ');
  final reason2Controller = TextEditingController(text: '(รายงาน สัตว์เลี้ยง) ');
  final otherController = TextEditingController(text: '(รายงาน อื่นๆ) ');
  String selected = '';

  final picker = ImagePicker();
  String imagePath = '';
  File? croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'รายงานปัญหา',
            style: GoogleFonts.kanit(
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildImageAsset(),
              RadioListTile(
                groupValue: selected,
                title: Text(
                  'ผู้ใช้งาน',
                  style: GoogleFonts.kanit(),
                ),
                value: 'ผู้ใช้งาน',
                onChanged: (String? val) {
                  setState(() {
                    selected = val!;
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),
              selected == 'ผู้ใช้งาน'
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Flexible(
                          child: TextField(
                        controller: reason1Controller,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'รายละเอียดเพิ่มเติม',
                            hintStyle: GoogleFonts.kanit(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                      )),
                    )
                  : Container(),
              RadioListTile(
                groupValue: selected,
                title: Text(
                  'สัตว์เลี้ยง',
                  style: GoogleFonts.kanit(),
                ),
                value: 'สัตว์เลี้ยง',
                onChanged: (String? val) {
                  setState(() {
                    selected = val!;
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),
              selected == 'สัตว์เลี้ยง'
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Flexible(
                          child: TextField(
                        controller: reason2Controller,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'รายละเอียดเพิ่มเติม',
                            hintStyle: GoogleFonts.kanit(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                      )),
                    )
                  : Container(),
              // RadioListTile(
              //   groupValue: selected,
              //   title: Text(
              //     'สัตว์เลี้ยงเป็นอันตราย',
              //     style: GoogleFonts.kanit(),
              //   ),
              //   value: 'สัตว์เลี้ยงเป็นอันตราย',
              //   onChanged: (String? val) {
              //     setState(() {
              //       selected = val!;
              //     });
              //   },
              // ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              //   child: Flexible(
              //       child: TextField(
              //     controller: otherController,
              //     decoration: InputDecoration(
              //         fillColor: Colors.grey.shade100,
              //         filled: true,
              //         hintText: 'รายละเอียดเพิ่มเติม',
              //         hintStyle: GoogleFonts.kanit(),
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12))),
              //   )),
              // ),
              // RadioListTile(
              //   groupValue: selected,
              //   title: Text(
              //     'สัตว์เลี้ยงไม่เหมาะสม',
              //     style: GoogleFonts.kanit(),
              //   ),
              //   value: 'สัตว์เลี้ยงไม่เหมาะสม',
              //   onChanged: (String? val) {
              //     setState(() {
              //       selected = val!;
              //     });
              //   },
              // ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              //   child: Flexible(
              //       child: TextField(
              //     controller: otherController,
              //     decoration: InputDecoration(
              //         fillColor: Colors.grey.shade100,
              //         filled: true,
              //         hintText: 'รายละเอียดเพิ่มเติม',
              //         hintStyle: GoogleFonts.kanit(),
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12))),
              //   )),
              // ),
              // RadioListTile(
              //   groupValue: selected,
              //   title: Text(
              //     'ก่อกวน สร้างความรำคาญ',
              //     style: GoogleFonts.kanit(),
              //   ),
              //   value: 'ก่อกวน สร้างความรำคาญ',
              //   onChanged: (String? val) {
              //     setState(() {
              //       selected = val!;
              //     });
              //   },
              // ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              //   child: Flexible(
              //       child: TextField(
              //     controller: otherController,
              //     decoration: InputDecoration(
              //         fillColor: Colors.grey.shade100,
              //         filled: true,
              //         hintText: 'รายละเอียดเพิ่มเติม',
              //         hintStyle: GoogleFonts.kanit(),
              //         border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(12))),
              //   )),
              // ),
              RadioListTile(
                groupValue: selected,
                title: Text(
                  'อื่นๆ',
                  style: GoogleFonts.kanit(),
                ),
                value: 'อื่นๆ',
                onChanged: (String? val) {
                  setState(() {
                    selected = val!;
                  });
                },
              ),
              const SizedBox(
                height: 16,
              ),
              selected == 'อื่นๆ'
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Flexible(
                          child: TextField(
                        controller: otherController,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'รายละเอียดเพิ่มเติม',
                            hintStyle: GoogleFonts.kanit(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                      )),
                    )
                  : Container(),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () => report(),
                child: Text(
                  'รายงาน',
                  style: GoogleFonts.kanit(),
                ),
              )
            ],
          ),
        ));
  }

  Widget buildImageAsset() => Column(
        children: [
          imagePath != ''
              ? Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Image.file(
                        File(imagePath),
                        height: 150,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 8.0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black,
                        child: GestureDetector(
                            onTap: () => setState(() {
                                  imagePath = '';
                                }),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            )),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => chooseGallery(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: const [10, 4],
                      strokeCap: StrokeCap.round,
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.folder_open,
                              size: 40,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'เลือกรูป',
                              style: GoogleFonts.kanit(
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
        ],
      );

  Future chooseGallery(BuildContext context) async {
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
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  final pickedFile =
                      await picker.getImage(source: ImageSource.camera);
                  CropImageDialog(pickedFile);
                },
                child: Text(
                  'ถ่ายรูป',
                  style: GoogleFonts.kanit(
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  final pickedFile =
                      await picker.getImage(source: ImageSource.gallery);
                  CropImageDialog(pickedFile);
                },
                child: Text(
                  'เลือกรูป',
                  style: GoogleFonts.kanit(
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void CropImageDialog(PickedFile? pickedFile) async {
    if (pickedFile != null) {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'การตัดรูป',
          toolbarColor: Colors.green[700],
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.green[700],
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      if (croppedFile != null) {
        setState(() {
          imagePath = croppedFile!.path;
          print(pickedFile.path);
        });
      }
    }
  }

  report() async {
    //FocusScope.of(context).unfocus();
    if (selected == 'อื่นๆ') {
      selected = otherController.text.trim();
      if (selected.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกข้อมูลก่อน', Colors.red);
        return;
      }

      print(selected);
    } else {
      if (selected == 'ผู้ใช้งาน') {
        selected = reason1Controller.text.trim();
        if (selected.isEmpty) {
          Utils.showToast(context, 'กรุณากรอกข้อมูลก่อน', Colors.red);
          return;
        }

        print(selected);
      } else {
        if (selected == 'สัตว์เลี้ยง') {
          selected = reason2Controller.text.trim();
          if (selected.isEmpty) {
            Utils.showToast(context, 'กรุณากรอกข้อมูลก่อน', Colors.red);
            return;
          }

          print(selected);
        }
      }
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final docReport = FirebaseFirestore.instance.collection('report').doc();
    await docReport.set({
      'report_id': docReport.id,
      'detail': selected,
      'photo': await FireStorageApi.uploadPhoto(croppedFile!, 'Report'),
      'time': DateTime.now(),
      'pet_id': widget.pet.pet_id,
      'pet_name': widget.pet.name,
      'user_id': widget.my_account.user_id,
      'isCheck1': false,
      'isCheck2': false,
      'isCheck3': false,
      'isCheck4': false,
    });

    Utils.sendPushNotifications(context,
        title: 'แจ้งเตือนรายงาน',
        body: 'มีรายงานจากผู้ใช้เข้ามา',
        token: 'admin');

    Utils.showToast(context, 'รายงานสำเร็จ', Colors.green);
    pd.dismiss();
    Navigator.pop(context);
  }
}
