import 'package:flutter/cupertino.dart';

class Dashboard with ChangeNotifier {
  final String id;
  final String Nama_dashboard;
  final String Link_dashboard;
  final String Type;

  Dashboard(
      {required this.id,
      required this.Nama_dashboard,
      required this.Link_dashboard,
      required this.Type});

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
      id: json['id'].toString(),
      Nama_dashboard: json['nama_dashboard'],
      Link_dashboard: json['link_dashboard'],
      Type: json['type']);
}
