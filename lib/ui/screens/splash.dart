import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cooked/locator.dart';
import 'package:home_cooked/routing_constants.dart';
import 'package:home_cooked/service/user_service.dart';
import 'package:logging/logging.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//https://heartbeat.fritz.ai/firebase-user-authentication-in-flutter-1635fb175675
class _SplashScreenState extends State<SplashScreen> with RouteAware {
  final _log = Logger('_SplashScreenState');
  final UserService userService;

  _SplashScreenState() : this.userService = locator.get<UserService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    _log.info("SplashScreen - didPush");
    _redirect();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    _log.info("SplashScreen - didPopNext");
    _redirect();
  }

  void _redirect() {
    locator.get<UserService>().getCurrentUser()
        .then((currentUser) {
          if (currentUser == null) {
            _log.info("User not logged in, redirecting to login screen");
            Navigator.pushReplacementNamed(context, LoginViewRoute);
          }
          else {
            _log.info("User ${currentUser.uid} is logged in.  Redirecting to home screen.");
            Navigator.pushReplacementNamed(context, HomeViewRoute);
          }
        })
        .catchError((err) => print(err));
  }

  @override
  initState() {
    _log.info('Loading splash screen');
    _redirect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _log.info("Building splash screen");
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
