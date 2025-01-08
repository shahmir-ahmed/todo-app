// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? id;
  String? name;
  String? email;
  String? password;
  String? token;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "password": password,
    "token": token,
  };
}
