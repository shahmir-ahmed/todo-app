import 'dart:convert';
import 'dart:developer';
import 'package:todo_app/configurations/backend_configs.dart';
import 'package:todo_app/infrastructure/models/todo.dart';
import 'package:http/http.dart' as http;

class TodoServices {
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

      // log('bodyInDart: $bodyInDart');

      if (response.statusCode == 200) {
        // list in map form
        List tasks = bodyInDart['tasks'];

        // in objects form
        List<TodoModel> taskModels = tasks.map((task) => TodoModel.fromJson(task)).toList();

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

      // print('url: $url');

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
        // return body['task']['_id'];
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

  /// delete Todo
  Future deleteTodo(String token, String todoId) async {
    try {
      String url = '${BackendConfigs.kBaseUrl}/todos/delete/$todoId';

      // print('url: $url');
      print('todoId: $todoId');

      final uri = Uri.parse(url);
        final response = await http.delete(uri, headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        });

      // json from response
      final responseJsonBody = response.body;

      // json body converted to dart data types
      final body = jsonDecode(responseJsonBody);

      log('response body: $body');

      if (response.statusCode == 200) {
        return 'success';
      } else {
        log('error: ${body['error'].toString()}');
        return "error";
      }
    } catch (e) {
      log("err in deleteTodo: $e");
      return null;
    }
  }

  /// Get Todos by type i.e. completed/incomplete
  Future getTodosByType(String token, String type) async {
    try {
      final url = "${BackendConfigs.kBaseUrl}/todos/$type";

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
        List<TodoModel> taskModels = tasks.map((task) => TodoModel.fromJson(task)).toList();

        // taskModels.forEach((task)=> print(task.id));

        return taskModels;
      } else {
        // return bodyInDart['error'];
        return "error";
      }
    } catch (e) {
      log("err in getTodosByType: $e");
      return null;
    }
  }

  /// Get Todos based on keyword
  Future searchTodos(String token, String keyword) async {
    try {
      final url = "${BackendConfigs.kBaseUrl}/todos/search?keywords=$keyword";

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
        List<TodoModel> taskModels = tasks.map((task) => TodoModel.fromJson(task)).toList();

        // taskModels.forEach((task)=> print(task.id));

        return taskModels;
      } else {
        // return bodyInDart['error'];
        log('error =====> ${bodyInDart['error']}');
        return "error";
      }
    } catch (e) {
      log("Err in searchTodos: $e");
      return null;
    }
  }

  /// Get Todos based on start and end dates
  Future searchTodosByDates(String token, String startDate, String endDate) async {
    try {
      final url = "${BackendConfigs.kBaseUrl}/todos/filter?startDate=$startDate&endDate=$endDate";

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
        List<TodoModel> taskModels = tasks.map((task) => TodoModel.fromJson(task)).toList();

        // taskModels.forEach((task)=> print(task.id));

        return taskModels;
      } else {
        // return bodyInDart['error'];
        log('error =====> ${bodyInDart['error']}');
        return "error";
      }
    } catch (e) {
      log("Err in searchTodosByDates: $e");
      return null;
    }
  }
}
