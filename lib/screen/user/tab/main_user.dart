import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/list/report_list.dart';
import 'package:pet_buddy/screen/login.dart';
import 'package:pet_buddy/screen/user/chat/my_chat.dart';
import 'package:pet_buddy/screen/user/pet/pet_add.dart';
import 'package:pet_buddy/screen/user/tab/breeding_guide.dart';
import 'package:pet_buddy/screen/user/tab/favorite_user.dart';
import 'package:pet_buddy/screen/user/tab/home_user.dart';
import 'package:pet_buddy/screen/user/tab/only_read_report_list.dart';
import 'package:pet_buddy/screen/user/tab/profile_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pet_buddy/api/authentication_google.dart';

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

class MainUser extends StatefulWidget {
  final String from;
  final UserModel my_account;
  const MainUser({
    Key? key,
    required this.my_account,
    required this.from,
  }) : super(key: key);

  @override
  State<MainUser> createState() => _MainUser();
}

class _MainUser extends State<MainUser> {
  int currentIndex = 0;

  void load_user() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(token);

    // await FirebaseMessaging.instance
    //     .subscribeToTopic('user')
    //     .whenComplete(() => print('Subscribe librarian'));

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

  Future<bool> Logout() async {
    return (await logoutMethod()) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeUser(my_account: widget.my_account),
      FavoriteUser(my_account: widget.my_account),
      const BreedingGuide(),
      const ProfileUser(),
    ];
    return WillPopScope(
        onWillPop: Logout,
        child: Scaffold(
            appBar: AppBar(
              title: Text(setAppbarName(currentIndex)),
              backgroundColor: Colors.pink,
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportListReadOnly(),
                      )),
                  icon: const Icon(Icons.history_outlined),
                ),
                IconButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyChatPage(my_account: widget.my_account)),
                        ),
                    icon: const Icon(Icons.chat))
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedItemColor: Colors.white,
              currentIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  backgroundColor: Colors.pink,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorite',
                  backgroundColor: Colors.pink,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Breeding',
                  backgroundColor: Colors.pink,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                  backgroundColor: Colors.pink,
                ),
              ],
            ),
            body: tabs[currentIndex],
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.pinkAccent,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PetAdd(my_account: widget.my_account)),
              ),
              child: const Icon(Icons.add),
            )));
  }

  String setAppbarName(int currentIndex) {
    String name = '';
    if (currentIndex == 0) {
      name = 'หน้าหลัก';
    } else if (currentIndex == 1) {
      name = 'ถูกใจ';
    } else if (currentIndex == 2) {
      name = 'คำแนะนำ';
    } else if (currentIndex == 3) {
      name = 'บัญชี';
    }
    return name;
  }

  logoutMethod() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '⭐ แจ้งเตือน',
            style: GoogleFonts.kanit(),
          ),
          content: Text(
            'คุณต้องการออกจากระบบใช่หรือไม่?',
            style: GoogleFonts.kanit(),
          ),
          actions: <Widget>[
            TextButton(
              // ปิด popup
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.kanit(),
              ),
            ),
            TextButton(
              onPressed: () async {
                // await FirebaseMessaging.instance
                //     .unsubscribeFromTopic('user')
                //     .whenComplete(() => print('User UnSubscribe'));
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(widget.my_account.user_id)
                    .update({'token': ''}).whenComplete(
                        () => print('Clear Token'));
                await AuthenticationGoogle.signOut(context: context);
                //await FacebookAuth.instance.logOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const Loginscreen(),
                    ),
                    (route) => false);
              },
              child: Text(
                'ตกลง',
                style: GoogleFonts.kanit(),
              ),
            ),
          ],
        );
      },
    );
  }
}
