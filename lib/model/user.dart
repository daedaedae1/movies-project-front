import 'package:flutter/material.dart';

class User {
  final String name;
  final String userid;
  final String pwd;

  User({
    required this.name,
    required this.userid,
    required this.pwd});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      userid: json['userid'],
      pwd: json['pwd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userid': userid,
      'pwd': pwd,
    };
  }
}

class UserData with ChangeNotifier {
  User? _user;

  User get user => _user!;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}