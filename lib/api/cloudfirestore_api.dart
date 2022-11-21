import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_buddy/api/firestorage_api.dart';
import 'package:pet_buddy/model/message.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/utils.dart';

// ไฟล์สำหรับจัดการข้อมูลใน firebase
class CloudFirestoreApi {
  static Stream<List<UserModel>> getUser() => FirebaseFirestore.instance
      .collection('user')
      .orderBy(UserModelField.createdTime, descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());

  static Future<String> getTokenFromUserId(String user_id) async {
    String token = '';

    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        token = result.data()['token'];
      });
    });

    return token;
  }

  static Future<String?> getUsername(String user_id) async {
    String? username;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        username = result.data()['username'];
      });
    });

    return username;
  }

  // รับค่า id แล้วคืนกลับไป
  static Future<String> getIdGroupMonth(String month) async {
    String? doc_id;
    await FirebaseFirestore.instance
        .collection('group_month')
        .where('month', isEqualTo: month)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        doc_id = result.data()['group_month_id'];
      });
    });

    return doc_id!;
  }

  static Future<String> getPhotoFromUserId(String user_id) async {
    String? photo;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        photo = result.data()['photo'];
      });
    });

    return photo!;
  }

  static Future<UserModel> getUserfromComment(String user_id) async {
    UserModel? my_account;

    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .get();

    if (ref.size == 0) {
      my_account = null;
      return my_account!;
    } else {
      await FirebaseFirestore.instance
          .collection('user')
          .where('user_id', isEqualTo: user_id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          // final user_id = result.data()['user_id'];
          // final email = result.data()['email'];
          // final name = result.data()['name'];
          // final surname = result.data()['surname'];
          // final password = result.data()['password'];
          // final tel = result.data()['tel'];
          // final token = result.data()['token'];
          // final type = result.data()['type'];
          // final gender = result.data()['gender'];
          // final stay = result.data()['stay'];
          // final photo = result.data()['photo'];

          // final province = result.data()['province'];
          // final amphure = result.data()['amphure'];
          // final district = result.data()['district'];
        });
      });
    }

    return my_account!;
  }

  static Future updateAllTrashMonthInit(String user_id) async {
    await FirebaseFirestore.instance
        .collection('trash_month')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'color': true});
      }
    });
  }

//   // อัพเดต color ใน note_month
  static Future updateColorTrashMonth(String noteMonthId) async {
    await FirebaseFirestore.instance
        .collection('trash_month')
        .where('id', isNotEqualTo: noteMonthId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'color': false});
      }
    });

    await FirebaseFirestore.instance
        .collection('trash_month')
        .doc(noteMonthId)
        .update({'color': true});
  }

//   // คำนวณราคารวม แล้วคืนกลับไป
  static Future<int> getSumBookMonth(String month, String status) async {
    int sum = 0;
    await FirebaseFirestore.instance
        .collection('month')
        .where('month', isEqualTo: month)
        .where('status', isEqualTo: status)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        sum += int.parse(result.data()['amount']);
      });
    });
    return sum;
  }

  static Future addComment(
      String comment, String place_id, String user_id) async {
    final doc = FirebaseFirestore.instance.collection('comment').doc();
    await doc.set({
      'comment': comment,
      'comment_id': doc.id,
      'createdTime': DateTime.now(),
      'like': 0,
      'place_id': place_id,
      'user_id': user_id,
    });
  }

  static Future setAverageRating(String pet_id) async {
    double sum = 0;

    final ref = await FirebaseFirestore.instance
        .collection('comment')
        .where('pet_id', isEqualTo: pet_id)
        .get();

    if (ref.size == 0) {
      await FirebaseFirestore.instance
          .collection('pet')
          .doc(pet_id)
          .update({'rating': "0"});
    } else {
      await FirebaseFirestore.instance
          .collection('comment')
          .where('pet_id', isEqualTo: pet_id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          sum = sum + result.data()['rating'];
        });
      });

      final average = (sum / ref.size).toStringAsFixed(1);
      print(average);

      await FirebaseFirestore.instance
          .collection('pet')
          .doc(pet_id)
          .update({'rating': double.parse(average)});
    }
  }

  static Future addFavoritePet(
      String pet_id, String user_id, String type) async {
    if (type == 'add') {
      if (checkLikePet(pet_id, user_id) == true) {
        return;
      }

      final doc = FirebaseFirestore.instance.collection('favorite').doc();
      await doc.set({
        'favorite_id': doc.id,
        'pet_id': pet_id,
        'user_id': user_id,
        'time': DateTime.now(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('favorite')
          .doc(await getPetIdFromUserId(pet_id, user_id))
          .delete();
    }
  }

  static Future<String> getPetIdFromUserId(
      String pet_id, String user_id) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('favorite')
        .where('pet_id', isEqualTo: pet_id)
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['favorite_id'];
      });
    });
    return data!;
  }

  static Future<bool> checkLikePet(String pet_id, String user_id) async {
    bool check;
    final ref = await FirebaseFirestore.instance
        .collection('favorite')
        .where('pet_id', isEqualTo: pet_id)
        .where('user_id', isEqualTo: user_id)
        .get();

    ref.size == 0 ? check = false : check = true;
    return check;
  }

  static Future<bool> whoLikeComment(String comment_id, String user_id) async {
    bool check;
    final ref = await FirebaseFirestore.instance
        .collection('comment')
        .where('comment_id', isEqualTo: comment_id)
        .where('who_like', arrayContainsAny: [user_id]).get();

    ref.size == 0 ? check = false : check = true;
    return check;
  }

  static Future getMaxvalue() async {
    int? data;
    await FirebaseFirestore.instance
        .collection('comment')
        .orderBy("count", descending: true)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['count'];
      });
    });

    print(data ??= 0);
  }

  static Stream<List<Message>> getMessages(String chat_link_id) =>
      FirebaseFirestore.instance
          .collection('chats/$chat_link_id/messages')
          .orderBy(MessageField.createdAt, descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList());

  static Future addChatLink(String user_id, String sender_id) async {
    late String chat_link_id1 = '', chat_link_id2 = '';
    final refUsers1 = FirebaseFirestore.instance
        .collection('chat_link')
        .where(
          'receiver_id',
          isEqualTo: user_id,
        )
        .where(
          'sender_id',
          isEqualTo: sender_id,
        );

    final refUsers2 = FirebaseFirestore.instance
        .collection('chat_link')
        .where(
          'receiver_id',
          isEqualTo: sender_id,
        )
        .where(
          'sender_id',
          isEqualTo: user_id,
        );

    final getChatLink1 = await refUsers1.get();
    final getChatLink2 = await refUsers2.get();
    if (getChatLink1.size == 0 && getChatLink2.size == 0) {
      final doc = FirebaseFirestore.instance.collection('chat_link').doc();
      final listUser = [];
      listUser.add(user_id);
      listUser.add(sender_id);
      await doc.set({
        'id': doc.id,
        'receiver_id': user_id,
        'sender_id': sender_id,
        'message': '',
        'type': '',
        'time': '',
        'day': '',
        'user': listUser,
        'createdTime': DateTime.now(),
      });
      return doc.id;
    } else {
      await refUsers1.get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          chat_link_id1 = result.data()['id'];
        });
      });
      await refUsers2.get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          chat_link_id2 = result.data()['id'];
        });
      });

      String id = '$chat_link_id1 $chat_link_id2'.trim();
      return id;
    }
  }

  static Future uploadMessage(String user_id, String message, File image,
      String type, UserModel my_account) async {
    String? chatLinkId = await addChatLink(user_id, my_account.user_id);
    print('chatLinkId ' + chatLinkId!);
    final refMessages =
        FirebaseFirestore.instance.collection('chats/$chatLinkId/messages');

    if (type == 'text') {
      final newMessage = Message(
        user_id: my_account.user_id,
        username: my_account.name,
        message: message,
        type: type,
        time:
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        day: Utils.getDateThai(),
        seen: await checkUserStay(user_id) == chatLinkId ? 'yes' : 'no',
        createdAt: DateTime.now(),
      );

      await refMessages.add(newMessage.toJson());

      await FirebaseFirestore.instance
          .collection('chat_link')
          .doc(chatLinkId)
          .update({
        'receiver_id': user_id,
        'sender_id': my_account.user_id,
        'message': message,
        'unseen':
            await getCountSeen(chatLinkId.trim(), my_account.user_id.trim()),
        'type': type,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        'day': Utils.getDateThai(),
        'createdTime': DateTime.now(),
      });
    } else {
      String urlPicture = await FireStorageApi.uploadPhoto(image, 'Message');

      final newMessage = Message(
        user_id: my_account.user_id,
        username: my_account.name,
        message: urlPicture,
        type: type,
        time:
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        day: Utils.getDateThai(),
        seen: await checkUserStay(user_id) == chatLinkId ? 'yes' : 'no',
        createdAt: DateTime.now(),
      );
      await refMessages.add(newMessage.toJson());

      await FirebaseFirestore.instance
          .collection('chat_link')
          .doc(chatLinkId)
          .update({
        'receiver_id': user_id,
        'sender_id': my_account.user_id,
        'message': urlPicture,
        'unseen':
            await getCountSeen(chatLinkId.trim(), my_account.user_id.trim()),
        'type': type,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        'day': Utils.getDateThai(),
        'createdTime': DateTime.now(),
      });
    }

    final refUsers = FirebaseFirestore.instance.collection('user');
    await refUsers
        .doc(user_id)
        .update({UserModelField.createdTime: DateTime.now()});
  }

  static Future<int> getCountSeen(String chat_link_id, String user_id) async {
    final ref = await FirebaseFirestore.instance
        .collection('chats/$chat_link_id/messages')
        .where('user_id', isEqualTo: user_id)
        .where('seen', isEqualTo: 'no')
        .get();

    return ref.size;
  }

  static Future updateAllseen(String chatLinkId, String user_id) async {
    await FirebaseFirestore.instance
        .collection('chats/$chatLinkId/messages')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'seen': 'yes'});
      }
    });
  }

  static Future updateUserStay(String user_id, String stay) async {
    final refUsers = FirebaseFirestore.instance.collection('user');
    await refUsers.doc(user_id).update({'stay': stay});
  }

  static Future<UserModel> getUserModelFromUserId(String user_id) async {
    UserModel? user;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        final user_id = result.data()['user_id'];
        final email = result.data()['email'];
        final name = result.data()['name'];
        final surname = result.data()['surname'];
        final password = result.data()['password'];
        final tel = result.data()['tel'];
        final token = result.data()['token'];
        final type = result.data()['type'];
        final stay = result.data()['stay'];
        final photo = result.data()['photo'];
        final age = result.data()['age'];
        final address = result.data()['address'];
        final idcard = result.data()['idcard'];
        final gender = result.data()['gender'];

        final province = result.data()['province'];
        final amphure = result.data()['amphure'];
        final district = result.data()['district'];

        user = UserModel(
          user_id: user_id,
          email: email,
          name: name,
          password: password,
          tel: tel,
          token: token,
          type: type,
          stay: stay,
          photo: photo,
          address: address,
          age: age,
          gender: gender,
          idcard: idcard,
          surname: surname,
          province: province,
          amphure: amphure,
          district: district,
        );
      });
    });
    return user!;
  }

  static Future<String> getDataFromUserId(String user_id, String type) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()[type];
      });
    });
    return data!;
  }

  static Future<String> getPasswordFromEmail(String email) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['password'];
      });
    });
    return data!;
  }

  static Future<String> checkUserStay(String user_id) async {
    String? stay;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        stay = result.data()['stay'];
      });
    });

    return stay!;
  }

  static Future<String> getPasswordFromTel(String tel) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('tel', isEqualTo: tel)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['password'];
      });
    });
    return data!;
  }

  static Future<String> getEmailFormtel(String tel) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('tel', isEqualTo: tel)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        data = element.data()['email'];
      });
    });
    return data!;
  }
}
