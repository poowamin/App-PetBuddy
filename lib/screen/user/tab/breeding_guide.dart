import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_buddy/model/petbreed.dart';

class BreedingGuide extends StatefulWidget {
  const BreedingGuide({super.key});

  @override
  State<BreedingGuide> createState() => _BreedingGuideState();
}

class _BreedingGuideState extends State<BreedingGuide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: SizedBox(
            width: 360,
            height: 560,
            child: StreamBuilder<List<Petbreed>>(
                stream: readBreeding(),
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Something went wrong! ${snapshot.error}',
                      style: GoogleFonts.kanit(),
                    );
                  } else if (snapshot.hasData) {
                    final petbreed = snapshot.data!;

                    return ListView(
                      children: petbreed.map(buildPetbreed).toList(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
          ),
        ),
      ),
    );
  }

  Widget buildPetbreed(Petbreed petbreed) => ListTile(
        title: Text(
          petbreed.breeding,
          style: GoogleFonts.kanit(),
        ),
      );

  Stream<List<Petbreed>> readBreeding() => FirebaseFirestore.instance
      .collection('breeding')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Petbreed.fromJson(doc.data())).toList());
}
