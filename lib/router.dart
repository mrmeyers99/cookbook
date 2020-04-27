import 'package:flutter/material.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/ui/screens/splash.dart';
import 'package:logging/logging.dart';
import 'ui/screens/home.dart';
import 'ui/screens/login.dart';
import 'ui/screens/register.dart';

//https://www.filledstacks.com/post/flutter-navigation-cheatsheet-a-guide-to-named-routing/
//https://www.filledstacks.com/post/flutter-web-advanced-navigation/
Route<dynamic> generateRoute(RouteSettings settings) {
  final log = Logger('router');
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case LoginViewRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case RegisterViewRoute:
      return MaterialPageRoute(builder: (context) => RegisterScreen());
    default:
      log.info("defaulting to splash screen for ${settings.name}");
      return MaterialPageRoute(builder: (context) => SplashScreen());
  }
}
