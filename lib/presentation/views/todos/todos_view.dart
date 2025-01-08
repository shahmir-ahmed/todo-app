import 'package:flutter/material.dart';
import 'package:todo_app/presentation/views/todos/body/body.dart';

class TodosView extends StatelessWidget {
  TodosView({super.key, required this.type});

  String type;

  @override
  Widget build(BuildContext context) {
    return TodosBodyView(type: type,);
  }
}