import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/application/todo_provider.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/presentation/views/auth/login/login_view.dart';
import 'package:todo_app/presentation/views/home/home_view.dart';
import 'package:todo_app/presentation/wrapper.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      // ChangeNotifierProvider(
      //   create: (_) => TodoProvider(),
      // ),
      ChangeNotifierProvider(create: (_) => UserProvider())
    ], child: const MyApp()),
  );
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
