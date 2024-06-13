import 'package:farm/styles/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? icon;
  final Widget? trailing;
  final bool obscuretext;
  final Color borderColor;
  final Color fieldColor;
  final TextInputType keyboardType;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;
  final Color textColor;
  final double verticalFieldPadding;
  final Color cursorColor;
  final BorderRadius? customRadius;
  final double borderWidth;
  final FocusNode? focusNode;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Function? onChanged;
  const CustomTextField(
      {super.key,
      required this.controller,
      this.autofocus = false,
      this.hint = '',
      this.hintStyle,
      this.icon,
      this.trailing,
      this.obscuretext = false,
      this.borderColor = ColorStyle.secondaryPrimaryColor,
      this.keyboardType = TextInputType.text,
      this.maxLength,
      this.maxLines = 1,
      this.inputFormatters,
      this.fieldColor = ColorStyle.whiteColor,
      this.textColor = ColorStyle.textColor,
      this.verticalFieldPadding = 20,
      this.cursorColor = ColorStyle.primaryColor,
      this.customRadius,
      this.borderWidth = 1,
      this.focusNode,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: obscuretext,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        autofocus: autofocus,
        cursorColor: cursorColor,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value); // Call the onChanged function with the value
          }
        },
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintStyle:
              hintStyle ?? const TextStyle(color: ColorStyle.lightTextColor),
          filled: true,
          fillColor: fieldColor,
          prefixIcon: icon,
          suffixIcon: trailing,
          //hintText: hint,
          label: Text(
            hint,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorStyle.lightTextColor),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 15, vertical: verticalFieldPadding),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: borderColor.withOpacity(0.6), width: borderWidth),
            borderRadius: customRadius != null
                ? customRadius!
                : BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: borderWidth),
            borderRadius: customRadius != null
                ? customRadius!
                : BorderRadius.circular(12),
          ),
        ));
  }
}
