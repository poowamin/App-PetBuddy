class UserModelField {
  static const createdTime = 'time';
}

class UserModel {
  final String address;
  final String age;
  final String email;
  final String gender;
  final String idcard;
  final String name;
  final String password;
  final String photo;
  final String stay;
  final String surname;
  final String tel;
  final String token;
  final String type;
  final String user_id;
  //final DateTime createdTime;

  final String? province;
  final String? amphure;
  final String? district;

  UserModel({
    required this.address,
    required this.age,
    required this.email,
    required this.name,
    required this.gender,
    required this.idcard,
    required this.password,
    //required this.gender,
    required this.stay,
    required this.surname,
    required this.tel,
    required this.token,
    required this.type,
    required this.photo,
    required this.user_id,
    //required this.createdTime

    required this.province,
    required this.amphure,
    required this.district,
  });

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        address: json['address'],
        age: json['age'],
        email: json['email'],
        gender: json['gender'],
        idcard: json['idcard'],
        password: json['password'],
        name: json['name'],
        stay: json['stay'],
        surname: json['surname'],
        tel: json['tel'],
        token: json['token'],
        type: json['type'],
        photo: json['photo'],
        user_id: json['user_id'],
        //createdTime: toDateTime(json['createdTime']),

        province: json['province'],
        amphure: json['amphure'],
        district: json['district'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'age': age,
        'email': email,
        'idcard': idcard,
        'password': password,
        'name': name,
        'gender': gender,
        'stay': stay,
        'surname': surname,
        'tel': tel,
        'token': token,
        'type': type,
        'photo': photo,
        'user_id': user_id,
        //'createdTime': fromDateTimeToJson(createdTime),

        'province': province,
        'amphure': amphure,
        'district': district,
      };
}
