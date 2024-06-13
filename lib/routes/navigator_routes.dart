import 'package:farm/models/screen_args/crop_args.dart';
import 'package:farm/models/screen_args/verify_code_screen_args.dart';
import 'package:farm/views/authentication/sign_in_screen.dart';
import 'package:farm/views/authentication/verify_code_screen.dart';
import 'package:farm/views/crop/detail/crop_detail_screen.dart';
import 'package:farm/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/views/splash/splash_screen.dart';

class NavigatorRoutes {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case initialRoute:
        page = const SplashScreen();
        break;
      case signinRoute:
        page = const SignInScreen();
        break;
      case verifyCodeRoute:
        page = VerifyCodeScreen(
            arguments: settings.arguments as VerifyCodeScreenArgs);
        break;
      case homeRoute:
        page = const HomeScreen();
        break;
      case cropDetailsRoute:
        page = CropDetailScreen(arguments: settings.arguments as CropArgs);
        break;
      default:
        page = const SplashScreen();
        break;
    }

    return MaterialPageRoute(builder: (_) => page);
  }
}
