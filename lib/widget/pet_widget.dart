import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/api/cloudfirestore_api.dart';
import 'package:pet_buddy/model/pet.dart';
import 'package:pet_buddy/model/user_model.dart';
import 'package:pet_buddy/screen/user/pet/pet_detail.dart';

class PetWidget extends StatelessWidget {
  final Pet pet;
  final UserModel my_account;

  const PetWidget({
    Key? key,
    required this.pet,
    required this.my_account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: GestureDetector(
            onTap: () async {
              bool like = await CloudFirestoreApi.checkLikePet(
                  pet.pet_id, my_account.user_id);

              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PetDetail(
                        pet: pet, like: like, my_account: my_account)),
              );
            },
            child: Card(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: pet.photo,
                    imageBuilder: (context, imageProvider) => Image.network(
                      pet.photo,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 152,
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/no_image.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 152,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pet.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.kanit(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Color.fromARGB(255, 201, 171, 5)),
                                Text(
                                  ' (${pet.rating}/5)',
                                  style: GoogleFonts.kanit(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Text(
                                pet.address,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.kanit(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('user')
                              .doc(pet.user_id)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError &&
                                (snapshot.hasData && !snapshot.data!.exists)) {
                              return const Text('');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'by ${data['name']}',
                                    style: GoogleFonts.kanit(),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
