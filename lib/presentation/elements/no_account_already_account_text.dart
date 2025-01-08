import 'package:flutter/material.dart';

import '../../application/navigation_helper.dart';
import '../../configurations/frontend_configs.dart';

class NoAccountAlreadyAccountText extends StatelessWidget {
  NoAccountAlreadyAccountText({
    Key? key,
    required this.primaryText,
    required this.redirectText,
    required this.onTap
  }) : super(key: key);

  String primaryText, redirectText;
  VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          primaryText,
          style: const TextStyle(color: Color(0xFF757575)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            redirectText,
            style: const TextStyle(
              color: FrontendConfigs.kAppPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}