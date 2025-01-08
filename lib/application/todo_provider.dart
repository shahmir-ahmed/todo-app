/*
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:todo_app/infrastructure/services/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> completedTodos = [];
  List<TodoModel> inCompletedTodos = [];
  bool _isLoading = false;

  bool get loading => _isLoading;
  void _toggleIsLoading() => _isLoading = !_isLoading;

  Future getCompletedTodos(String token, context) async {
    _toggleIsLoading();
    notifyListeners();

    final result = await TodoServices().getTodosByType(token, 'completed');

    if (result != null) {
      completedTodos = result;
    }else{
      floatingSnackBar(message: 'Error loading completed todos. Please try again later', context: context);
    }
    _toggleIsLoading();
    notifyListeners();
  }

  Future getInCompletedTodos(String token, context) async {
    _toggleIsLoading();
    notifyListeners();

    final result = await TodoServices().getTodosByType(token, 'incomplete');

    if (result != null) {
      inCompletedTodos = result;
    }else{
      floatingSnackBar(message: 'Error loading incompleted todos. Please try again later', context: context);
    }
    _toggleIsLoading();
    notifyListeners();
  }
}
*/