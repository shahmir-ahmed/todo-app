import 'dart:developer';

import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:todo_app/application/navigation_helper.dart';
import 'package:todo_app/application/shared_prefs.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/models/task.dart';
import 'package:todo_app/infrastructure/services/task.dart';
import 'package:todo_app/presentation/views/auth/login/login_view.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _TodoAppViewBodyState();
}

class _TodoAppViewBodyState extends State<HomeViewBody> {
  List<TaskModel>? _tasks;
  // final Storage storage = Storage();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  String token = '';
  bool loggingOut = false;
  bool isLoading = false;

  Future _addNewTask(String title) async {
    final result = await TaskServices().addUpdateTodo(token, {'description': title}, forAdd: true);

    toggleIsLoading();

    if (result != null) {
      if (result == 'success') {
        floatingSnackBar(message: "Task added successfully.", context: context);

        final newTask = TaskModel(
          complete: false,
          description: title,
        );

        setState(() {
          _tasks!.add(newTask);
        });

        _listKey.currentState?.insertItem(_tasks!.length - 1);
      } else {
        floatingSnackBar(
            message: "Error adding task. Please try again later.",
            context: context);
      }
    } else {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    }

    // storage.writeTasks(_tasks);
  }

  Future _toggleTaskCompleted(int index, bool newStatus) async {
    final result = await TaskServices().addUpdateTodo(token, {'description': _tasks![index].description,'complete': newStatus}, forAdd: false, todoId: _tasks![index].id);

    toggleIsLoading();

    if (result != null) {
      if (result == 'success') {
        floatingSnackBar(message: "Task marked as ${newStatus? 'completed' : 'uncompleted'}.", context: context);

        setState(() {
          _tasks![index].toggleCompleted();
        });
      } else {
        floatingSnackBar(
            message: "Error updating task status. Please try again later.",
            context: context);
      }
    } else {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    }

    // storage.writeTasks(_tasks);
  }

  void _deleteTask(int index) {
    TaskModel removedTask = _tasks![index];

    setState(() {
      _tasks!.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(removedTask.description!,
                  style:
                      const TextStyle(decoration: TextDecoration.lineThrough)),
              leading: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 250),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedTask.description!} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _tasks!.insert(index, removedTask);
            });
            _listKey.currentState?.insertItem(index);
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // storage.writeTasks(_tasks);
  }

  void _showAddNewTaskDialog(BuildContext context) {
    String taskDesc = '';

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: FrontendConfigs.whiteColor,
            title: const Text('Add New Task'),
            content: TextField(
              onChanged: (value) {
                taskDesc = value;
              },
              decoration: const InputDecoration(
                labelText: 'Task Description',
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  if (taskDesc.trim().isNotEmpty) {
                    toggleIsLoading();
                    _addNewTask(taskDesc);
                    Navigator.of(ctx).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  _editTask(index) {
    // show edit task screen
    // pass this task to edit task screen
    final task = _tasks![index];
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    return Card(
      key: Key(_tasks![index].id ?? ''),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          _tasks![index].description!,
          style: TextStyle(
              decoration:
                  _tasks![index].complete! ? TextDecoration.lineThrough : null),
        ),
        leading: Icon(
          _tasks![index].complete!
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: _tasks![index].complete! ? Colors.green : null,
        ),
        trailing: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTask(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTask(index),
              ),
            ],
          ),
        ),
        onTap: () {
          toggleIsLoading();
          // log('task id: ${_tasks![index].id}');
          _toggleTaskCompleted(index, !_tasks![index].complete!);
          // storage.writeTasks(_tasks);
        },
      ),
    );
  }

  toggleIsLoggingOut() {
    setState(() {
      loggingOut = !loggingOut;
    });
  }

  toggleIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  _logoutUser() async {
    final result = await SharedPrefsHelper().clearPrefs();
    // print('result: $result');
    toggleIsLoggingOut();
    if (result != null) {
      if (result == 'success') {
        NavigationHelper.popScreen(context);
        NavigationHelper.pushScreen(context, const LoginView());
        floatingSnackBar(message: 'Logged out.', context: context);
      } else {
        floatingSnackBar(message: 'Error logging out.', context: context);
      }
    } else {
      floatingSnackBar(message: 'Error logging out.', context: context);
    }
  }

  getUserAuthToken() async {
    final result = await SharedPrefsHelper().getToken();

    if (result != null) {
      token = result;
      print('token: $token');
      // if somehow token is empty // get user tasks if token is not empty
      if (token.isNotEmpty) {
        // get all user tasks
        getUserAllTasks();
      }
    }
  }

  getUserAllTasks() async {
    final result = await TaskServices().getAllTodos(token);

    if (result == null) {
      floatingSnackBar(
          message:
              "An unexpected error has occurred while loading todos. Please try again later.",
          context: context);
    } else {
      if (result == 'error') {
        // token has expired
        // clear shared prefs.
        final result2 = await SharedPrefsHelper().clearPrefs();

        // prefs. cleared
        if (result2 != null) {
          if (result2 == 'success') {
            NavigationHelper.popScreen(context);
            NavigationHelper.pushScreen(context, LoginView());
            floatingSnackBar(
                message: "Session has expired. Please login again.",
                context: context);
          } else {
            // error clearing
            floatingSnackBar(
                message: "Error ending session. Please try again later.",
                context: context);
          }
        } else {
          // error clearing
          floatingSnackBar(
              message: "Error ending session. Please try again later.",
              context: context);
        }
      } else {
        // todos fetched
        _tasks = result;
        // print('tasks before sort: ${_tasks!.map((task)=> task.id).toList()}');
        // sort by createdAt
        _tasks!.sort((a, b) => DateTime.parse(b.createdAt!)
            .compareTo(DateTime.parse(a.createdAt!)));
        // print('tasks after sort: ${_tasks!.map((task)=> task.id).toList()}');
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    getUserAuthToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('token: $token');
    return Scaffold(
      backgroundColor: FrontendConfigs.whiteColor,
      appBar: AppBar(
        backgroundColor: FrontendConfigs.kAppPrimaryColor,
        scrolledUnderElevation: 0.0,
        title: const Text(
          'Todo',
          style: TextStyle(color: FrontendConfigs.whiteColor),
        ),
        actions: [
          loggingOut
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                      onTap: () {
                        toggleIsLoading();
                        toggleIsLoggingOut();
                        _logoutUser();
                      },
                      child: const Icon(
                        Icons.logout,
                        color: FrontendConfigs.whiteColor,
                      )),
                )
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.3),
        progressIndicator: const CircularProgressIndicator(
          color: FrontendConfigs.kAppPrimaryColor,
        ),
        child: _tasks == null
            ? const SizedBox(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                  color: FrontendConfigs.kAppPrimaryColor,
                )))
            : _tasks!.isEmpty
                ? const SizedBox(
                    height: 200, child: Center(child: Text('No tasks found.')))
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: _tasks!.length,
                      itemBuilder: (context, index, animation) {
                        return _buildTaskItem(context, index);
                      },
                    ),
                  ),
      ),
      floatingActionButton: _tasks == null
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () => _showAddNewTaskDialog(context),
              tooltip: 'Add Task',
              backgroundColor: FrontendConfigs.kAppPrimaryColor,
              child: const Icon(
                Icons.add,
                color: FrontendConfigs.whiteColor,
              ),
            ),
    );
  }
}
