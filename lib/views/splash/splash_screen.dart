import 'package:farm/keys/route_keys.dart';
import 'package:farm/models/api/user/user_details.dart';
import 'package:farm/models/api/user/user_response.dart';
import 'package:farm/services/user_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserService userService = UserService();

  @override
  initState() {
    print(PrefUtil().getUserToken);
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
    if (PrefUtil().getUserLoggedIn) {
      _refreshUserDetails();
    } else {
      _exitFullScreen();
      Future.delayed(const Duration(milliseconds: 1500)).then((value) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(signinRoute, (e) => false);
      });
    }
  }

  _refreshUserDetails() async {
    userService.refreshUserDetails().then((value) {
      _exitFullScreen();
      if (value.error == null) {
        UserResponse userResponse = value.snapshot;
        if (userResponse.success ?? false) {
          UserDetails user = userResponse.data!.user!;
          _saveUserData(user);
          Navigator.of(context)
              .pushNamedAndRemoveUntil(homeRoute, (e) => false);
        } else {
          ToastUtil.showToast("Session expired");
          Navigator.of(context)
              .pushNamedAndRemoveUntil(signinRoute, (e) => false);
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
      }
    });
  }

  _saveUserData(UserDetails user) {
    PrefUtil().setUserId = user.fireUid ?? "";
    PrefUtil().setUserToken = user.authToken ?? "";
    PrefUtil().setUserPhoneOrEmail = user.phoneOrEmail ?? "";
    PrefUtil().setUserRole = user.role ?? "";
    PrefUtil().setUserLoggedIn = true;
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
