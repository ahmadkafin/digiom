import 'dart:async';
import 'dart:convert';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;
  String? _userName;
  String? _roles;
  String? _names;
  Timer? _authTimer;

  bool? _disclaimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get username {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _userName;
    }
    return null;
  }

  String? get roles {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _roles;
    }
    return null;
  }

  String? get names {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _names;
    }
    return null;
  }

  bool? get disclaimer {
    return _disclaimer;
  }

  Future<void> _authenticate(String username, String password) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/user/login");
    try {
      var headers = {'Content-Type': 'application/json'};
      final res = await http.post(url,
          body: json.encode(
            {
              "Username": username,
              "Password": password,
            },
          ),
          headers: headers);
      final responseData = json.decode(res.body);

      if (responseData['username'] == null) {
        throw HttpException(responseData['message']);
        // print(responseData['message']);
      }

      _token = responseData['token'];
      _userId = responseData['id'].toString();
      _userName = responseData['username'];
      _names = responseData['names'];
      _roles = responseData['roles'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: responseData['expires'],
        ),
      );

      _disclaimer = true;
      // print(responseData);
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'username': _userName,
        'names': _names,
        'roles': _roles,
        'expiry': _expireDate?.toIso8601String(),
      });
      prefs.setString('userData', userData);
      prefs.setBool('disclaimer', _disclaimer!);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> login(String username, String password) async {
    return _authenticate(username, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData') ?? "") as Map<String?, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiry']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _userName = extractedUserData['username'];
    _names = extractedUserData['names'];
    _roles = extractedUserData['roles'];
    _expireDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _names = null;
    _roles = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    // print(_token);
    // prefs.remove('disclaimer');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> disclaimerOff() async {
    final prefs = await SharedPreferences.getInstance();
    _disclaimer = false;
    // prefs.remove('disclaimer');
    notifyListeners();
  }

  Future<void> postLog(String keterangan) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/userlog");
    final ipv4 = await Ipify.ipv4();
    try {
      var headers = {'Content-Type': 'application/json'};
      final res = await http.post(
        url,
        body: json.encode({
          "usernames": username,
          "logontime": DateTime.now().toIso8601String(),
          "keterangan": keterangan,
          "ip": ipv4
        }),
        headers: headers,
      );
      if (res.statusCode == 204) {
        print("sukses");
      } else {
        print(res.statusCode);
      }
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
