import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';

import '../../../constants.dart';

List<Map> _categoryJson = [
  {"id": '1', "name": "สุนัข"},
  {"id": '2', "name": "แมว"},
  {"id": '3', "name": "นก"},
  {"id": '4', "name": "กระต่าย"},
];

List<Map> _typedogJson = [
  {"id": '1', "name": "โกลเดน รีทรีฟเวอร์"},
  {"id": '2', "name": "ลาบาดอร์"},
  {"id": '3', "name": "บางแก้ว"},
  {"id": '4', "name": "เปอร์เซีย"},
];

class PetAdd extends StatefulWidget {
  final UserModel my_account;

  const PetAdd({
    Key? key,
    required this.my_account,
  }) : super(key: key);
  @override
  _PetAdd createState() => _PetAdd();
}

class _PetAdd extends State<PetAdd> {
  //ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  String? name, detail, day, tumbon, address, _category, _type;

  final picker = ImagePicker();
  String imagePath = '';
  String imagePDegree = '';
  File? croppedFile;
  File? croppedFile2;

  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  double? latitude, longitude;
  LatLng? initialPosition;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    //load();
    markers.clear();
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เพิ่มสัตว์เลี้ยง',
          style: GoogleFonts.kanit(),
        ),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildGoogleMap(),
            Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    buildImageAsset(),
                    // const Align(
                    //     child: Text('หมวดหมู่', style: TextStyle(fontSize: 18)),
                    //     alignment: Alignment.centerLeft),
                    const SizedBox(height: 10),
                    buildName(),
                    buildAddress(),
                    buildDetail(),
                    const SizedBox(height: 10),
                    buildCategory(),
                    const SizedBox(height: 10),
                    buildType(),
                    const SizedBox(height: 10),
                    buildButton(),
                  ],
                ))
          ],
        ),
      )),
    );
  }

  Widget buildGoogleMap() => SizedBox(
      height: 200,
      child: GoogleMap(
        zoomGesturesEnabled: true,
        onTap: (LatLng latLng) {
          markers.clear();

          latitude = latLng.latitude;
          longitude = latLng.longitude;

          print('${latitude.toString()}  ${longitude.toString()}');
          setState(() {
            markers.add(Marker(
              markerId: const MarkerId('id'),
              position: LatLng(latitude!, longitude!),
              // LatLng(latitude!, longitude!), //position of marker
              infoWindow: const InfoWindow(
                title: 'จุดพิกัด',
              ),
              icon: BitmapDescriptor.defaultMarker, //Icon for Marker
            ));
          });
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(19.031245616702847, 99.92622323969147),
          zoom: 15.0,
        ),
        markers: markers,
        mapType: MapType.normal, //map type
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ));

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
                    margin: const EdgeInsets.all(5),
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
                            Text('เลือกรูป',
                                style: GoogleFonts.kanit(
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade400,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  )),
        ],
      );

  // แสดงช่องกรอกรายการ
  Widget buildName() => TextFormField(
        maxLines: 1,
        initialValue: name,
        onChanged: (name) => setState(() => this.name = name),
        validator: (name) {
          if (name!.isEmpty) {
            return 'กรุณาใส่ชื่อสัตว์เลี้ยง';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'ชื่อสัตว์เลี้ยง',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  Widget buildDetail() => TextFormField(
        maxLines: 1,
        initialValue: detail,
        onChanged: (detail) => setState(() => this.detail = detail),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: 'รายละเอียด',
          labelStyle: Myconstant().textStyle3(),
        ),
      );

  // แสดงช่องกรอกจำนวน
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
        ),
      );

  Widget buildCategory() => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(0)),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              isDense: true,
              hint: Text(
                'กรุณาเลือกประเภท',
                style: GoogleFonts.kanit(),
              ),
              value: _category,
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue.toString().trim();
                  print(_category);
                });
              },
              items: _categoryJson.map((Map map) {
                return DropdownMenuItem<String>(
                  value: map["name"].toString(),
                  child: Row(
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            map["name"],
                            style: GoogleFonts.kanit(),
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );

  Widget buildType() => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(0)),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              isDense: true,
              hint: Text(
                'กรุณาเลือกสายพันธุ์',
                style: GoogleFonts.kanit(),
              ),
              value: _type,
              onChanged: (String? newValue) {
                setState(() {
                  _type = newValue.toString().trim();
                  print(_type);
                });
              },
              items: _typedogJson.map((Map map) {
                return DropdownMenuItem<String>(
                  value: map["name"].toString(),
                  child: Row(
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            map["name"],
                            style: GoogleFonts.kanit(),
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );

  // แสดงปุ่มบันทึก
  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink),
          ),
          onPressed: () => save_data(),
          child: Text(
            'เพิ่มสัตว์เลี้ยง',
            style: GoogleFonts.kanit(
                textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
          ),
        ),
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

  // ฟังก์ชัน save_data
  void save_data() async {
    print(croppedFile!);
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // ถ้าในข้อมูลไม่ครบ
      return;
    } else {
      if (imagePath == '') {
        Utils.showToast(context, 'กรุณาเลือกรูปภาพก่อน', Colors.red);
        return;
      }

      if (_category == null) {
        Utils.showToast(context, 'กรุณาเลือกประเภทก่อน', Colors.red);
        return;
      }

      if (_type == null) {
        Utils.showToast(context, 'กรุณาเลือกสายพันธุ์ก่อน', Colors.red);
        return;
      }

      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();

      GeoPoint location = GeoPoint(latitude!, longitude!);

      final docPet = FirebaseFirestore.instance.collection('pet').doc();
      await docPet.set({
        'address': address,
        'category': _category,
        'type': _type,
        'detail': detail,
        'location': location,
        'name': name,
        'pet_id': docPet.id,
        'photo': await FireStorageApi.uploadPhoto(croppedFile!, 'Pet'),
        'time': DateTime.now(),
        'rating': 0,
        'user_id': widget.my_account.user_id,
      }).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'เพิ่มสัตว์เลี้ยงสำเร็จ',
              style: GoogleFonts.kanit(),
            ),
          )));

      Navigator.of(context).pop(false);
      pd.dismiss();

      if (pd.isShowing) {
        // นับเวลา 3 วิ
        Timer(const Duration(seconds: 3), () {
          pd.dismiss(); // ซ่อน Loading
          Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่',
              Colors.red); // แสดงข้อความ
        });
      }
    }
  }
}
