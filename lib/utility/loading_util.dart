import 'package:farm/styles/color_style.dart';
import 'package:flutter/material.dart';

class LoadingUtil {
  static showInButtonLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: ColorStyle.blackColor,
      ),
    );
  }
}
