import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/UserService.dart';
import 'package:logging/logging.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//https://heartbeat.fritz.ai/firebase-user-authentication-in-flutter-1635fb175675
class _SplashScreenState extends State<SplashScreen> {
  final log = Logger('_SplashScreenState');

  @override
  initState() {
    final log = Logger('Loading splash screen');
    locator.get<UserService>().getCurrentUser()
        .then((currentUser) {
              if (currentUser == null) {
                log.info("User not logged in, redirecting to login screen");
                Navigator.pushReplacementNamed(context, LoginViewRoute);
              }
              else {
                log.info("User ${currentUser.uid} is logged in.  Redirecting to home screen.");
                Navigator.pushReplacementNamed(context, HomeViewRoute);
              }
            })
        .catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
