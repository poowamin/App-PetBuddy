import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/favorite.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/pet/pet_detail.dart';
import 'package:pet_buddy/widget/heart_animation_widget.dart';

class FavoriteWidget extends StatefulWidget {
  final Favorite favorite;
  final UserModel my_account;

  const FavoriteWidget({
    Key? key,
    required this.favorite,
    required this.my_account,
  }) : super(key: key);

  @override
  _FavoriteWidget createState() => _FavoriteWidget();
}

class _FavoriteWidget extends State<FavoriteWidget> {
  bool isLiked = true;

  @override
  Widget build(BuildContext context) {
    final icon = isLiked ? Icons.favorite : Icons.favorite_outline;
    final color = isLiked ? Colors.red : Colors.white;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('pet')
          .doc(widget.favorite.pet_id)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError || (snapshot.hasData && !snapshot.data!.exists)) {
          return const Text("");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          final pet = Pet(
            address: data['address'],
            category: data['category'],
            detail: data['detail'],
            location: data['location'],
            name: data['name'],
            pet_id: data['pet_id'],
            photo: data['photo'],
            rating: double.parse(data['rating'].toString()),
            time: data['time'],
            user_id: data['user_id'],
            pdphotos: data['PDphotos'],
          );

          return GestureDetector(
              onTap: () async {
                bool like = await CloudFirestoreApi.checkLikePet(
                    widget.favorite.pet_id, widget.my_account.user_id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PetDetail(
                          pet: pet, like: like, my_account: widget.my_account)),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      data['photo'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 5,
                    right: 5,
                    child: Text(data['name'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                  ),
                  Positioned(
                      top: 3,
                      right: 3,
                      child: HeartAnimationWidget(
                        alwaysAnimate: true,
                        isAnimating: isLiked,
                        child: IconButton(
                            onPressed: () => setState(() {
                                  // isLiked = !isLiked;

                                  // isLiked
                                  //     ? CloudFirestoreApi.addFavoritePlace(
                                  //         data['place_id'],
                                  //         widget.my_account.user_id,
                                  //         'add')
                                  //     : CloudFirestoreApi.addFavoritePlace(
                                  //         data['place_id'],
                                  //         widget.my_account.user_id,
                                  //         'delete');

                                  CloudFirestoreApi.addFavoritePet(
                                      data['pet_id'],
                                      widget.my_account.user_id,
                                      'delete');
                                }),
                            icon: Icon(
                              icon,
                              color: color,
                              size: 28,
                            )),
                      ))
                ],
              ));
        }
        return const Text("");
      },
    );
  }
}
