import 'dart:convert';
import 'dart:developer';
import 'package:todo_app/configurations/backend_configs.dart';
import 'package:todo_app/infrastructure/models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  /// register user
  Future registerUser(UserModel user) async {
    try {
      const url = "${BackendConfigs.kBaseUrl}/users/register";

      final uri = Uri.parse(url);

      final userJson = jsonEncode(user.toJson());

      final response = await http.post(uri, headers: {
        'Content-Type': 'application/json'
      }, body: userJson);

      final responseBody = response.body; // json string body

      // log('responseBody: $responseBody');

      final body = jsonDecode(responseBody); // dart type body

      log('body after decode: $body');

      if (response.statusCode == 201) {
        return 'success';
      } else {
        return 'error'+body['error'];
      }
      // return body['message'];
    } catch (e) {
      log("err in registerUser: $e");
      return null;
    }
  }

  /// login user
  Future loginUser(UserModel user) async {
    try {
      const url = "${BackendConfigs.kBaseUrl}/users/login";

      final uri = Uri.parse(url);

      final userJson = jsonEncode(user.toJson());

      final response = await http.post(uri, headers: {
        'Content-Type': 'application/json'
      }, body: userJson);

      final responseBody = response.body; // json string body

      // log('responseBody: $responseBody');

      final body = jsonDecode(responseBody); // dart type body

      log('body after decode: $body');
      // log('response.statusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        return body['token'];
        // user.token = body['token'];
        // print(user.toJson());
        // return user;
      } else {
        return 'error';
      }
      // return body['message'];
    } catch (e) {
      log("err in loginUser: $e");
      return null;
    }
  }
}
