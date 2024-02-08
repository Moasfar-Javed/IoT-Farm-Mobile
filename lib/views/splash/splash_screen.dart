import 'package:farm/keys/route_keys.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  initState() {
    _moveToFullScreen();
    _moveToNextScreen();

    super.initState();
  }

  _moveToFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  _moveToNextScreen() {
    Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      _exitFullScreen();
      if (PrefUtil().getUserLoggedIn) {
        Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (e) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(signinRoute, (e) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.backgroundColor,
      body: Center(
        child: SizedBox(
            height: 100,
            width: 100,
            child: SvgPicture.asset("assets/svgs/app_icon.svg")),
      ),
    );
  }
}
