import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/authentication_google.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/user/user_edit.dart';
import 'package:pet_buddy/screen/full_image.dart';

import '../../../constants.dart';

class UserDetail extends StatefulWidget {
  final String user_id;

  // รับค่ามาจากหน้าก่อน
  const UserDetail({
    Key? key,
    required this.user_id,
  }) : super(key: key);
  @override
  _UserDetail createState() => _UserDetail();
}

class _UserDetail extends State<UserDetail> with WidgetsBindingObserver {
  //  ประกาศตัวแปร

  String? user_id = '',
      email = '',
      name = '',
      password = '',
      tel = '',
      type = '',
      photo_before = '',
      age = '',
      address = '',
      gender = '',
      idcard = '',
      surname = '',
      province = '',
      amphure = '',
      district = '';

  String imagePath = '';
  final picker = ImagePicker();

  final provinceController = TextEditingController();
  final amphureController = TextEditingController();
  final districtController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    setState(() {
      user_id = widget.user_id;

      load_user(user_id!);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        // ...your code goes here...
        print('resume');
      });
    }
  }

  void load_user(String user_id) async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        setState(() {
          user_id = result.data()['user_id'];
          email = result.data()['email'];
          name = result.data()['name'];
          password = result.data()['password'];
          tel = result.data()['tel'];
          type = result.data()['type'];
          photo_before = result.data()['photo'];
          age = result.data()['age'];
          address = result.data()['address'];
          gender = result.data()['gender'];
          idcard = result.data()['idcard'];
          surname = result.data()['surname'];
          province = result.data()['province'];
          amphure = result.data()['amphure'];
          district = result.data()['district'];
        });
      });
    });
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'รายละเอียดบัญชี',
            style: GoogleFonts.kanit(),
          ),
        ),
        body: Container(
          // แสดงจากบนลงล่าง
          child: ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              buildPhoto(),
              const SizedBox(
                height: 30.0,
              ),
              buildEmail(),
              const SizedBox(
                height: 10.0,
              ),
              buildUsername(),
              const SizedBox(
                height: 10.0,
              ),
              buildPassword(),
              const SizedBox(
                height: 10,
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
              const SizedBox(
                height: 10.0,
              ),
              buildButtonEdit(),
              buildButtonDelete(),
              // buildButtontest(),
            ],
          ),
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
                onPressed: () async => await FireStorageApi.removePhoto(
                    'https://firebasestorage.googleapis.com/v0/b/farmaccounting-74f30.appspot.com/o/Slip%2F2021-10-06%2021%3A40%3A35.182752.jpg?alt=media&token=bc811314-61b3-4ce8-93ea-c204e64d7594'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => photo_before != ''
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImage(photo: photo_before!),
                    ),
                  )
                : print('object'),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xff476cfb),
              child: ClipOval(
                child: SizedBox(
                    width: 105,
                    height: 105,
                    child: photo_before != ''
                        ? Image.network(
                            '${photo_before}', // this image doesn't exist
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
          Opacity(
            opacity: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: const Icon(
                  Icons.photo_camera,
                  size: 25.0,
                ),
                onPressed: () async {},
              ),
            ),
          )
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
                'อีเมล :',
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

  Widget buildUsername() => Padding(
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

  Widget buildPassword() => Padding(
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
              child: Text(
                '$password',
                style: Myconstant().textStyle1(),
              ),
            ),
          ],
        ),
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
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => goToEditUser(),
        label: Text(
          'แก้ไขข้อมูล',
          style: GoogleFonts.kanit(),
        ),
        icon: const Icon(Icons.edit),
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, fixedSize: const Size(500, 20)),
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

  Widget buildButtonDelete() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(widget.user_id)
              .delete()
              .whenComplete(() => Navigator.of(context).pop(false));
        },
        label: Text(
          'ระงับบัญชี',
          style: GoogleFonts.kanit(),
        ),
        icon: const Icon(Icons.disabled_by_default_outlined),
        style: ElevatedButton.styleFrom(
            primary: Colors.red, fixedSize: const Size(500, 20)),
      ));

  Widget buildButtontest() => Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ElevatedButton.icon(
        onPressed: () => AuthenticationGoogle.testfunction(),
        label: Text(
          'test',
          style: GoogleFonts.kanit(),
        ),
        icon: const Icon(Icons.delete),
        style: ElevatedButton.styleFrom(
            primary: Colors.red, fixedSize: const Size(500, 20)),
      ));

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
      province: provinceController.text.trim(),
      amphure: amphureController.text.trim(),
      district: districtController.text.trim(),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UserEdit(user: user),
      ),
    );
  }
}
