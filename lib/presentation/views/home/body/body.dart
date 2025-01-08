import 'dart:convert';
import 'dart:developer';

import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:todo_app/application/navigation_helper.dart';
import 'package:todo_app/application/shared_prefs_helper.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:todo_app/infrastructure/services/todo.dart';
import 'package:todo_app/infrastructure/services/user.dart';
import 'package:todo_app/presentation/elements/custom_drawer.dart';
import 'package:todo_app/presentation/elements/loading_alert_dialog.dart';
import 'package:todo_app/presentation/elements/todo_details_bottom_sheet.dart';
import 'package:todo_app/presentation/elements/todo_tile.dart';
import 'package:todo_app/presentation/views/auth/login/login_view.dart';
import 'package:todo_app/presentation/views/profile/profile_view.dart';

import '../../../../application/user_provider.dart';
import '../../../../infrastructure/models/user.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  List<TodoModel>? _todos;
  List<TodoModel>? _searchedTodos = [];
  // final Storage storage = Storage();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _listKey2 = GlobalKey<AnimatedListState>();
  String token = '';
  // bool loggingOut = false;
  bool isLoading = false;
  bool isSearching = false;
  List<DateTime>? _selectedDates;

  Future _addNewTodo(String desc) async {
    final requestBody = {'description': desc};

    final result =
        await TodoServices().addUpdateTodo(token, requestBody, forAdd: true);

    // toggleIsLoading();
    NavigationHelper.popScreen(context);

    if (result != null) {
      if (result == 'success') {
        floatingSnackBar(message: "Todo added successfully.", context: context);

        setState(() {
          _todos = null;
        });

        getUserAllTodos();

        /*
        final newTodo = TodoModel(
          complete: false,
          description: desc,
        );

        setState(() {
          // _todos!.add(newTodo);
          _todos!.insert(0, newTodo);
        });

        // _listKey.currentState?.insertItem(_todos!.length - 1);
        _listKey.currentState?.insertItem(0);
        // _listKey.currentState?.setState(() {
        //   _listKey.currentState?.insertItem(0);
        // });
         */
      } else {
        floatingSnackBar(
            message: "Error adding todo. Please try again later.",
            context: context);
      }
    } else {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    }

    // storage.writeTodos(_todos);
  }

  Future _updateTodoDesc(int index, String newDesc) async {
    final requestBody = {
      'description': newDesc,
      'complete': _todos![index].complete
    };
    // log(requestBody.toString());
    final todoId = _todos![index].id;

    final result = await TodoServices()
        .addUpdateTodo(token, requestBody, forAdd: false, todoId: todoId);

    // toggleIsLoading();
    NavigationHelper.popScreen(context);

    if (result != null) {
      if (result == 'success') {
        floatingSnackBar(
            message: "Todo description updated successfully.",
            context: context);

        setState(() {
          _todos![index].description = newDesc;
        });
      } else {
        floatingSnackBar(
            message: "Error updating todo description. Please try again later.",
            context: context);
      }
    } else {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    }

    // storage.writeTodos(_todos);
  }

  Future _updateTodoStatus(int index, bool newStatus) async {
    final requestBody = {
      'description': _todos![index].description,
      'complete': newStatus
    };

    final todoId = _todos![index].id;

    final result = await TodoServices()
        .addUpdateTodo(token, requestBody, forAdd: false, todoId: todoId);

    // toggleIsLoading();
    NavigationHelper.popScreen(context);

    if (result != null) {
      if (result == 'success') {
        floatingSnackBar(
            message:
                "Todo marked as ${newStatus ? 'completed' : 'uncompleted'}.",
            context: context);

        setState(() {
          _todos![index].toggleCompleted();
        });
      } else {
        floatingSnackBar(
            message: "Error updating todo status. Please try again later.",
            context: context);
      }
    } else {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    }

    // storage.writeTodos(_todos);
  }

  void _deleteTodo(int index) async {
    TodoModel removedTodo = _todos![index];

    String removedTodoId = _todos![index].id ?? '';

    // print('removedTodo.complete!: ${removedTodo.complete!}');

    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(removedTodo.description!,
                  style: TextStyle(
                      decoration: removedTodo.complete!
                          ? TextDecoration.lineThrough
                          : null)),
              leading: Icon(
                removedTodo.complete!
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: removedTodo.complete! ? Colors.green : null,
              ),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 250),
    );

    setState(() {
      _todos!.removeAt(index);
    });

    final result = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedTodo.description!} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _todos!.insert(index, removedTodo);
            });
            _listKey.currentState?.insertItem(index);
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final closedReason = await result.closed;

    // print('closedReason: $closedReason'); // reason

    if (closedReason != SnackBarClosedReason.action) {
      // print('deleting todo.');
      // toggleIsLoading();
      showLoadingAlertDialog(context, message: 'Deleting todo...');

      final todoId = removedTodoId;

      final result = await TodoServices().deleteTodo(token, todoId);

      // toggleIsLoading();
      Navigator.pop(context);

      if (result != null) {
        if (result == 'success') {
          floatingSnackBar(
              message: "Todo deleted successfully.", context: context);
        } else {
          // re add removed todo
          setState(() {
            _todos!.insert(index, removedTodo);
          });
          _listKey.currentState?.insertItem(index);

          floatingSnackBar(
              message: "Error deleting todo. Please try again later.",
              context: context);
        }
      } else {
        // re add removed todo
        setState(() {
          _todos!.insert(index, removedTodo);
        });
        _listKey.currentState?.insertItem(index);

        floatingSnackBar(
            message:
                "An unexpected error has occurred. Please try again later.",
            context: context);
      }
    }
    // else{
    //   // print('closed due to action button, so not deleting.');
    // }

    // storage.writeTodos(_todos);
  }

  void _showAddUpdateTodoDialog(BuildContext context,
      {String desc = '', bool forAdd = true, int index = 0}) {
    String todoDesc = desc;

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: FrontendConfigs.whiteColor,
            title: Text(forAdd ? 'Add new todo' : 'Edit todo'),
            content: TextFormField(
              initialValue: todoDesc,
              onChanged: (value) {
                todoDesc = value;
              },
              decoration: const InputDecoration(
                labelText: 'Todo Description',
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
                child: Text(forAdd ? 'Add' : 'Update'),
                onPressed: () {
                  if (todoDesc.trim().isNotEmpty) {
                    // toggleIsLoading();
                    Navigator.of(ctx).pop();
                    if (forAdd) {
                      showLoadingAlertDialog(context,
                          message: 'Adding todo...');
                      _addNewTodo(todoDesc);
                    } else {
                      showLoadingAlertDialog(context,
                          message: 'Updating todo...');
                      _updateTodoDesc(index, todoDesc);
                    }
                    // Navigator.of(ctx).pop();
                  } else {
                    floatingSnackBar(
                        message: "Description is required.", context: ctx);
                  }
                },
              ),
            ],
          );
        });
  }

  void _showConfirmDeleteTodoDialog(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: FrontendConfigs.whiteColor,
            title: const Text('Delete todo?'),
            content: const Text('Are you sure you want to delete this todo?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteTodo(index);
                },
              ),
            ],
          );
        });
  }

  Widget _buildTodoItem(BuildContext context, int index) {
    return Card(
      // color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.5),
      // key: Key(_todos![index].id ?? ''),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
          _todos![index].description!,
          style: TextStyle(
              decoration:
                  _todos![index].complete! ? TextDecoration.lineThrough : null),
        ),
        leading: GestureDetector(
          onTap: () {
            // toggleIsLoading();
            showLoadingAlertDialog(context, message: 'Updating todo status...');
            // log('todo id: ${_todos![index].id}');
            _updateTodoStatus(index, !_todos![index].complete!);
            // storage.writeTodos(_todos);
          },
          child: Icon(
            _todos![index].complete!
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: _todos![index].complete! ? Colors.green : null,
          ),
        ),
        trailing: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAddUpdateTodoDialog(context,
                    desc: _todos![index].description!,
                    forAdd: false,
                    index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showConfirmDeleteTodoDialog(context, index),
              ),
            ],
          ),
        ),
        onTap: () {
          showTodoDetailsBottomSheet(
              context, isSearching ? _searchedTodos![index] : _todos![index]);
        },
      ),
    );
  }

  /*toggleIsLoggingOut() {
    setState(() {
      loggingOut = !loggingOut;
    });
  }*/

  // toggleIsLoading() {
  //   setState(() {
  //     isLoading = !isLoading;
  //   });
  // }

  /*_logoutUser() async {
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
  }*/
/*
  getUserAuthToken() async {
    final result = await SharedPrefsHelper().getToken();

    if (result != null) {
      token = result;
      print('token: $token');
      // if somehow token is empty // get user todos if token is not empty
      if (token.isNotEmpty) {
        // Provider.of<UserProvider>(context, listen: false).setToken(token);
        // print(
        //     'token set in provider: ${Provider.of<UserProvider>(context, listen: false).getToken}');

        // get all user todos
        getUserAllTodos();

        // get user profile
        // getUserProfile();
      }
    }
  }
 */

  /*
  getUserProfile() async {
    // print('getting user profile via provider');
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // print(token);
    final result = await UserServices().getProfile(token);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (result != null) {
      userProvider.setUser(UserModel.fromJson(jsonDecode(result)['user']));
    } else {
      userProvider.setUser(null);
    }
    // userProvider.getProfile(token, context);
  }
  */

  getUserAllTodos() async {
    token = Provider.of<UserProvider>(context, listen: false).getUser!.token!;

    // print('token from provider: $token');

    final result = await TodoServices().getAllTodos(token);

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
            NavigationHelper.pushScreen(context, const LoginView());
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
        _todos = result;
        // print('todos before sort: ${_todos!.map((todo)=> todo.id).toList()}');
        // sort by createdAt
        _todos!.sort((a, b) => DateTime.parse(b.createdAt!)
            .compareTo(DateTime.parse(a.createdAt!)));
        // print('todos after sort: ${_todos!.map((todo)=> todo.id).toList()}');
        setState(() {});
      }
    }
  }

  _searchTodos(String keyword) async {
    setState(() {
      _searchedTodos = null;
    });
    await TodoServices().searchTodos(token, keyword).then((val) {
      if (val != null) {
        if (val == 'error') {
          floatingSnackBar(
              message: 'Error searching. Please try again later.',
              context: context);
        } else {
          val.map((e)=> log('e: ${e.description}')).toList();
          setState(() {
            _searchedTodos = val;
          });
        }
      } else {
        floatingSnackBar(
            message:
                'An unexpected error has occurred. Please try again later.',
            context: context);
      }
    });
  }
/*
  void _showMultiDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Dates'),
          content: SizedBox(
            height: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.multiple,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  _selectedDates = args.value as List<DateTime>?;
                });
                log("selected dates: "+_selectedDates!.map((date)=>"date: "+date.toString()).toList().toString());
              },
              initialSelectedDates: _selectedDates,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _selectedDates != null && _selectedDates!.isNotEmpty
                          ? 'Selected Dates: ${_selectedDates!.join(", ")}'
                          : 'No Dates Selected',
                    ),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }*/

  @override
  void initState() {
    // getUserAuthToken();
    // get all user todos
    // _dateRangePickerController = DateRangePickerController();
    // _dateRangePickerController2 = DateRangePickerController();
    // rangeStart = '';
    // rangeEnd = '';
    getUserAllTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('token: $token');
    return /*ProfileView();*/
        Scaffold(
      backgroundColor: FrontendConfigs.whiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: FrontendConfigs.whiteColor),
        backgroundColor: FrontendConfigs.kAppPrimaryColor,
        scrolledUnderElevation: 0.0,
        title: isSearching
            ? TextFormField(
                style: const TextStyle(
                    color: FrontendConfigs.whiteColor,
                    decoration: TextDecoration.none),
                cursorColor: FrontendConfigs.whiteColor,
                autofocus: true,
                onFieldSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    print('keyword: ${text.trim()}');
                    _searchTodos(text.trim());
                  }
                },
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: FrontendConfigs.whiteColor, width: 1.5)),
                  border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: FrontendConfigs.whiteColor, width: 1.5)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: FrontendConfigs.whiteColor, width: 1.5)),
                  hintText: "Search",
                  hintStyle: const TextStyle(
                      color: FrontendConfigs.whiteColor,
                      fontWeight: FontWeight.normal),
                  contentPadding: const EdgeInsets.only(
                    top: 12,
                    left: 6,
                  ),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isSearching = false;
                          _searchedTodos = [];
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: FrontendConfigs.whiteColor,
                        size: 25,
                      )),
                ),
              )
            : const Text(
                'Todo',
                style: TextStyle(color: FrontendConfigs.whiteColor),
              ),
        actions: [
          // isSearching
          //     ? Padding(
          //         padding: const EdgeInsets.only(left: 8.0, right: 30),
          //         child: GestureDetector(
          //           onTap: () {
          //             _showMultiDatePicker(context);
          //           },
          //           child: const Icon(
          //             Icons.calendar_month,
          //             color: FrontendConfigs.whiteColor,
          //           ),
          //         ),
          //       )
          //     :
              !isSearching ?
              Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearching = true;
                      });
                    },
                    child: const Icon(
                      Icons.search,
                      color: FrontendConfigs.whiteColor,
                    ),
                  ))
          : const SizedBox(),
          !isSearching
              ? Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      _showAddUpdateTodoDialog(context);
                    },
                    child: const Icon(
                      Icons.add,
                      color: FrontendConfigs.whiteColor,
                    ),
                  ))
              : const SizedBox()
          /*
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
           */
        ],
      ),
      body: isSearching
          ? _searchedTodos == null
              ? const SizedBox(
                  height: 200,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: FrontendConfigs.kAppPrimaryColor,
                  )))
              // : _searchedTodos!.isEmpty
              //     ? const SizedBox(
              //         height: 200,
              //         child: Center(child: Text('No todos found.')))
              : SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                    // Column(
                    //   children: [
                        // selected dates
                        // _selectedDates != null && _selectedDates!.isNotEmpty
                        //     ? Padding(
                        //       padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                        //       child: Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text(
                        //               'Start: ${_selectedDates!.first.toString().split(' ')[0]}', // Show the first selected date
                        //               style: const TextStyle(
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             const Icon(Icons.arrow_forward_rounded),
                        //             Text(
                        //               'End: ${_selectedDates!.last.toString().split(' ')[0]}', // Show the last selected date
                        //               style: const TextStyle(
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //           ],
                        //         ),
                        //     )
                        //     : const SizedBox(),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _searchedTodos!.length,
                          itemBuilder: (context, index) {
                            return TodoTile(todo: _searchedTodos![index]);
                          },
                        ),
                    //   ],
                    // ),
                  ),
              )
          : LoadingOverlay(
              isLoading: isLoading,
              color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.3),
              progressIndicator: const CircularProgressIndicator(
                color: FrontendConfigs.kAppPrimaryColor,
              ),
              child: _todos == null
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: FrontendConfigs.kAppPrimaryColor,
                      )))
                  : _todos!.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: Text('No todos found.')))
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: AnimatedList(
                            key: _listKey,
                            initialItemCount: _todos!.length,
                            itemBuilder: (context, index, animation) {
                              return _buildTodoItem(context, index);
                            },
                          ),
                        ),
            ),
      /*
      floatingActionButton:
      _todos == null
          ? const SizedBox()
          : isSearching
              ? const SizedBox()
              : FloatingActionButton(
                  onPressed: () => _showAddUpdateTodoDialog(context),
                  tooltip: 'Add Todo',
                  backgroundColor: FrontendConfigs.kAppPrimaryColor,
                  child: const Icon(
                    Icons.add,
                    color: FrontendConfigs.whiteColor,
                  ),
                ),*/
      drawer: const CustomDrawer(),
    );
  }
}
