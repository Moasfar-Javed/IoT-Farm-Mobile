import 'package:flutter/material.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/views/splash_screen.dart';

class NavigatorRoutes {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case initialRoute:
        page = const SplashScreen();
        break;
      default:
        page = const SplashScreen();
        break;
    }

    return MaterialPageRoute(builder: (_) => page);
  }
}
