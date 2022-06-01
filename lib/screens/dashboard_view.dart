import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../providers/auth.dart';
import '../providers/dashboards.dart';

class DashboardView extends StatelessWidget {
  DashboardView({Key? key}) : super(key: key);
  static const routeName = '/dashboard-view';
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    final dashboardId = ModalRoute.of(context)!.settings.arguments as String;
    final dashboardData = Provider.of<Dashboards>(context, listen: false)
        .findDashboard(dashboardId);
    String? token = Provider.of<Auth>(context, listen: false).token;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dashboardData.Nama_dashboard,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: dashboardData.Type == 'dark'
            ? Colors.black
            : Color.fromRGBO(84, 130, 53, 1),
      ),
      body: Container(
        child: WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            _loadDashboard(dashboardData.id, token);
          },
        ),
      ),
    );
  }

  _loadDashboard(id, token) async {
    String url = "https://gis.pgn.co.id/digiomm/dashboardmvc/details/$id";
    _webViewController.loadUrl(
      url,
      headers: {
        'Content-Type': 'text/html',
        'Accept': 'text/html',
        'Authorization': 'Bearer $token'
      },
    );
  }
}
