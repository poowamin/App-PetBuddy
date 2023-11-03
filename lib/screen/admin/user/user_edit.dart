import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:pet_buddy/model/user_model.dart';

import '../../../constants.dart';
import '../../../widget/choose_amphure_dialod.dart';
import '../../../widget/choose_district_dialog.dart';

List<Map> jsonData = [
  {"id": '1', "name": "ชาย"},
  {"id": '2', "name": "หญิง"},
];

class UserEdit extends StatefulWidget {
  final UserModel user;

  // รับค่ามาจากหน้าก่อน
  const UserEdit({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _UserEdit createState() => _UserEdit();
}

class _UserEdit extends State<UserEdit> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? user_id,
      email,
      name,
      password,
      tel,
      type,
      age,
      address,
      idcard,
      surname,
      province,
      amphure,
      district;
  String? gender;
  bool hidePassword = false;

  final provinceController = TextEditingController();
  final amphureController = TextEditingController();
  final districtController = TextEditingController();

  int proid = 0;
  int ampid = 0;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.user.user_id;
    email = widget.user.email;
    name = widget.user.name;
    password = widget.user.password;
    tel = widget.user.tel;
    type = widget.user.type;
    age = widget.user.age;
    address = widget.user.address;
    idcard = widget.user.idcard;
    surname = widget.user.surname;
    province = widget.user.province;
    amphure = widget.user.amphure;
    district = widget.user.district;
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'แก้ไขข้อมูลผู้ใช้',
            style: GoogleFonts.kanit(),
          ),
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
        enabled: false,
        maxLines: 1,
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

  Widget buildPassword() => TextFormField(
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
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          onPressed: () {
            saveTodo();
          },
          child: Text(
            'แก้ไขข้อมูล',
            style: GoogleFonts.kanit(
                textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5)),
          ),
        ),
      );

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

      // แก้ไขข้อมูล
      await FirebaseFirestore.instance.collection('user').doc(user_id).update({
        'name': name.toString().trim(),
        'password': password.toString().trim(),
        'surname': surname.toString().trim(),
        'tel': tel.toString().trim(),
        'gender': gender.toString().trim(),
        'age': age.toString().trim(),
        'address': address.toString().trim(),
        'idcard': idcard.toString().trim(),
        'province': provinceController.text.trim(),
        'amphure': amphureController.text.trim(),
        'district': districtController.text.trim(),
      });

      pd.dismiss();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => EmployeeDetail(user_id: user_id!)),
      // );
      Navigator.pop(context);
    }
  }
}
