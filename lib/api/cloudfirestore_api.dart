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

  static Future<String> getTokenFromUserId(String userId) async {
    String token = '';

    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        token = result.data()['token'];
      }
    });

    return token;
  }

  static Future<String?> getUsername(String userId) async {
    String? username;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
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
    String? docId;
    await FirebaseFirestore.instance
        .collection('group_month')
        .where('month', isEqualTo: month)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        docId = result.data()['group_month_id'];
      });
    });

    return docId!;
  }

  static Future<String> getPhotoFromUserId(String userId) async {
    String? photo;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        photo = result.data()['photo'];
      });
    });

    return photo!;
  }

  static Future<UserModel> getUserfromComment(String userId) async {
    UserModel? myAccount;

    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
        .get();

    if (ref.size == 0) {
      myAccount = null;
      return myAccount!;
    } else {
      await FirebaseFirestore.instance
          .collection('user')
          .where('user_id', isEqualTo: userId)
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

    return myAccount!;
  }

  static Future updateAllTrashMonthInit(String userId) async {
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
      String comment, String placeId, String userId) async {
    final doc = FirebaseFirestore.instance.collection('comment').doc();
    await doc.set({
      'comment': comment,
      'comment_id': doc.id,
      'createdTime': DateTime.now(),
      'like': 0,
      'place_id': placeId,
      'user_id': userId,
    });
  }

  static Future setAverageRating(String petId) async {
    double sum = 0;

    final ref = await FirebaseFirestore.instance
        .collection('comment')
        .where('pet_id', isEqualTo: petId)
        .get();

    if (ref.size == 0) {
      await FirebaseFirestore.instance
          .collection('pet')
          .doc(petId)
          .update({'rating': "0"});
    } else {
      await FirebaseFirestore.instance
          .collection('comment')
          .where('pet_id', isEqualTo: petId)
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          sum = sum + result.data()['rating'];
        }
      });

      final average = (sum / ref.size).toStringAsFixed(1);
      print(average);

      await FirebaseFirestore.instance
          .collection('pet')
          .doc(petId)
          .update({'rating': double.parse(average)});
    }
  }

  static Future addFavoritePet(
      String petId, String userId, String type) async {
    if (type == 'add') {
      if (checkLikePet(petId, userId) == true) {
        return;
      }

      final doc = FirebaseFirestore.instance.collection('favorite').doc();
      await doc.set({
        'favorite_id': doc.id,
        'pet_id': petId,
        'user_id': userId,
        'time': DateTime.now(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('favorite')
          .doc(await getPetIdFromUserId(petId, userId))
          .delete();
    }
  }

  static Future<String> getPetIdFromUserId(
      String petId, String userId) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('favorite')
        .where('pet_id', isEqualTo: petId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['favorite_id'];
      });
    });
    return data!;
  }

  static Future<bool> checkLikePet(String petId, String userId) async {
    bool check;
    final ref = await FirebaseFirestore.instance
        .collection('favorite')
        .where('pet_id', isEqualTo: petId)
        .where('user_id', isEqualTo: userId)
        .get();

    ref.size == 0 ? check = false : check = true;
    return check;
  }

  static Future<bool> whoLikeComment(String commentId, String userId) async {
    bool check;
    final ref = await FirebaseFirestore.instance
        .collection('comment')
        .where('comment_id', isEqualTo: commentId)
        .where('who_like', arrayContainsAny: [userId]).get();

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

  static Stream<List<Message>> getMessages(String chatLinkId) =>
      FirebaseFirestore.instance
          .collection('chats/$chatLinkId/messages')
          .orderBy(MessageField.createdAt, descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList());

  static Future addChatLink(String userId, String senderId) async {
    late String chatLinkId1 = '', chatLinkId2 = '';
    final refUsers1 = FirebaseFirestore.instance
        .collection('chat_link')
        .where(
          'receiver_id',
          isEqualTo: userId,
        )
        .where(
          'sender_id',
          isEqualTo: senderId,
        );

    final refUsers2 = FirebaseFirestore.instance
        .collection('chat_link')
        .where(
          'receiver_id',
          isEqualTo: senderId,
        )
        .where(
          'sender_id',
          isEqualTo: userId,
        );

    final getChatLink1 = await refUsers1.get();
    final getChatLink2 = await refUsers2.get();
    if (getChatLink1.size == 0 && getChatLink2.size == 0) {
      final doc = FirebaseFirestore.instance.collection('chat_link').doc();
      final listUser = [];
      listUser.add(userId);
      listUser.add(senderId);
      await doc.set({
        'id': doc.id,
        'receiver_id': userId,
        'sender_id': senderId,
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
          chatLinkId1 = result.data()['id'];
        });
      });
      await refUsers2.get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          chatLinkId2 = result.data()['id'];
        });
      });

      String id = '$chatLinkId1 $chatLinkId2'.trim();
      return id;
    }
  }

  static Future uploadMessage(String userId, String message, File image,
      String type, UserModel myAccount) async {
    String? chatLinkId = await addChatLink(userId, myAccount.user_id);
    print('chatLinkId ' + chatLinkId!);
    final refMessages =
        FirebaseFirestore.instance.collection('chats/$chatLinkId/messages');

    if (type == 'text') {
      final newMessage = Message(
        user_id: myAccount.user_id,
        username: myAccount.name,
        message: message,
        type: type,
        time:
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        day: Utils.getDateThai(),
        seen: await checkUserStay(userId) == chatLinkId ? 'yes' : 'no',
        createdAt: DateTime.now(),
      );

      await refMessages.add(newMessage.toJson());

      await FirebaseFirestore.instance
          .collection('chat_link')
          .doc(chatLinkId)
          .update({
        'receiver_id': userId,
        'sender_id': myAccount.user_id,
        'message': message,
        'unseen':
            await getCountSeen(chatLinkId.trim(), myAccount.user_id.trim()),
        'type': type,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        'day': Utils.getDateThai(),
        'createdTime': DateTime.now(),
      });
    } else {
      String urlPicture = await FireStorageApi.uploadPhoto(image, 'Message');

      final newMessage = Message(
        user_id: myAccount.user_id,
        username: myAccount.name,
        message: urlPicture,
        type: type,
        time:
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        day: Utils.getDateThai(),
        seen: await checkUserStay(userId) == chatLinkId ? 'yes' : 'no',
        createdAt: DateTime.now(),
      );
      await refMessages.add(newMessage.toJson());

      await FirebaseFirestore.instance
          .collection('chat_link')
          .doc(chatLinkId)
          .update({
        'receiver_id': userId,
        'sender_id': myAccount.user_id,
        'message': urlPicture,
        'unseen':
            await getCountSeen(chatLinkId.trim(), myAccount.user_id.trim()),
        'type': type,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().length == 1 ? '0${DateTime.now().minute}' : DateTime.now().minute.toString()} น.',
        'day': Utils.getDateThai(),
        'createdTime': DateTime.now(),
      });
    }

    final refUsers = FirebaseFirestore.instance.collection('user');
    await refUsers
        .doc(userId)
        .update({UserModelField.createdTime: DateTime.now()});
  }

  static Future<int> getCountSeen(String chatLinkId, String userId) async {
    final ref = await FirebaseFirestore.instance
        .collection('chats/$chatLinkId/messages')
        .where('user_id', isEqualTo: userId)
        .where('seen', isEqualTo: 'no')
        .get();

    return ref.size;
  }

  static Future updateAllseen(String chatLinkId, String userId) async {
    await FirebaseFirestore.instance
        .collection('chats/$chatLinkId/messages')
        .where('user_id', isEqualTo: userId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({'seen': 'yes'});
      }
    });
  }

  static Future updateUserStay(String userId, String stay) async {
    final refUsers = FirebaseFirestore.instance.collection('user');
    await refUsers.doc(userId).update({'stay': stay});
  }

  static Future<UserModel> getUserModelFromUserId(String userId) async {
    UserModel? user;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        final userId = result.data()['user_id'];
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
          user_id: userId,
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

  static Future<String> getDataFromUserId(String userId, String type) async {
    String? data;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
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

  static Future<String> checkUserStay(String userId) async {
    String? stay;
    await FirebaseFirestore.instance
        .collection('user')
        .where('user_id', isEqualTo: userId)
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
