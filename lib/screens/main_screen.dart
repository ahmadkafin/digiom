import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import '../providers/auth.dart';
import '../widgets/dashboard_dark.dart';
import '../widgets/dashboard_light.dart';
import '../widgets/drawers.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/home';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool change = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late WebViewController _webViewController;

  String filePath = 'files/disclaimer.html';
  bool _isAccept = false;

  @override
  Widget build(BuildContext context) {
    var md = MediaQuery.of(context).size;
    bool disclaimer = Provider.of<Auth>(context).disclaimer ?? false;

    return disclaimer
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 25),
                      child: WebView(
                        initialUrl: '',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _webViewController = webViewController;
                          _loadFromFile();
                        },
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isAccept,
                          onChanged: (value) {
                            setState(() {
                              _isAccept = !_isAccept;
                            });
                          },
                        ),
                        Text("Accept"),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Visibility(
                        visible: _isAccept,
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<Auth>(context, listen: false)
                                .postLog("Login");
                            Provider.of<Auth>(context, listen: false)
                                .disclaimerOff();
                          },
                          child: Text("Accept"),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          var _auth = Provider.of<Auth>(context, listen: false);
                          await _auth.logout().then(
                                (value) => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyApp(),
                                  ),
                                ),
                              );
                        },
                        child: Text("Decline"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            key: _drawerKey,
            appBar: AppBar(
              title: Container(
                alignment: Alignment.bottomCenter,
                child: const Text(
                  "Digio for Operation and Maintenance Dashboard",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              backgroundColor:
                  change ? Colors.black : Color.fromRGBO(84, 130, 53, 1),
              leading: IconButton(
                onPressed: () {
                  return _drawerKey.currentState!.openDrawer();
                },
                icon: Image.asset('img/digiom_white.png'),
              ),
            ),
            body: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              color: change ? Colors.black : Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 5, left: 5),
                      child: change ? DashboardDark() : DashboardLight(),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    height: md.height * 0.06,
                    color:
                        change ? Colors.black : Color.fromRGBO(84, 130, 53, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // IconButton(
                        //   icon: Icon(Icons.ac_unit_sharp),
                        //   onPressed: () {},
                        // ),
                        // IconButton(
                        //   icon: Icon(Icons.ac_unit_sharp),
                        //   onPressed: () {},
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            drawer: Drawers(
              isMode: change,
              isVisible: true,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  change = !change;
                });
              },
              backgroundColor:
                  change ? Colors.black : Color.fromRGBO(84, 130, 53, 1),
              child: Icon(change ? Icons.dark_mode : Icons.wb_sunny),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }

  _loadFromFile() async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    _webViewController.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
