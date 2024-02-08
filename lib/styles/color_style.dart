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
  //static const primaryTextColor = Color(0xFF474747);
  static const backgroundColor = Color(0xFF1E1E1E);
  static const secondaryBackgroundColor = Color(0xFF454545);
  static const textColor = Color(0xFFFFFFFF);
  static const lightTextColor = Color(0xFFE0E0E0);
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF000000);
}
