import 'dart:ui';

import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/application/shared_prefs_helper.dart';
import 'package:todo_app/application/todo_provider.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:todo_app/presentation/elements/todo_details_bottom_sheet.dart';
import 'package:todo_app/presentation/elements/todo_tile.dart';

import '../../../../infrastructure/services/todo.dart';

class TodosBodyView extends StatefulWidget {
  TodosBodyView({super.key, required this.type});

  String type;

  @override
  State<TodosBodyView> createState() => _TodosBodyViewState();
}

class _TodosBodyViewState extends State<TodosBodyView> {
  bool _isLoading = false;

  List<TodoModel>? completedTodos;
  List<TodoModel>? inCompletedTodos;

  void _toggleIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  getCompletedTodos(String token) async {
    final result = await TodoServices().getTodosByType(token, 'completed');

    if (result != null) {
      completedTodos = result;
      // sort by createdAt
      completedTodos!.sort((a, b) =>
          DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
    } else {
      floatingSnackBar(
          message: 'Error loading completed todos. Please try again later',
          context: context);
    }
    _toggleIsLoading();
  }

  getInCompletedTodos(String token) async {
    final result = await TodoServices().getTodosByType(token, 'incomplete');

    if (result != null) {
      inCompletedTodos = result;
      // sort by createdAt
      inCompletedTodos!.sort((a, b) =>
          DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
    } else {
      floatingSnackBar(
          message: 'Error loading incompleted todos. Please try again later',
          context: context);
    }
    _toggleIsLoading();
  }

  @override
  void initState() {
    // TODO: implement initState
    _toggleIsLoading();

    // SharedPrefsHelper().getToken().then((val) {
    final token =
        Provider.of<UserProvider>(context, listen: false).getUser!.token!;
    if (widget.type == 'Completed') {
      getCompletedTodos(token);
    } else {
      getInCompletedTodos(token);
    }
    // });

    /*
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.getUser!.token;

      if (widget.type == 'Completed') {
        getCompletedTodos(token!);
      } else {
        getInCompletedTodos(token!);
      }

      /*
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);

      if (widget.type == 'Completed') {
        // if (todoProvider.completedTodos
        //     .isEmpty) {
        todoProvider.getCompletedTodos(token!, context);
        // }
      } else {
        // if (todoProvider
        //     .inCompletedTodos
        //     .isEmpty) {
        todoProvider.getInCompletedTodos(token!, context);
        // }
      }
      */
    });
     */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('build'); // will run only once
    return Scaffold(
        backgroundColor: FrontendConfigs.whiteColor,
        appBar: AppBar(
          title: Text('${widget.type} todos'),
          backgroundColor: FrontendConfigs.whiteColor,
          scrolledUnderElevation: 0.0,
        ),
        body: _getBody());
  }

  _getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Text(DateTime.now()
            //     .toString()), // will not run again when provider is updated
            // Consumer<TodoProvider>(
            //   // consume todos provider here
            //   builder:
            //       (BuildContext context, TodoProvider value, Widget? child) {
            //     return
            _isLoading
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : widget.type == "Completed"
                    ? completedTodos!.isEmpty
                        ? _getNotFoundText()
                        : _getTodoList()
                    : inCompletedTodos!.isEmpty
                        ? _getNotFoundText()
                        : _getTodoList()
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  _getNotFoundText() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text('No ${widget.type.toLowerCase()} todos found.'),
      ),
    );
  }

  _getTodoList() {
    return ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.type == 'Completed'
            ? completedTodos!.length
            : inCompletedTodos!.length,
        itemBuilder: (context, index) {
          final todo = widget.type == 'Completed'
              ? completedTodos![index]
              : inCompletedTodos![index];
          return TodoTile(todo: todo,);
        });
  }
}
