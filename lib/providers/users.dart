import 'dart:convert';

import '../models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import './user.dart';

class Users with ChangeNotifier {
  List<User> _data = [];

  final String? authToken;

  Users(this.authToken, this._data);

  List<User> get dataUsers => [..._data];

  Future<List<User>> fetchAllUser() async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/users");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      if (res.statusCode == 200) {
        final result = json.decode(res.body).cast<Map<String, dynamic>>();
        _data = result.map<User>((json) => User.fromJson(json)).toList();
        notifyListeners();
        return _data;
      } else {
        throw Exception(res.statusCode);
      }
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addUser(User user) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/users");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
        body: json.encode({
          "userId": user.userId,
          "userNames": user.userNames,
          "userSatuanKerja": user.userSatuanKerja,
          "roles": user.roles,
          "status": user.status
        }),
      );
      final result = json.decode(res.body);
      if (res.statusCode == 201) {
        final newUser = User(
            id: user.id,
            userId: user.userId,
            userNames: user.userNames,
            userSatuanKerja: user.userSatuanKerja,
            status: user.status,
            roles: user.roles);
        _data.add(newUser);
        notifyListeners();
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  User findUser(String id) {
    return _data.firstWhere((element) => element.id == id);
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/users/$id");
    final existing = _data.indexWhere((element) => element.id == id);
    User? existingUser = _data[existing];
    _data.removeAt(existing);
    notifyListeners();
    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (res.statusCode >= 400) {
      print(res.statusCode);
      print(res.body);
      _data.insert(existing, existingUser);
      notifyListeners();
      throw HttpException("tidak bisa menghapus User");
    }
    existingUser = null;
  }

  Future<void> updateUser(String id, User newUser) async {
    final userId = _data.indexWhere((element) => element.id == id);
    try {
      if (userId >= 0) {
        final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/users/$id");
        await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken'
          },
          body: json.encode(
            {
              "id": int.parse(id),
              "userId": newUser.userId,
              "userNames": newUser.userNames,
              "userSatuanKerja": newUser.userSatuanKerja,
              "roles": newUser.roles,
              "status": newUser.status
            },
          ),
        );
        _data[userId] = newUser;
        notifyListeners();
      } else {
        print('error');
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }
}
