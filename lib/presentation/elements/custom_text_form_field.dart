import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../configurations/frontend_configs.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({super.key, required this.controller, this.textInputAction, this.keyboardType, required this.hintText, this.labelText, this.suffix, this.obscureText=false, this.isPassword, this.onSuffixTap});

  TextEditingController controller;
  TextInputAction? textInputAction;
  TextInputType? keyboardType;
  String hintText;
  String? labelText;
  dynamic suffix;
  VoidCallback? onSuffixTap;
  bool obscureText;
  bool? isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          floatingLabelBehavior: labelText==null ? null :
          FloatingLabelBehavior.always,
          floatingLabelStyle: labelText==null ? null :
          MaterialStateTextStyle.resolveWith(
                  (Set<MaterialState> states) {
                final Color color =
                states.contains(MaterialState.focused)
                    ? FrontendConfigs.kAppPrimaryColor
                    : const Color(0xFF757575);
                return TextStyle(color: color);
              }),
          hintStyle:
          const TextStyle(color: Color(0xFF757575)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          suffix: isPassword!=null ? isPassword! ? GestureDetector(
            onTap: onSuffixTap,
            child: suffix,
          ) : suffix : suffix,
          border: FrontendConfigs.authOutlineInputBorder,
          enabledBorder: FrontendConfigs.authOutlineInputBorder,
          focusedBorder: FrontendConfigs.authOutlineInputBorder.copyWith(
              borderSide: const BorderSide(
                  color: FrontendConfigs.kAppPrimaryColor))),
    );
  }
}
