import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/configurations/backend_configs.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/infrastructure/models/user.dart';

class UserServices {
  Future getProfile(String token) async {
    // print('token in getProfile: $token');
    // print('getting user profile via services');
    try {
      String url = "${BackendConfigs.kBaseUrl}/users/profile";

      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': token
      });

      // print('response.statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        /*
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(UserModel.fromJson(jsonDecode(response.body)['user']));
        // print('user setting via provider');
        return 'success';
        */
        var user = UserModel.fromJson(jsonDecode(response.body)['user']);
        user.token = token;
        // print('token: $token');
        // print('user: ${user.toJson()}');
        return user;
      } else {
        log('Err getting profile: ${jsonDecode(response.body)['error']}');
        return null;
      }
    } catch (e) {
      log('Err in getProfile: $e');
      return null;
    }
  }

  Future updateProfile(UserModel userModel) async {
    try {
      String url = "${BackendConfigs.kBaseUrl}/users/profile";

      final body = jsonEncode({"name": userModel.name!, "email": userModel.email!});

      final response = await http.put(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': userModel.token!
          },
          body: body);

      // print('response.statusCode: ${response.statusCode}');
      // print('response: ${response.body}');

      if (response.statusCode == 200) {
        var user = UserModel.fromJson(jsonDecode(response.body)['updatedUser']);
        user.token = userModel.token!;
        return user;
      } else {
        log('Err updating profile: ${jsonDecode(response.body)['error']}');
        return null;
      }
    } catch (e) {
      log('Err in updating profile: $e');
      return null;
    }
  }
}
