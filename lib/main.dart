import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_thailand_provinces/flutter_thailand_provinces.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/admin/tab/main_admin.dart';
import 'package:pet_buddy/screen/user/tab/main_user.dart';
import 'package:pet_buddy/screen/login.dart';
import 'package:http/http.dart' as http;
import 'package:pet_buddy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await ThailandProvincesDatabase.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  get kPrimaryColor => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: const Color.fromARGB(255, 250, 236, 195)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkData();
  }

  void checkData() async {
    // เช็คว่า login ไว้หรือเปล่า ถ้า login ให้ไป HomePage , ถ้าไม่ได้ Login ให้ไป LoginPage
    final prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('check') ?? false;
    var userId = prefs.getString('user_id') ?? '';
    var email = prefs.getString('email') ?? '';
    var name = prefs.getString('name') ?? '';
    var password = prefs.getString('password') ?? '';
    var tel = prefs.getString('tel') ?? '';
    var type = prefs.getString('type') ?? '';
    var photo = prefs.getString('photo') ?? '';
    var gender = prefs.getString('gender') ?? '';
    var age = prefs.getString('age') ?? '';
    var address = prefs.getString('address') ?? '';
    var idcard = prefs.getString('idcard') ?? '';
    var surname = prefs.getString('surname') ?? '';
    var stay = prefs.getString('stay') ?? '';

    var province = prefs.getString('province') ?? '';
    var amphure = prefs.getString('amphure') ?? '';
    var district = prefs.getString('district') ?? '';

    final myAccount = UserModel(
      user_id: userId,
      email: email,
      name: name,
      password: password,
      tel: tel,
      token: '',
      type: type,
      gender: gender,
      stay: stay,
      photo: photo,
      age: age,
      address: address,
      idcard: idcard,
      surname: surname,
      province: province,
      amphure: amphure,
      district: district,
    );
    if (check) {
      if (type == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainAdmin(my_account: myAccount, from: 'login')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainUser(
                    my_account: myAccount,
                    from: 'login',
                  )),
        );
      }
    } else {
      Timer(const Duration(seconds: 3), () {
        // นับเวลา 3 วิ
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const Loginscreen(),
            ),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo3.png',
              height: 250,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
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
                color: Colors.blue,
                playSound: true,
                icon: '@drawable/logo3',
              ),
            ));
      }
    });

    notification();
  }

  void notification() async {
    final prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('check') ?? false;
    var type = prefs.getString('type');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        if (check) {
          if (type == 'เจ้าหน้าที่') {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text(notification.title!),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(notification.body!)],
                      ),
                    ),
                  );
                });
          }
        }
      }
    });
  }

  Future<bool> SendPushNotifications(
      {required String title, required String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": "/topics/staff",
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": '0rder',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAA-YnbwkY:APA91bHbpYu7B44IX7ScAMtTjvtOm4La4Vt6oPkoNc5eekLKafo7BtwyepDPRjA6Uf0YNK4uRxwQYGWDBePOveeI5GUymaPrH5wiPvX2Z1zHEYOT8djA-Tj9ANxLmDa_MmQ5XRg0Dsvm' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      print('test ok push CFM');
      Utils.showToast(context, 'OK Notification', Colors.green);
      return true;
    } else {
      print('CFM error');
      return false;
    }
  }

  void _incrementCounter() {
    setState(() {
      SendPushNotifications(title: 'แจ้งเตือน', body: 'แจ้งเตือนจุดเก็บขยะ');
    });
  }

  void showNotification() {
    flutterLocalNotificationsPlugin.show(
      0,
      "แจ้งเตือน",
      "แจ้งเตือนเก็บขยะ",
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            importance: Importance.high,
            color: Colors.blue,
            playSound: true,
            icon: '@drawable/logo3'),
      ),
    );

    // Navigator.push(context,
    //     MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await FirebaseMessaging.instance
                    .subscribeToTopic('staff')
                    .whenComplete(
                      () => print('Subscribe'),
                    );
              },
              child: const Text('Subscribe To Staff'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseMessaging.instance
                    .unsubscribeFromTopic('staff')
                    .whenComplete(
                      () => print('Unubscribe'),
                    );
              },
              child: const Text('UnSubscribe To Staff'),
            ),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotification,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Palette {
  static const MaterialColor kToDark = MaterialColor(
    0xffe79797, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe79797), //10%
      100: Color(0xffe79797), //20%
      200: Color(0xffe79797), //30%
      300: Color(0xffe79797), //40%
      400: Color(0xffe79797), //50%
      500: Color(0xffe79797), //60%
      600: Color(0xffe79797), //70%
      700: Color(0xffe79797), //80%
      800: Color(0xffe79797), //90%
      900: Color(0xffe79797), //100%
    },
  );
}
