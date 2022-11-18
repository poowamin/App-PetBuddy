import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

// ไฟล์สำหรับจัดการข้อมูลใน firebase
class FireStorageApi {
  // ลบรูปภาพ
  static Future removePhoto(String photo_before) async {
    if (Uri.parse(photo_before).origin ==
        'https://firebasestorage.googleapis.com') {
      await FirebaseStorage.instance
          .refFromURL(photo_before)
          .delete()
          .then((value) => print('Delete Photo Success'));
    }
  }

  static Future uploadPhoto(File _image, String folder) async {
    if (_image == null) {
      return '';
    } else {
      String fileName =
          '${folder}_${DateTime.now().millisecondsSinceEpoch}${path.extension(_image.path)}';
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('$folder/$fileName').putFile(_image);
      if (snapshot.state == TaskState.success) {
        final String url = await snapshot.ref
            .getDownloadURL()
            .whenComplete(() => print('Upload Success'));
        return url;
      }
    }
  }
}
