import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Myconstant {
  // Colors
  static Color primary = const Color.fromARGB(255, 231, 151, 151);
  static Color dark = const Color.fromARGB(255, 62, 5, 5);
  static Color light = const Color.fromARGB(255, 250, 126, 115);

  // fonts
  TextStyle textStyle1() => GoogleFonts.kanit(
        fontSize: 16,
        color: dark,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle2() => GoogleFonts.sarabun(
        fontSize: 14,
        color: dark,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle3() => GoogleFonts.kanit(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle4() => GoogleFonts.kanit(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle5() => GoogleFonts.kanit(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle6() => GoogleFonts.kanit(
        fontSize: 18,
        color: const Color.fromARGB(255, 201, 171, 5),
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      );

  TextStyle textStyle7() => GoogleFonts.kanit(
        fontSize: 16,
        color: Colors.blueGrey,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );

  TextStyle testStyle3() => GoogleFonts.prompt(
        fontSize: 14,
        color: Colors.black45,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );

  TextStyle textinput1() => GoogleFonts.openSans(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );

  TextStyle textinput2() => GoogleFonts.openSans(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
      );
}
