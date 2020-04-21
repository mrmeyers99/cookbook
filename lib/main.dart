import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'cache.dart';
import 'ui/screens/home.dart';
import 'ui/screens/login.dart';
import 'ui/screens/register.dart';
import 'ui/screens/splash.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MaterialApp(
    title: 'Cookbook',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: SplashScreen(),
    navigatorObservers: [routeObserver],
    routes: {
      '/home': (BuildContext context) => HomeScreen(),
      '/login': (BuildContext context) => LoginScreen(),
      '/register': (BuildContext context) => RegisterScreen(),
    },
  ));
}
