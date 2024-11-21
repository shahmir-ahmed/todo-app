import 'package:flutter/material.dart';

class NavigationHelper {
  static pushScreen(context, screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  static popScreen(context) {
    Navigator.pop(context);
  }
}
