import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Time Piece 360"),
      ),
      body: _MySignUP(),
    );
  }
}

class _MySignUP extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StateMySignUp();
  }
}

class _StateMySignUp extends State<_MySignUP> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _errorMessageEvent;
  RegExp regExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  _isValidSignUp(String email, String password, String name, String phone,
      String rePassword) {
    if (email == null || email.trim().isEmpty || !regExp.hasMatch(email)) {
      _errorMessageEvent = "you must write your right Email ";
      return false;
    }

    if (name == null || name.trim().isEmpty) {
      _errorMessageEvent = "you must write your right name ";
      return false;
    }

    if (phone == null || phone.trim().isEmpty || phone.length < 9) {
      _errorMessageEvent = "you must write your right number phone ";
      return false;
    }

    if (password == null || password.trim().isEmpty || password.length < 7) {
      _errorMessageEvent =
          "you must write your  password  more than 8 character";
      return false;
    }

    if (password == password.toLowerCase || password == password.toUpperCase) {
      _errorMessageEvent = "Password must include small and capital letter";
      return false;
    }
    if (rePassword == null ||
        rePassword.trim().isEmpty ||
        password != rePassword) {
      _errorMessageEvent = "password must equal RePassword";
      return false;
    }

    return true;
  }

  _register() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final  user = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (user != null) {

        await  Firestore.instance.collection('users').document('user').
              collection(_emailController.value.text)
              .document("profile")
              .setData({
            'phone': _phoneController.value.text,
            'name': _nameController.value.text,
            'password': _passwordController.value.text
          });
          _saveProfile(
              email: _emailController.text, password: _passwordController.text);
          Navigator.pushReplacementNamed(context, "/HomeScreen");
        }
      } catch (error) {
        if (error.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")) {
          _errorMessageEvent =
              "The email address is already in use by another account";
        }
        setState(() {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(_errorMessageEvent)));
        });
      }
    } else {
      setState(() {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("no internet connection")));
      });
    }
  }
  var _isLoading = false;

  _getDelay() {
    setState(() {
      _isLoading = true;
    });
    final duration = Duration(seconds: 3);
    Timer(duration, () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  _saveProfile({String email, String password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child:_isLoading == true
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Sign Up",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 50,
                      fontStyle: FontStyle.italic,
                      color: Colors.white),
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
                              BorderSide(width: 5.0, color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(10)))),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: "Name",
                      fillColor: Theme.of(context).accentColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 5.0, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: "Phone",
                      fillColor: Theme.of(context).accentColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 5.0, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: "Password",
                      fillColor: Theme.of(context).accentColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 5.0, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _rePasswordController,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                      labelText: "Re-Password",
                      fillColor: Theme.of(context).accentColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 5.0, color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
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
                  color: Colors.white,
                  child: Text("Sign up"),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    if (_isValidSignUp(
                        _emailController.value.text,
                        _passwordController.value.text,
                        _nameController.value.text,
                        _phoneController.value.text,
                        _rePasswordController.value.text)) {
                      _register();
                      _getDelay();
                    } else {
                      setState(() {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(_errorMessageEvent)));
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _rePasswordController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
