// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  String? id;
  String? description;
  bool? complete;
  String? owner;
  String? createdAt;
  String? updatedAt;

  TodoModel({
    this.id,
    this.description,
    this.complete,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json["_id"],
    description: json["description"],
    complete: json["complete"],
    owner: json["owner"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "description": description,
    "complete": complete,
    "owner": owner,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };

  void toggleCompleted() {
    complete = !complete!;
  }
}
