import 'package:flutter/material.dart';

import '../../configurations/frontend_configs.dart';

class AppButton extends StatelessWidget {
  AppButton({super.key, required this.onPressed, required this.child});

  VoidCallback onPressed;
  Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: FrontendConfigs.kAppPrimaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(16)),
        ),
      ),
      child: child,
    );
  }
}
