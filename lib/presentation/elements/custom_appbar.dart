import 'package:flutter/material.dart';
import 'package:todo_app/configurations/frontend_configs.dart';

PreferredSizeWidget customAppBar({required String title}){
  return AppBar(
    scrolledUnderElevation: 0.0,
    backgroundColor: FrontendConfigs.whiteColor,
    title: Text(title),
  );
}