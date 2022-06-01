import 'package:flutter/cupertino.dart';

class User with ChangeNotifier {
  final String id;
  final String userId;
  final String userNames;
  final String userSatuanKerja;
  final bool status;
  final String roles;

  User(
      {required this.id,
      required this.userId,
      required this.userNames,
      required this.userSatuanKerja,
      required this.status,
      required this.roles});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json['id'].toString(),
      userId: json['userId'],
      userNames: json['userNames'],
      userSatuanKerja: json['userSatuanKerja'],
      status: json['status'],
      roles: json['roles']);
}
