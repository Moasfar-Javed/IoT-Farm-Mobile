import 'package:farm/styles/color_style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: ColorStyle.primaryMaterialColor[200],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // static showCustomSnackbar(
  //     {required BuildContext context,
  //     required String contentText,
  //     SnackBarType type = SnackBarType.fail}) {
  //   IconSnackBar.show(
  //     context: context,
  //     snackBarType: type,
  //     label: contentText,
  //   );
  // }

  static void showActionAlertDialog(
      String title, String msg, BuildContext context, onButtonClicked) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title,
                  style: const TextStyle(
                    fontFamily: "ClassicSans",
                  )),
              content: Text(msg,
                  style: const TextStyle(
                    fontFamily: "ClassicSans",
                  )),
              actions: [
                TextButton(
                  child: Text("Cancel",
                      style: TextStyle(
                        color: ColorStyle.primaryColor,
                        fontFamily: "ClassicSans",
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("OK",
                      style: TextStyle(
                        color: ColorStyle.primaryColor,
                        fontFamily: "ProductSans",
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onButtonClicked();
                  },
                )
              ],
            ));
  }
}
