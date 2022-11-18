import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/user/user_detail.dart';
import 'package:pet_buddy/screen/admin/user/user_edit.dart';
import 'package:pet_buddy/widget/cached_image_user.dart';

class UserWidget extends StatelessWidget {
  final UserModel user;

  const UserWidget({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: CachedImageUser(
          radius: 64,
          user: user,
        ),
      ),
      title: Text(
        user.name,
        style: GoogleFonts.kanit(),
      ),
      subtitle: Text(
        user.email,
        style: GoogleFonts.kanit(),
      ),
      trailing: Text(
        user.type == 'user' ? 'ผู้ใช้ทั่วไป' : 'แอดมิน',
        style: GoogleFonts.kanit(),
      ),
      onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => UserDetail(user_id: user.user_id)),
          ),
      onLongPress: () => addEditStaff(context, user));
}

Future addEditStaff(BuildContext context, UserModel user) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '⭐ แจ้งเตือน',
          style: GoogleFonts.kanit(),
        ),
        content: Text(
          'คุณต้องการแก้ไขข้อมูลผู้ใช้ ใช่หรือไม่?',
          style: GoogleFonts.kanit(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ไม่ใช่',
              style: GoogleFonts.kanit(),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserEdit(
                          user: user,
                        )),
              );
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
