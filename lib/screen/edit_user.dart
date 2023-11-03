import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thailand_provinces/dao/amphure_dao.dart';
import 'package:flutter_thailand_provinces/dao/district_dao.dart';
import 'package:flutter_thailand_provinces/dao/province_dao.dart';
import 'package:flutter_thailand_provinces/dialog/choose_province_dialog.dart';
import 'package:flutter_thailand_provinces/provider/amphure_provider.dart';
import 'package:flutter_thailand_provinces/provider/district_provider.dart';
import 'package:flutter_thailand_provinces/provider/province_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:pet_buddy/screen/admin/tab/main_admin.dart';
import 'package:pet_buddy/screen/user/tab/main_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_buddy/model/user_model.dart';

import '../constants.dart';
import '../widget/choose_amphure_dialod.dart';
import '../widget/choose_district_dialog.dart';

List<Map> jsonData = [
  {"id": '1', "name": "ชาย"},
  {"id": '2', "name": "หญิง"},
];

class EditUserPage extends StatefulWidget {
  final UserModel my_account;
  final String from;

  // รับค่ามาจากหน้าก่อน
  const EditUserPage({
    Key? key,
    required this.my_account,
    required this.from,
  }) : super(key: key);

  @override
  _EditUserPage createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  late String? user_id,
      email,
      name,
      password,
      tel,
      type,
      age,
      address,
      idcard,
      surname,
      from,
      province,
      amphure,
      district;

  final provinceController = TextEditingController();
  final amphureController = TextEditingController();
  final districtController = TextEditingController();

  String? gender;
  late UserModel user;
  bool hidePassword = false;

  int proid = 0;
  int ampid = 0;
  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.my_account.user_id;
    email = widget.my_account.email;
    name = widget.my_account.name;
    password = widget.my_account.password;
    tel = widget.my_account.tel;
    type = widget.my_account.type;
    age = widget.my_account.age;
    address = widget.my_account.address;
    idcard = widget.my_account.idcard;
    surname = widget.my_account.surname;
    from = widget.from;
    province = widget.my_account.province;
    amphure = widget.my_account.amphure;
    district = widget.my_account.district;
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('แก้ไขโปรไฟล์',
              style: GoogleFonts.kanit(
                textStyle:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
              )),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // แสดงจากบนลงล่าง
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildEmail(),
                    const SizedBox(height: 8),
                    buildPassword(),
                    const SizedBox(height: 8),
                    buildUsername(),
                    const SizedBox(height: 8),
                    buildSurname(),
                    const SizedBox(height: 8),
                    buildTel(),
                    const SizedBox(height: 8),
                    buildAge(),
                    const SizedBox(height: 8),
                    buildIdCard(),
                    const SizedBox(height: 8),
                    buildAddress(),
                    const SizedBox(height: 8),
                    buildProvince(),
                    const SizedBox(height: 8),
                    buildAmphure(),
                    const SizedBox(height: 8),
                    buildDistrict(),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                value: gender,
                                icon: const Icon(Icons.arrow_drop_down),
                                hint: Text(
                                  "กรุณาเลือกเพศ",
                                  style: GoogleFonts.kanit(
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    gender = newValue!.toString();
                                    print(gender);
                                  });
                                },
                                items: jsonData.map((Map map) {
                                  return DropdownMenuItem<String>(
                                    value: map["name"].toString(),
                                    child: Row(
                                      children: [
                                        Text(
                                          map["name"],
                                          style: Myconstant().textStyle1(),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildEmail() => TextFormField(
        maxLines: 1,
        readOnly: true,
        initialValue: email,
        onChanged: (email) => setState(() => this.email = email),
        validator: (email) {
          if (email!.isEmpty) {
            return 'กรุณาใส่อีเมลก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'E - mail',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildUsername() => TextFormField(
        maxLines: 1,
        initialValue: name,
        onChanged: (name) => setState(() => this.name = name),
        validator: (name) {
          if (name!.isEmpty) {
            return 'กรุณาใส่ชื่อบัญชีก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่ชื่อบัญชี',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildSurname() => TextFormField(
        maxLines: 1,
        initialValue: surname,
        onChanged: (surname) => setState(() => this.surname = surname),
        validator: (surname) {
          if (surname!.isEmpty) {
            return 'กรุณาใส่นามสกุลก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่นามสกุล',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildTel() => TextFormField(
        maxLines: 1,
        initialValue: tel,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (tel) => setState(() => this.tel = tel),
        validator: (tel) {
          if (tel!.isEmpty) {
            return 'กรุณาใส่เบอร์โทรก่อน';
          }
          if (tel.length < 8) {
            return 'กรุณาเช็คจำนวนตัวเลขก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่เบอร์โทร',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildAge() => TextFormField(
        maxLines: 1,
        initialValue: age,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (age) => setState(() => this.age = age),
        validator: (age) {
          if (age!.isEmpty) {
            return 'กรุณาใส่อายุก่อน';
          }

          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่อายุ',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildAddress() => TextFormField(
        maxLines: 1,
        initialValue: address,
        onChanged: (address) => setState(() => this.address = address),
        validator: (address) {
          if (address!.isEmpty) {
            return 'กรุณาใส่ที่อยู่ก่อน';
          }

          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่ที่อยู่',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildIdCard() => TextFormField(
        maxLines: 1,
        initialValue: idcard,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onChanged: (idcard) => setState(() => this.idcard = idcard),
        validator: (idcard) {
          if (idcard!.isEmpty) {
            return 'กรุณาใส่เลขบัตรประชาชนก่อน';
          }
          if (idcard.length != 13) {
            return 'กรุณาเช็คเลขบัตรประชาชนก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'กรุณาใส่เลขบัตรประชาชน',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildPassword() => Stack(
        children: [
          TextFormField(
            maxLines: 1,
            initialValue: password,
            onChanged: (password) => setState(() => this.password = password),
            validator: (password) {
              if (password!.isEmpty) {
                return 'กรุณาใส่รหัสผ่านก่อน';
              }
              if (password.length < 5) {
                return 'รห้สผ่านต้องมากกว่า 6 ตัว';
              }
              return null;
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'รหัสผ่าน',
              labelStyle: Myconstant().textStyle3(),
            ),
            obscureText: hidePassword == false ? true : false,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Positioned(
              right: 10,
              bottom: 0,
              top: 15,
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

  Widget buildButton() => Container(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: () => saveTodo(),
        label: Text(
          'แก้ไขข้อมูล',
          style: Myconstant().textStyle4(),
        ),
        icon: const Icon(Icons.edit),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, fixedSize: const Size(500, 20)),
      ));

  Widget buildProvince() => TextFormField(
        readOnly: true,
        //initialValue: province,
        controller: provinceController,
        onTap: () async {
          var list = await ProvinceProvider.all();
          ProvinceDao province = await ChooseProvinceDialog.show(
            context,
            listProvinces: list,
            styleTitle: Myconstant().textStyle1(),
            styleSubTitle: Myconstant().textStyle2(),
            styleTextNoData: Myconstant().testStyle3(),
            styleTextSearch: Myconstant().textinput1(),
            styleTextSearchHint: Myconstant().textinput2(),
            colorBackgroundHeader: Myconstant.primary,
            colorBackgroundSearch: Colors.white.withOpacity(0.7),
            colorBackgroundDialog: Colors.black45.withOpacity(0.2),
            colorLine: Colors.grey.shade400,
            colorLineHeader: Myconstant.primary,
          );
          provinceController.text = province.nameTh.toString();
          proid = province.id;

          print(province.nameTh);
          print(province.id);
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'กะรุณาระบุจังหวัดก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'จังหวัด',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildAmphure() => TextFormField(
        readOnly: true,
        //initialValue: amphure,
        controller: amphureController,
        onTap: () async {
          var list = await AmphureProvider.all();
          AmphureDao amphure = await ChooseAmphureDialog.show(context,
              listAmphures: list,
              styleTitle: Myconstant().textStyle1(),
              styleSubTitle: Myconstant().textStyle2(),
              styleTextNoData: Myconstant().testStyle3(),
              styleTextSearch: Myconstant().textinput1(),
              styleTextSearchHint: Myconstant().textinput2(),
              colorBackgroundHeader: Myconstant.primary,
              colorBackgroundSearch: Colors.white.withOpacity(0.7),
              colorBackgroundDialog: Colors.black45.withOpacity(0.2),
              colorLine: Colors.grey.shade400,
              colorLineHeader: Myconstant.primary);
          amphureController.text = amphure.nameTh.toString();
          ampid = amphure.id;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'กะรุณาระบุอำเภอก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'อำเภอ',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildDistrict() => TextFormField(
        readOnly: true,
        //initialValue: district,
        controller: districtController,
        onTap: () async {
          var list = await DistrictProvider.all();
          DistrictDao district = await ChooseDistrictDialog.show(context,
              listDistricts: list,
              styleTitle: Myconstant().textStyle1(),
              styleSubTitle: Myconstant().textStyle2(),
              styleTextNoData: Myconstant().testStyle3(),
              styleTextSearch: Myconstant().textinput1(),
              styleTextSearchHint: Myconstant().textinput2(),
              colorBackgroundHeader: Myconstant.primary,
              colorBackgroundSearch: Colors.white.withOpacity(0.7),
              colorBackgroundDialog: Colors.black45.withOpacity(0.2),
              colorLine: Colors.grey.shade400,
              colorLineHeader: Myconstant.primary);
          districtController.text = district.nameTh.toString();
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'กะรุณาระบุตำบลก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'ตำบล',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();

      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'name': name.toString().trim(),
        'password': password.toString().trim(),
        'surname': surname.toString().trim(),
        'tel': tel.toString().trim(),
        'age': age.toString().trim(),
        'address': address.toString().trim(),
        'gender': gender.toString().trim(),
        'idcard': idcard.toString().trim(),
        'province': provinceController.text.trim(),
        'amphure': amphureController.text.trim(),
        'district': districtController.text.trim(),
      });
      final userAuth = FirebaseAuth.instance.currentUser;
      await userAuth?.updatePassword(password.toString().trim());
      await userAuth?.updateDisplayName(name.toString().trim());

      // ถ้า from เป็น user1 ให้บันทึกลง SharedPreferences แล้วไปหน้า HomePage ส่งค่า 4 ไป
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('name', name.toString().trim());
      prefs.setString('password', password.toString().trim());
      prefs.setString('tel', tel.toString().trim());
      prefs.setString('age', age.toString().trim());
      prefs.setString('address', address.toString().trim());
      prefs.setString('gender', gender.toString().trim());
      prefs.setString('idcard', idcard.toString().trim());
      prefs.setString('surname', surname.toString().trim());
      prefs.setString('province', provinceController.text.trim());
      prefs.setString('amphure', amphureController.text.trim());
      prefs.setString('district', districtController.text.trim());

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

      pd.dismiss();
      if (type == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainAdmin(
                    my_account: user,
                    from: 'edit_user',
                  )),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainUser(
                    my_account: user,
                    from: 'edit_user',
                  )),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
