import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

class NewMessageWidget extends StatefulWidget {
  final String user_id;
  final UserModel my_account;

  const NewMessageWidget({
    required this.user_id,
    required this.my_account,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '', imagePath = '';
  final picker = ImagePicker();

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    await CloudFirestoreApi.uploadMessage(
      widget.user_id,
      message.trim(),
      File('path'),
      'text',
      widget.my_account,
    );

    Utils.sendPushNotifications(
      context,
      title: 'แจ้งเตือนข้อความ',
      body: 'คุณได้รับข้อความ',
      token: await CloudFirestoreApi.getTokenFromUserId(widget.user_id),
    );

    _controller.clear();
  }

  void sendPicture() async {
    FocusScope.of(context).unfocus();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      ProgressDialog pd = ProgressDialog(
        loadingText: 'กรุณารอสักครู่...',
        context: context,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      pd.show();
      //FirebaseApi.uploadPhoto(File(pickedFile.path));

      await CloudFirestoreApi.uploadMessage(widget.user_id, '',
              File(pickedFile.path), 'photo', widget.my_account)
          .whenComplete(() => pd.dismiss());
      print(imagePath);

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

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: 'ใส่ข้อความสนทนา',
                    labelStyle: GoogleFonts.kanit(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 0),
                      gapPadding: 10,
                      //borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    message = value;
                  }),
                ),
              ),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: message.trim().isEmpty ? null : sendMessage,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}
