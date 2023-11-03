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
import 'package:pet_buddy/api/auth_utils.dart';
import 'package:pet_buddy/constants.dart';
import 'package:pet_buddy/utils.dart';
import 'package:pet_buddy/widget/choose_amphure_dialod.dart';
import 'package:pet_buddy/widget/choose_district_dialog.dart';

List<Map> jsonData = [
  {"id": '1', "name": "ชาย"},
  {"id": '2', "name": "หญิง"},
];

class Registerscreen extends StatefulWidget {
  const Registerscreen({Key? key}) : super(key: key);

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _formKey = GlobalKey<FormState>();
  late String email = '',
      tel = '',
      password = '',
      name = '',
      surname = '',
      password_confirm = '',
      idcard = '',
      age = '',
      address = '';

  final provinceController = TextEditingController();
  final amphureController = TextEditingController();
  final districtController = TextEditingController();

  bool validate = false;
  String? gender;

  int proid = 0;
  int ampid = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สร้างบัญชีเข้าใช้งาน',
            style: GoogleFonts.kanit(
              textStyle:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            )),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildName(),
                const SizedBox(height: 8),
                buildSurname(),
                const SizedBox(height: 8),
                buildEmail(),
                const SizedBox(height: 8),
                buildPassword(),
                const SizedBox(height: 8),
                buildPasswordConfirm(),
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
                            hint: Text("กรุณาเลือกเพศ",
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(fontSize: 14),
                                )),
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
    );
  }

  Widget buildEmail() => TextFormField(
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

  Widget buildName() => TextFormField(
        maxLines: 1,
        initialValue: name,
        onChanged: (name) => setState(() => this.name = name),
        validator: (name) {
          if (name!.isEmpty) {
            return 'กรุณาใส่ชื่อก่อน';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'ชื่อ',
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
          labelText: 'นามสกุล',
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
          if (password.length < 6) {
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
  Widget buildPasswordConfirm() => TextFormField(
        maxLines: 1,
        initialValue: password_confirm,
        onChanged: (passwordConfirm) =>
            setState(() => password_confirm = passwordConfirm),
        validator: (passwordConfirm) {
          if (password != passwordConfirm) {
            return 'รหัสผ่านไม่ตรงกัน';
          }
          if (passwordConfirm!.isEmpty) {
            return 'กรุณาใส่รหัสผ่านก่อน';
          }
          if (passwordConfirm.length < 6) {
            return 'รห้สผ่านต้องมากกว่า 6 ตัว';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'รหัสผ่านอีกครั้ง',
          labelStyle: Myconstant().textStyle3(),
        ),
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
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
          if (tel.length < 6) {
            return 'เบอร์โทรต้องมากกว่า 6 ตัว';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'เบอร์โทร',
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
          labelText: 'อายุ',
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
            labelText: 'ที่อยู่',
            labelStyle: Myconstant().textStyle3(),
            hintText: 'บ้านเลขที่',
            hintStyle: GoogleFonts.kanit(
              textStyle: const TextStyle(
                fontSize: 13.0,
              ),
            )),
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

  Widget buildButton() => Container(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: () => register(),
        label: Text(
          'เพิ่มบัญชี',
          style: GoogleFonts.kanit(textStyle: const TextStyle(fontSize: 16),)
        ),
        icon: const Icon(Icons.edit),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink, fixedSize: const Size(500, 20)),
      ));

  register() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      RegExp emailRegExp = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
      if (email.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
        return;
      } else if (!emailRegExp.hasMatch(email)) {
        Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
        return;
      }

      if (password.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกรหัสผ่านก่อน', Colors.red);
        return;
      }
      if (password_confirm.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกยืนยันรหัสผ่านก่อน', Colors.red);
        return;
      }

      if (password != password_confirm) {
        Utils.showToast(context, 'รหัสผ่านไม่ตรงกัน', Colors.red);
        return;
      }

      if (name.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกชื่อก่อน', Colors.red);
        return;
      }

      if (tel.isEmpty) {
        Utils.showToast(context, 'กรุณากรอกเบอร์โทรก่อน', Colors.red);
        return;
      }

      if (tel.length < 8) {
        Utils.showToast(context, 'กรุณาเช็คจำนวนเบอร์โทรก่อน', Colors.red);
        return;
      }

      if (age.isEmpty) {
        Utils.showToast(context, 'กรุณาเช็คอายุก่อน', Colors.red);
        return;
      }

      if (address.isEmpty) {
        Utils.showToast(context, 'กรุณาเช็คที่อยู่ก่อน', Colors.red);
        return;
      }

      if (surname.isEmpty) {
        Utils.showToast(context, 'กรุณาเช็คนามสกุลก่อน', Colors.red);
        return;
      }
      if (idcard.isEmpty) {
        Utils.showToast(context, 'กรุณาเช็คเลขบัตรประชาชนก่อน', Colors.red);
        return;
      }
      if (idcard.length != 13) {
        Utils.showToast(
            context, 'กรุณาเช็คจำนวนเลขบัตรประชาชนก่อน', Colors.red);
        return;
      }
      if (gender == null) {
        Utils.showToast(context, 'กรุณาเลือกเพศก่อน', Colors.red);
        return;
      }

      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();

      User? user = await EPAuthentication.registerUsingEmailPassword(
          name: name.trim(),
          email: email.trim(),
          password: password.trim(),
          context: context,
          pd: pd);

      if (user == null) {
        return;
      }
      // else {
      // if (await checkIfDocExists(email.trim()) == false) {
      //   pd.dismiss();
      //   Utils.showToast(context, 'อีเมลซ้ำ กรุณาเปลี่ยน',
      //       Colors.red); // ส่งค่าไปเพิ่มข้อมูลผู้ใช้

      // } else {
      final docUser = FirebaseFirestore.instance.collection('user').doc();
      await docUser.set({
        'email': email,
        'name': name,
        'password': password,
        'photo': '',
        'stay': '',
        'tel': tel,
        'time': DateTime.now(),
        'token': '',
        'type': 'user',
        'gender': gender,
        'age': age,
        'address': address,
        'idcard': idcard,
        'surname': surname,
        'user_id': docUser.id,
        'province': provinceController.text.trim(),
        'amphure': amphureController.text.trim(),
        'district': districtController.text.trim(),
      });

      // await FirebaseAuth.instance.signOut();
      Utils.showToast(context, 'สมัครสมาชิกสำเร็จ', Colors.green);
      pd.dismiss();
      Navigator.pop(context);
      // }
      // }
    }
  }

  Future<bool> checkIfDocExists(String email) async {
    bool check = false;
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      // ถ้าไม่ซ้ำให้เป็น false
      check = true;
    } else {
      // ถ้าซ้ำให้เป็น true
      check = false;
    }
    return check;
  }
}
