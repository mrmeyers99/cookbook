import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:logging/logging.dart';

import 'router.dart' as router;
import 'routing_constants.dart';
import 'ui/screens/splash.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  var list = [1, 2, 3];
  var map = {
    1: "one",
    2: "two",
    3: "three",
  };


}
//void main() {
//  Logger.root.level = Level.ALL; // defaults to Level.INFO
//  Logger.root.onRecord.listen((record) {
//    print('${record.level.name}: ${record.time}: ${record.message}');
//  });
//
//  setupLocator();
//
//  runApp(MaterialApp(
//    title: 'Cookbook',
//    theme: ThemeData(
//      primarySwatch: Colors.blue,
//    ),
//    home: SplashScreen(),
//    onGenerateRoute: router.generateRoute,
//    initialRoute: HomeViewRoute,
//    navigatorObservers: [routeObserver],
//  ));
//}
