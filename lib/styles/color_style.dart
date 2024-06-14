import 'package:flutter/material.dart';

class ColorStyle {
  static const Map<int, Color> customSwatchColor = {
    50: Color.fromRGBO(46, 139, 87, .1),
    100: Color.fromRGBO(46, 139, 87, .2),
    200: Color(0xFF2E8B57),
    300: Color.fromRGBO(46, 139, 87, .4),
    400: Color.fromRGBO(46, 139, 87, .5),
    500: Color.fromRGBO(46, 139, 87, .6),
    600: Color.fromRGBO(46, 139, 87, .7),
    700: Color.fromRGBO(46, 139, 87, .8),
    800: Color.fromRGBO(46, 139, 87, .9),
    900: Color.fromRGBO(46, 139, 87, 1),
  };

  static MaterialColor primaryMaterialColor =
      const MaterialColor(0xFF2E8B57, customSwatchColor);

  static const primaryColor = Color(0xFF2E8B57);
  static const lightPrimaryColor = Color(0xFF61BC84);
  static const darkPrimaryColor = Color(0xFF345E37);
  static const alertColor = Color.fromARGB(255, 171, 194, 72);
  static const backgroundColor = Color(0xFFFFFFFF);
  static const secondaryBackgroundColor = Color(0xFFFFFFFF);
  static const secondaryPrimaryColor = Color.fromARGB(255, 78, 77, 77);
  static const textColor = Color(0xFF000000);
  static const lightTextColor = Color(0xFF000000);
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF000000);

  static const warningColor = Color.fromARGB(255, 178, 193, 15);
  static const errorColor = Color.fromARGB(255, 197, 58, 53);
}
