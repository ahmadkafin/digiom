import '../screens/user_add.dart';
import '../screens/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'providers/dashboards.dart';
import 'providers/users.dart';
import 'screens/dashboard_add.dart';
import 'screens/dashboard_management_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_view.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Dashboards>(
          create: (_) => Dashboards('', []),
          update: (ctx, auth, previousDashboard) => Dashboards(
            auth.token,
            previousDashboard == null ? [] : previousDashboard.dataDashboard,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Users>(
          create: (_) => Users('', []),
          update: (ctx, auth, previous) => Users(
            auth.token,
            previous == null ? [] : previous.dataUsers,
          ),
        )
      ],
      builder: (ctx, child) => Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Digiom",
          home: auth.isAuth
              ? MainScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) {
                    // print(auth.tryAutoLogin());
                    return snapshot.connectionState == ConnectionState.waiting
                        ? SplashScreen()
                        : snapshot.connectionState == ConnectionState.done
                            ? LoginScreen()
                            : SplashScreen();
                  },
                ),
          routes: {
            MainScreen.routeName: (ctx) => const MainScreen(),
            DashboardView.routeName: (ctx) => DashboardView(),
            DashboardManagement.routeName: (ctx) => const DashboardManagement(),
            DashboardAdd.routeName: (ctx) => const DashboardAdd(),
            UserManagement.routeName: (ctx) => const UserManagement(),
            UserAdd.routeName: (ctx) => const UserAdd(),

            // LoginScreen.routeName: (ctx) => const LoginScreen(),
            // TestDashboard.routeName: (ctx) => const TestDashboard(),
          },
        ),
      ),
    );
  }
}
