import 'package:flutter/material.dart';
import 'package:todo_app/presentation/views/auth/login/login_view.dart';
import 'package:todo_app/presentation/views/home/home_view.dart';
import 'package:todo_app/presentation/wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Wrapper(),
    );
  }
}
