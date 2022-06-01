import 'dart:convert';

import '../models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';

class Dashboards with ChangeNotifier {
  List<Dashboard> _data = [];

  final String? authToken;

  Dashboards(this.authToken, this._data);

  List<Dashboard> get dataDashboard => [..._data];

  Future<List<Dashboard>> fetchAllDashboard() async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/dashboard");
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
        _data =
            result.map<Dashboard>((json) => Dashboard.fromJson(json)).toList();
        notifyListeners();
        return _data;
      } else {
        throw Exception(res.statusCode);
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<List<Dashboard>> fetchDashboard(String mode) async {
    final url =
        Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/dashboard/$mode");
    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken'
      },
    );
    // print('Token $authToken');
    if (res.statusCode == 200) {
      final result = json.decode(res.body).cast<Map<String, dynamic>>();
      _data =
          result.map<Dashboard>((json) => Dashboard.fromJson(json)).toList();

      notifyListeners();
      return _data;
    } else {
      throw Exception(res.statusCode);
    }
  }

  Dashboard findDashboard(String id) {
    return _data.firstWhere((el) => el.id == id);
  }

  Future<void> addDashboard(Dashboard dashboard) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/dashboard");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
        body: json.encode({
          "Nama_dashboard": dashboard.Nama_dashboard,
          "Link_dashboard": dashboard.Link_dashboard,
          "Type": dashboard.Type
        }),
      );
      final result = json.decode(res.body);
      if (res.statusCode == 201) {
        final newDashboard = Dashboard(
          id: dashboard.id,
          Nama_dashboard: dashboard.Nama_dashboard,
          Link_dashboard: dashboard.Link_dashboard,
          Type: dashboard.Type,
        );
        // print(newDashboard.Nama_dashboard);
        _data.add(newDashboard);
        notifyListeners();
      }
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> deleteDashboard(String id) async {
    final url = Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/dashboard/$id");
    final existing = _data.indexWhere((element) => element.id == id);
    Dashboard? existingDashboard = _data[existing];
    _data.removeAt(existing);
    notifyListeners();
    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (res.statusCode >= 400) {
      // print(res.statusCode);
      // print(res.body);
      _data.insert(existing, existingDashboard);
      notifyListeners();
      throw HttpException("tidak bisa menghapus dashboard");
    }
    existingDashboard = null;
  }

  Future<void> updateDashboard(String id, Dashboard newDashboard) async {
    final dashboardId = _data.indexWhere((element) => element.id == id);
    try {
      if (dashboardId >= 0) {
        final url =
            Uri.parse("https://gis.pgn.co.id/digiomm/api/v1/dashboard/$id");
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
              "Nama_dashboard": newDashboard.Nama_dashboard,
              "Link_dashboard": newDashboard.Link_dashboard,
              "Type": newDashboard.Type
            },
          ),
        );
        _data[dashboardId] = newDashboard;
        notifyListeners();
      } else {
        print('error');
      }
    } catch (error) {
      // print(error);
      throw (error);
    }
  }
}
