import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Time Piece 360"),
      ),
      body: _MyLoginScreen(),
    );
  }
}

class _MyLoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<_MyLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessageEvent="";

  _isValidSignIn(String email, String password) {
    if (email == null || email.trim().isEmpty) {
      _errorMessageEvent = "you must write your right Email or right your name";
      return false;
    }

    if (password == null || password.trim().isEmpty || password.length < 7) {
      _errorMessageEvent =
          "you must write your right password  more than 8 character ";
      return false;
    }

    if (password == password.toLowerCase() ||
        password == password.toUpperCase()) {
      _errorMessageEvent = "Password must include small and capital letter";
      return false;
    }

    return true;
  }

  _saveProfileSharedPreference({String email, String password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

   _signInWithEmailAndPassword() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final  user = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (user != null) {
          _saveProfileSharedPreference(
              email: _emailController.text, password: _passwordController.text);
          Navigator.pushReplacementNamed(context, "/HomeScreen");
        }
      } catch (error) {
        if (error.toString().contains("ERROR_USER_NOT_FOUND")) {
          _errorMessageEvent = "this email is not found";
        }
        if (error.toString().contains("ERROR_WRONG_PASSWORD")) {
          _errorMessageEvent =
              "The password is invalid or the user does not have a password";
        }
        setState(() {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(_errorMessageEvent)));
        });

        print(error.toString());
        error.toString();
      }
    } else {
      setState(() {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("no internet connection")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 100),
                Text(
                  "Sign In",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 50,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).accentColor),
                ),
                SizedBox(height: 30),
                TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Email",
                        fillColor: Theme.of(context).accentColor,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 5.0, color: Theme.of(context).accentColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(10)))),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: ' Password',
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 5.0, color: Theme.of(context).accentColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).accentColor,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  color: Theme.of(context).accentColor,
                  child: Text("Sign in"),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    if (_isValidSignIn(_emailController.value.text,
                        _passwordController.value.text)) {
                      _signInWithEmailAndPassword();
                    } else {
                      setState(() {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(_errorMessageEvent)));
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                FlatButton(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  color: Theme.of(context).accentColor,
                  child: Text("Sign Up"),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/SignUp');
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
