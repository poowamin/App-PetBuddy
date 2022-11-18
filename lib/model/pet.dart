import 'package:cloud_firestore/cloud_firestore.dart';

class PetField {
  static const createdTime = 'time';
}

class Pet {
  String address;
  String category;
  String detail;
  GeoPoint location;
  String name;
  String pet_id;
  String photo;
  double rating;
  Timestamp time;
  String user_id;
  String pdphotos;

  Pet({
    required this.address,
    required this.category,
    required this.detail,
    required this.location,
    required this.name,
    required this.pet_id,
    required this.photo,
    required this.rating,
    required this.time,
    required this.user_id,
    required this.pdphotos,
  });

  static Pet fromJson(Map<String, dynamic> json) => Pet(
        address: json['address'],
        category: json['category'],
        detail: json['detail'],
        location: json['location'],
        name: json['name'],
        pet_id: json['pet_id'],
        photo: json['photo'],
        rating: double.parse(json['rating'].toString()),
        time: json['time'],
        user_id: json['user_id'],
        pdphotos: json['PDphotos'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'category': category,
        'detail': detail,
        'location': location,
        'name': name,
        'pet_id': pet_id,
        'photo': photo,
        'rating': rating.toString(),
        'time': time,
        'user_id': user_id,
        'PDphotos': pdphotos,
      };
}
