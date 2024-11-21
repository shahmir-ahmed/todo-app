import 'dart:convert';
import 'dart:developer';
import 'package:todo_app/configurations/backend_configs.dart';
import 'package:todo_app/infrastructure/models/task.dart';
import 'package:http/http.dart' as http;

class TaskServices {
  /// Get all Todos
  Future getAllTodos(String token) async {
    try {
      const url = "${BackendConfigs.kBaseUrl}/todos/get";

      final uri = Uri.parse(url);

      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      });

      // json from response
      final bodyInJson = response.body;

      // converted to dart data types
      final bodyInDart = jsonDecode(bodyInJson);

      log('bodyInDart: $bodyInDart');

      if (response.statusCode == 200) {
        // list in map form
        List tasks = bodyInDart['tasks'];

        // in objects form
        List<TaskModel> taskModels = tasks.map((task) => TaskModel.fromJson(task)).toList();

        // taskModels.forEach((task)=> print(task.id));

        return taskModels;
      } else {
        // return bodyInDart['error'];
        return "error";
      }
    } catch (e) {
      log("err in getAllTodos: $e");
      return null;
    }
  }

  /// add update Todo
  Future addUpdateTodo(String token, dynamic requestBody, {required bool forAdd, todoId = ''}) async {
    try {
      String url = '${BackendConfigs.kBaseUrl}/todos/';
      if(forAdd) {
        url += "add";
      }else{
        url += "update/$todoId";
      }

      // print(url);

      final uri = Uri.parse(url);

      // log('requestBody: $requestBody');

      final requestJsonBody = jsonEncode(requestBody);

      // log('requestJsonBody: $requestJsonBody');

      http.Response response;

      if(forAdd) {
        response = await http.post(uri, headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        }, body: requestJsonBody);
      }else{
        response = await http.patch(uri, headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        }, body: requestJsonBody);
      }

      // json from response
      final responseJsonBody = response.body;

      // json body converted to dart data types
      final body = jsonDecode(responseJsonBody);

      log('response body: $body');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'success';
      } else {
        log('error: ${body['error'].toString()}');
        return "error";
      }
    } catch (e) {
      log("err in addUpdateTodo: $e");
      return null;
    }
  }
}
