// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  String? id;
  String? description;
  bool? complete;
  String? owner;
  String? createdAt;
  String? updatedAt;

  TaskModel({
    this.id,
    this.description,
    this.complete,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
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
