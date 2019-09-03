
import 'package:flutter/material.dart';
import 'package:timepiece360/profie_screen.dart';
import 'package:timepiece360/sign_in.dart';
import 'package:timepiece360/sign_up.dart';
import 'package:timepiece360/splash_screen.dart';
import 'package:timepiece360/theme.dart';

import 'home_screen.dart';

void main() => runApp(TimePieces());

class TimePieces extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "TimePiece360 ",
        theme:Themes.kDefaultTheme,
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          '/LoginScreen': (BuildContext context) => LoginScreen(),
          '/SignUp': (BuildContext context) => SignUp(),
          '/HomeScreen': (BuildContext context) => HomeScreen(),
          '/ProfileScreen': (BuildContext context) => ProfileScreen(),
        });
  }
}
