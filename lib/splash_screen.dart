import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final title = 'TimePiece360';

  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Center(
          child: Text(
        widget.title,
        style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 50,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).accentColor),
      )),
    );
  }

  _isProfileLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    if (email != null) {
      _startSplashScreenTimer(_navigateToHomeScreen);
    } else {
      _startSplashScreenTimer(_navigateToLoginScreen);
    }
  }

  _navigateToLoginScreen() {
    Navigator.pushReplacementNamed(context, "/LoginScreen");
  }

  _navigateToHomeScreen() {
    Navigator.pushReplacementNamed(context, "/HomeScreen");
  }

  _startSplashScreenTimer(Function function) {
    final duration = Duration(seconds: 2);
    Timer(duration, function);
  }

  @override
  void initState() {
    _isProfileLogin();
    super.initState();
  }
}
