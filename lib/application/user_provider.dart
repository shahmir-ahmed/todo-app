import 'dart:developer';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/infrastructure/models/user.dart';
import 'package:todo_app/infrastructure/services/user.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  void saveUser(user) {
    _user = user;
    notifyListeners();
  }

  UserModel? get getUser => _user;

  /*
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _toggleIsLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }
  */

  /*
  Future getProfile(token, context) async {
    _toggleIsLoading();

    final result = await UserServices().getProfile(token, context);

    _toggleIsLoading();
  }
  */
}
