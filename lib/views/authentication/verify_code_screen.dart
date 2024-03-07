import 'dart:async';

import 'package:farm/keys/route_keys.dart';
import 'package:farm/models/api/user/user_details.dart';
import 'package:farm/models/api/user/user_response.dart';
import 'package:farm/models/screen_args/verify_code_screen_args.dart';
import 'package:farm/services/user_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/auth_util.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';

class VerifyCodeScreen extends StatefulWidget {
  final VerifyCodeScreenArgs arguments;
  const VerifyCodeScreen({super.key, required this.arguments});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isCodeInputValid = false;
  final focusNode = FocusNode();

  late Timer _timer;
  int _countdown = 120;

  bool isLoadingVerifyButton = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  UserService userService = UserService();

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final defaultPinTheme = const PinTheme(
    width: 50,
    height: 50,
    textStyle: TextStyle(
        color: Color.fromRGBO(70, 69, 66, 1),
        fontSize: 30,
        fontWeight: FontWeight.w400),
  );

  final cursor = Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 21,
      height: 1,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(137, 146, 160, 1),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  _verifyOtp() async {
    setState(() {
      isLoadingVerifyButton = true;
    });
    UserCredential? userCredential = await AuthUtil.signInWithPhoneNumber(
            widget.arguments.phoneNumber,
            _codeController.text,
            widget.arguments.verificationId)
        .catchError((e) {
      switch (e.code) {
        case "invalid-verification-code":
          ToastUtil.showToast("Please enter a valid code sent to you");
          break;
        case "invalid-credential":
          ToastUtil.showToast("Please enter a valid phone number");
          break;
        case "invalid-verification-id":
          ToastUtil.showToast("Verification failed, please try again");
          break;
        default:
          ToastUtil.showToast(e.code);
          break;
      }
      return null;
    });

    if (userCredential != null) {
      String emailOrPhone = userCredential.user!.email != null
          ? userCredential.user!.email!
          : userCredential.user!.phoneNumber!;
      _signInToServer(userCredential.user!.uid, emailOrPhone);
    }
  }

  _signInWithPhone() async {
    await AuthUtil.verifyPhoneNumber(widget.arguments.phoneNumber,
        (userCredential) {
      if (userCredential != null) {
        String emailOrPhone = userCredential.user!.email != null
            ? userCredential.user!.email!
            : userCredential.user!.phoneNumber!;
        _signInToServer(userCredential.user!.uid, emailOrPhone);
      }
    }, (errorCode) {
      switch (errorCode) {
        case "invalid-verification-code":
          ToastUtil.showToast("Please enter a valid code");
          break;
        case "invalid-credential":
          ToastUtil.showToast("Please enter a valid phone number");
          break;
        case "invalid-verification-id":
          ToastUtil.showToast("Verification failed, please try again");
          break;
        default:
          ToastUtil.showToast(errorCode);
          break;
      }
    }, (verificationId, resendToken) {
      ToastUtil.showToast("Code resent to ${widget.arguments.phoneNumber}");
      startTimer();
    }, (verificationId) {
      // ToastUtil.showToast("Your request timed out, please try again later");
    });
  }

  void startTimer() {
    _countdown = 120;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_countdown < 1) {
            timer.cancel();
          } else {
            _countdown -= 1;
          }
        });
      },
    );
  }

  _moveToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
  }

  Future<String?> _getFcmToken() async {
    await _firebaseMessaging.requestPermission();
    return await _firebaseMessaging.getToken();
  }

  _signInToServer(String uid, String emailOrNumber) async {
    String? token = await _getFcmToken();
    userService.signInUser(uid, emailOrNumber, token).then((value) {
      setState(() {
        isLoadingVerifyButton = false;
      });
      if (value.error == null) {
        UserResponse userResponse = value.snapshot;
        if (userResponse.success ?? false) {
          UserDetails user = userResponse.data!.user!;
          _saveUserData(user);
          _moveToHome();
        } else {
          ToastUtil.showToast(userResponse.message ?? "");
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
    Duration duration = Duration(seconds: _countdown);
    String timerText = formatDuration(duration);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AbsorbPointer(
          absorbing: isLoadingVerifyButton,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: double.maxFinite,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorStyle.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 5,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            splashColor: Colors.transparent,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: ColorStyle.whiteColor,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                            height: 150,
                            width: 150,
                            child:
                                SvgPicture.asset("assets/svgs/sms_image.svg")),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.arguments.phoneNumber,
                        style: const TextStyle(
                            color: ColorStyle.lightTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "We've sent you a code on your phone number to verify it is really you",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorStyle.lightTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Pinput(
                        length: 6,
                        controller: _codeController,
                        focusNode: focusNode,
                        autofocus: true,
                        defaultPinTheme: defaultPinTheme.copyWith(
                            decoration: BoxDecoration(
                          color: ColorStyle.backgroundColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(300),
                        )),
                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsRetrieverApi,
                        focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: BoxDecoration(
                              color:
                                  ColorStyle.backgroundColor.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                                color: ColorStyle.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.w600)),
                        submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: BoxDecoration(
                              color: ColorStyle.lightTextColor,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            textStyle: const TextStyle(
                                color: ColorStyle.primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.w600)),
                        onChanged: (value) {
                          if (value.length < 6) {
                            setState(() {
                              isCodeInputValid = false;
                            });
                          } else {
                            setState(() {
                              isCodeInputValid = true;
                            });
                          }
                        },
                        onCompleted: (value) {
                          setState(() {
                            isCodeInputValid = true;
                          });
                          _verifyOtp();
                        },
                        showCursor: true,
                        cursor: cursor,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: CustomRoundedButton(
                          "Verify",
                          () {
                            if (isCodeInputValid) {
                              _verifyOtp();
                            } else {
                              ToastUtil.showToast(
                                  "Please enter a valid code sent to you");
                            }
                            // Navigator.of(context).pushNamed(verifyEmailRoute);
                          },
                          widgetButton: isLoadingVerifyButton
                              ? LoadingUtil.showInButtonLoader()
                              : null,
                          borderColor: ColorStyle.whiteColor,
                          buttonBackgroundColor: isCodeInputValid
                              ? ColorStyle.whiteColor
                              : Colors.transparent,
                          textColor: isCodeInputValid
                              ? ColorStyle.blackColor
                              : ColorStyle.whiteColor,
                          waterColor: Colors.black12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          if (_countdown == 0) {
                            _signInWithPhone();
                          }
                        },
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "Did not recieve a code? ",
                                style: const TextStyle(
                                    color: ColorStyle.lightTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                    text: _countdown == 0
                                        ? "Resend Code"
                                        : "Resend in $timerText",
                                    style: TextStyle(
                                        decoration: _countdown == 0
                                            ? TextDecoration.underline
                                            : null,
                                        color: ColorStyle.lightTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  )
                                ])),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
