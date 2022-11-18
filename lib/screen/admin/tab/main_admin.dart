// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/authentication_google.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/tab/home_admin.dart';
import 'package:pet_buddy/screen/admin/tab/profile_admin.dart';
import 'package:pet_buddy/screen/login.dart';
import 'package:pet_buddy/screen/user/chat/my_chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title

    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //print('A bg message just showed up :  ${message.messageId}');
}

class MainAdmin extends StatefulWidget {
  String? from;
  UserModel my_account;
  MainAdmin({
    Key? key,
    required this.my_account,
    required this.from,
  }) : super(key: key);

  @override
  _MainAdmin createState() => _MainAdmin();
}

class _MainAdmin extends State<MainAdmin> {
  String? token = '', request_amount = '', intent_from, from;
  int? selectedIndex;
  SharedPreferences? prefs;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();

    setState(() {
      // รับค่า from จากหน้าก่อน
      intent_from = widget.from;

      if (intent_from == 'edit_user') {
        selectedIndex = 0;
      } else {
        selectedIndex = 0;
      }

      //_requestPermission();
      load_user();
      //loadRequestAmount();
    });
  }

  void load_user() async {
    token = await FirebaseMessaging.instance.getToken();
    print(token);

    await FirebaseMessaging.instance
        .subscribeToTopic('admin')
        .whenComplete(() => print('Subscribe admin'));

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.my_account.user_id)
        .update({'token': token}).whenComplete(() => print('Update Token'));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.pink,
                playSound: true,
                groupKey: 'id',
                setAsGroupSummary: true,
                icon: '@drawable/logo3',
              ),
            ));
      }
    });
  }

  requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();

    final info = statuses[Permission.camera].toString();
    print(info);
    //_toastInfo(info);
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override // แสดง UI
  Widget build(BuildContext context) {
    final tabs = [
      HomeAdmin(my_account: widget.my_account),
      const ProfileAdmin(),
    ];

    return WillPopScope(
      onWillPop: Logout,
      child: Scaffold(
        appBar: AppBar(
          title: appBarMainEmployee(selectedIndex),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyChatPage(my_account: widget.my_account)),
                    ),
                icon: const Icon(Icons.chat))
            // selectedIndex == 0
            //     ? GestureDetector(
            //         onTap: () => Logout(),
            //         child: Center(
            //             child: Container(
            //                 margin: const EdgeInsets.only(right: 10),
            //                 child: const Text(
            //                   'ออกจากระบบ',
            //                   style: TextStyle(fontSize: 16),
            //                 ))))
            //     : Container()
          ],
        ),
        // แสดงปุ่มด้านล่าง
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Colors.white,
          currentIndex: selectedIndex!,
          onTap: (index) => setState(() {
            selectedIndex = index;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Home',
              backgroundColor: Color.fromARGB(255, 231, 151, 151),
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.assignment),
            //   label: 'ประวัติการยืม',
            //   backgroundColor: Colors.green,
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts, size: 28),
              label: 'Profile',
              backgroundColor: Color.fromARGB(255, 231, 151, 151),
            ),
          ],
        ),
        body: ListView(
          children: [tabs[selectedIndex!]],
        ),
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

                // final user = Provider.of<UserProvider>(context);
                // await FirebaseFirestore.instance
                //     .collection('user')
                //     .doc(user.user_id)
                //     .update({'token': ''}).whenComplete(
                //         () => print('Clear Token'));

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

  appBarMainEmployee(int? selectedIndex) {
    if (selectedIndex == 0) {
      return Text(
        'หน้าหลัก',
        style: GoogleFonts.kanit(),
      );
    } else if (selectedIndex == 1) {
      return Text(
        'บัญชี',
        style: GoogleFonts.kanit(),
      );
    }
  }
}
