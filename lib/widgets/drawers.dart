import '../main.dart';
import '../providers/auth.dart';
import '../screens/dashboard_management_screen.dart';
import '../screens/user_management.dart';
// import 'package:digiom/screens/dashboard_dark_screen.dart';
// import 'package:digiom/screens/dashboard_management_screen.dart';
// import 'package:digiom/screens/dashboard_screen.dart';
// import 'package:digiom/screens/login_screen.dart';
// import 'package:digiom/screens/test_dashboard.dart';
// import 'package:digiom/screens/user_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Drawers extends StatefulWidget {
  Drawers({
    Key? key,
    required this.isMode,
    required this.isVisible,
  }) : super(key: key);

  bool isMode;
  bool isVisible;

  @override
  State<Drawers> createState() => _DrawersState();
}

class _DrawersState extends State<Drawers> {
  @override
  Widget build(BuildContext context) {
    String? name = Provider.of<Auth>(context, listen: false).names;
    String? username = Provider.of<Auth>(context, listen: false).username;
    String? roles = Provider.of<Auth>(context, listen: false).roles;
    bool isModes = widget.isMode;

    var md = MediaQuery.of(context).size;

    return Drawer(
      child: Container(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isModes ? Colors.black : Color.fromRGBO(84, 130, 53, 1),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CircleAvatar(
                                  radius: 35,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "$name",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "$username",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: md.height * 0.4,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        size: 25,
                      ),
                      title: const Text('Home'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                    Visibility(
                      visible: roles == 'admin' ? true : false,
                      child: ListTile(
                        leading: const Icon(
                          Icons.people,
                          size: 25,
                        ),
                        title: const Text("User Management"),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(UserManagement.routeName);
                        },
                      ),
                    ),
                    Visibility(
                      visible: roles == 'admin' ? true : false,
                      child: ListTile(
                        leading: const Icon(
                          Icons.dashboard,
                          size: 25,
                        ),
                        title: const Text("Dashboard Management"),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                              DashboardManagement.routeName);
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text("Logout"),
                      // onTap: () => Provider.of<Auth>(context, listen: false).logout(),
                      onTap: () async {
                        await Provider.of<Auth>(context, listen: false)
                            .postLog("Logout");
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
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      "DIGIO for Operation and Maintenance Dashboard",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
