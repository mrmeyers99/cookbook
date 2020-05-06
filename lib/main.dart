import 'package:flutter/material.dart';
import 'package:home_cooked/locator.dart';
import 'package:logging/logging.dart';

import 'router.dart' as router;
import 'routing_constants.dart';
import 'ui/screens/splash.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message} ${record.error != null ? ': ' + record.error.toString() : ''} ${record.stackTrace != null ? ': ' + record.stackTrace.toString() : ''}');
  });

  setupLocator();

  runApp(MaterialApp(
    title: 'Cookbook',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: SplashScreen(),
    onGenerateRoute: router.generateRoute,
    initialRoute: HomeViewRoute,
    navigatorObservers: [routeObserver],
  ));
}
