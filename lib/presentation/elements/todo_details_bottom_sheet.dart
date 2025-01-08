import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/infrastructure/models/todo.dart';

import '../../configurations/frontend_configs.dart';

showTodoDetailsBottomSheet(context, TodoModel todo){
  return showModalBottomSheet(
    constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height*0.38),
      showDragHandle: true,
      backgroundColor: FrontendConfigs.whiteColor,
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: const Text('Todo details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    const Text('ID: ', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(todo.id.toString().substring(todo.id.toString().length-5)),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text('Description: ', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(todo.description.toString()),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text('Completed: ', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(todo.complete ?? false ? 'Yes' : 'No', style: TextStyle(color: todo.complete ?? false ? Colors.green : Colors.red),),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text('Creation date, time: ', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(DateFormat('d MMMM, y, h:mm a')
                        .format(DateTime.parse(todo.createdAt!).toLocal())
                        .toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ));
}