import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/api/authentication_google.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/edit_user.dart';
import 'package:pet_buddy/screen/full_image.dart';
import 'package:pet_buddy/screen/login.dart';
import 'package:pet_buddy/utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as path;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  //  ประกาศตัวแปร
  SharedPreferences? prefs;
  bool hidePassword = false;

  String? user_id = '',
      email = '',
      name = '',
      password = '',
      tel = '',
      type = '',
      photo_before = '',
      address = '',
      age = '',
      gender = '',
      idcard = '',
      surname = '',
      province = '',
      amphure = '',
      district = '';
  //     createdTime;

  String imagePath = '';
  final picker = ImagePicker();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs?.getString('user_id');
      email = prefs?.getString('email');
      name = prefs?.getString('name');
      password = prefs?.getString('password');
      tel = prefs?.getString('tel');
      type = prefs?.getString('type');
      photo_before = prefs?.getString('photo');
      address = prefs?.getString('address');
      age = prefs?.getString('age');
      gender = prefs?.getString('gender');
      idcard = prefs?.getString('idcard');
      surname = prefs?.getString('surname');
      province = prefs?.getString('province');
      amphure = prefs?.getString('amphure');
      district = prefs?.getString('district');
    });
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ข้อมูลผู้ใช้',
            style: GoogleFonts.kanit(),
          ),
        ),
        body: ListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            const SizedBox(
              height: 30.0,
            ),
            buildPhoto(),
            const SizedBox(height: 30.0),
            buildEmail(),
            const SizedBox(
              height: 10.0,
            ),
            buildName(),
            const SizedBox(
              height: 10.0,
            ),
            buildSurname(),
            const SizedBox(
              height: 10.0,
            ),
            buildTel(),
            const SizedBox(
              height: 10.0,
            ),
            buildType(),
            const SizedBox(
              height: 10.0,
            ),
            buildAddress(),
            const SizedBox(
              height: 10.0,
            ),
            buildProvince(),
            const SizedBox(
              height: 10.0,
            ),
            buildAmphure(),
            const SizedBox(
              height: 10.0,
            ),
            buildDistrict(),
            const SizedBox(
              height: 10.0,
            ),
            buildAges(),
            const SizedBox(
              height: 10.0,
            ),
            buildGender(),
            const SizedBox(
              height: 10.0,
            ),
            buildIdCard(),
            buildButtonEdit(),
            buildButtonExit()
          ],
        ));
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 25.0,
                  ),
                  onPressed: () => print('object')),
            ),
          ),
          GestureDetector(
            onTap: () => photo_before != ''
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImage(photo: photo_before!),
                    ),
                  )
                : print('test'),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color.fromARGB(255, 247, 219, 140),
              child: ClipOval(
                child: SizedBox(
                    width: 105,
                    height: 105,
                    child: photo_before != ''
                        ? Image.network(
                            photo_before!, // this image doesn't exist
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/user.png',
                            fit: BoxFit.cover,
                          )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: IconButton(
              icon: const Icon(
                Icons.photo_camera,
                size: 25.0,
              ),
              onPressed: () async {
                final pickedFile =
                    await picker.getImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  File? croppedFile = await ImageCropper().cropImage(
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
                      imagePath = croppedFile.path;
                      uploadPic(croppedFile);
                      print(imagePath);
                    });
                  }
                }
              },
            ),
          ),
        ],
      );

  Widget buildEmail() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              child: Text(
                'อีเมลล์ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '$email',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildName() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              child: Text(
                'ชื่อผู้ใช้ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '$name',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildPassword() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 65,
                  child: Text(
                    'รหัสผ่าน :',
                    style: Myconstant().textStyle7(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: hidePassword
                      ? Text(
                          '$password',
                          style: Myconstant().textStyle1(),
                        )
                      : Text(
                          Utils.returnPassword(password!.length),
                          style: Myconstant().textStyle1(),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
              right: 30,
              child: GestureDetector(
                  child: Icon(
                    hidePassword == false
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onTap: () => setState(() {
                        hidePassword = !hidePassword;
                      })))
        ],
      );

  Widget buildTel() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 67,
              child: Text(
                'เบอร์โทร :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$tel',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildSurname() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 67,
              child: Text(
                'นามสกุล :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  '$surname',
                  style: Myconstant().textStyle1(),
                )),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 65,
              child: Text(
                'ประเภท :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                type == 'user' ? 'ผู้ใช้ทั่วไป' : 'แอดมิน',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildAddress() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'ที่อยู่ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                address!,
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildAges() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'อายุ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                age!,
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildGender() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'เพศ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                gender!,
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildIdCard() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'เลขบัตร :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                idcard!,
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildButtonEdit() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(50, 20, 50, 0),
      child: ElevatedButton.icon(
        onPressed: () => goToEditUser(),
        label: Text(
          'แก้ไขข้อมูล',
          style: GoogleFonts.kanit(),
        ),
        icon: const Icon(Icons.edit),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, fixedSize: const Size(500, 20)),
      ));

  Widget buildButtonExit() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: ElevatedButton.icon(
        onPressed: () => logoutMethod(context),
        label: Text(
          'ออกจากระบบ',
          style: GoogleFonts.kanit(),
        ),
        icon: const Icon(Icons.exit_to_app),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, fixedSize: const Size(500, 20)),
      ));

  Widget buildProvince() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'จังหวัด :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$province',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildAmphure() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'อำเภอ :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$amphure',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  Widget buildDistrict() => Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 67,
              child: Text(
                'ตำบล :',
                style: Myconstant().textStyle7(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '$district',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
      );

  // อัปโหลดรูปภาพ
  Future uploadPic(File _image) async {
    FocusScope.of(context).unfocus();

    if (_image == null) {
      // ถ้าไม่มีรูปให้แสดง SnackBar
      Utils.showToast(context, 'กรุณาเลือกรูปก่อน', Colors.red);

      return;
    } else {
      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();
      String fileName =
          'User_${DateTime.now().millisecondsSinceEpoch}${path.extension(_image.path)}';

      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('User/$fileName').putFile(_image);
      if (snapshot.state == TaskState.success) {
        String url = await snapshot.ref.getDownloadURL();

        if (photo_before != '') {
          await FireStorageApi.removePhoto(photo_before!);
        }

        pd.dismiss();
        prefs?.setString('photo', url);
        FirebaseFirestore.instance
            .collection('user')
            .doc(user_id)
            .update({'photo': url});

        //await FirebaseAuth.instance.currentUser!.updatePhotoURL(url);

        setState(() {
          photo_before = url;
        });
      } else {
        pd.dismiss();
        Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่',
            Colors.red); // แสดง SnackBar
        return;
      }
    }
  }

  // ไปหน้า EditUserPage
  void goToEditUser() {
    final user = UserModel(
      user_id: user_id.toString().trim(),
      email: email.toString().trim(),
      name: name.toString().trim(),
      password: password.toString().trim(),
      tel: tel.toString().trim(),
      token: '',
      type: type.toString().trim(),
      stay: '',
      photo: '',
      address: address!,
      age: age!,
      gender: gender!,
      idcard: idcard!,
      surname: surname!,
      province: province!,
      amphure: amphure!,
      district: district!,
    );

    // ไปหน้า EditUserPage
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserPage(my_account: user, from: 'edit'),
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
                await AuthenticationGoogle.signOut(context: context);
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(user_id)
                    .update({'token': ''}).whenComplete(
                        () => print('Clear Token'));
                // เคลียร์ SharedPreferences และไปหน้า LoginPage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const Loginscreen(),
                    ),
                    (route) => false);
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
