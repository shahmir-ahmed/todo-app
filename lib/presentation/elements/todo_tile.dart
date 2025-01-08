import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:todo_app/presentation/elements/todo_details_bottom_sheet.dart';

import '../../configurations/frontend_configs.dart';

class TodoTile extends StatelessWidget {
  TodoTile({super.key, required this.todo});

  TodoModel todo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showTodoDetailsBottomSheet(context, todo);
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.1),
            ),
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: ListTile(
              // leading: Text(
              //   '${index + 1}',
              //   style: const TextStyle(fontSize: 14),
              // ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      todo.description ?? '',
                    ),
                  )
                ],
              ),
              subtitle:
              // Text(todo.createdAt!)
                Text(
                DateFormat('d MMM, y - h:mm a')
                    .format(DateTime.parse(todo.createdAt!).toLocal())
                    .toString(),
                style: const TextStyle(fontSize: 12),
              )
              /*Text(
                      '${DateTime.tryParse(todo.createdAt ?? '')!.day}-${DateTime.tryParse(todo.createdAt ?? '')!.month}-${DateTime.tryParse(todo.createdAt ?? '')!.year}, ${DateTime.tryParse(todo.createdAt ?? '')!.hour}:${DateTime.tryParse(todo.createdAt ?? '')!.minute}')*/
              ,
            )));
  }
}
