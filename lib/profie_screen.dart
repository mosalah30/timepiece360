
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _image;
  String _imageUrl;
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  String _errorMessageEvent = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentUser;

  _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, "/LoginScreen");
  }

  _isValidSignUpdateProfile(
      String password, String name, String phone, String rePassword) {
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

  _updateProfile() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final user = await _auth.currentUser();
        if (user != null) {
          String imageUrl = await _pickSaveImage(user.email.toString());
          user.updatePassword(_passwordController.value.text);
          await Firestore.instance.collection('users').document('user')
              .collection(user.email.toString())
              .document("profile")
              .setData({
            'phone': _phoneController.value.text,
            'name': _nameController.value.text,
            'password': _passwordController.value.text,
            'image': imageUrl
          });
          setState(() {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("profile update you will sign out now")));
          });
          Future.delayed(Duration(seconds: 3));
          _logout();
        }
      } catch (error) {
        if (error.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")) {
          _errorMessageEvent =
              "The email address is already in use by another account";
        }
        if (error.toString().contains("ERROR_WRONG_PASSWORD")) {
          _errorMessageEvent =
              "The password is invalid or the user does not have a password";
        }
        setState(() {
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(_errorMessageEvent)));
        });
      }
    } else {
      setState(() {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("no internet connection")));
      });
    }
  }

  _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: _getImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      child: _image != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(_image),
                            )
                          : CircleAvatar(
                              backgroundImage: _imageUrl != null
                                  ? NetworkImage(_imageUrl)
                                  : AssetImage('images/avater.jpg'),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 50,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.black),
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
                  SizedBox(height: 30),
                  TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Phone",
                          labelStyle: TextStyle(color: Colors.black),
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
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.black),
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
                        labelStyle: TextStyle(color: Colors.black),
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
                    child: Text("Update Profile"),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_isValidSignUpdateProfile(
                          _passwordController.value.text,
                          _nameController.value.text,
                          _phoneController.value.text,
                          _rePasswordController.value.text)) {
                        _updateProfile();
                      } else {
                        setState(() {
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text(_errorMessageEvent)));
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }

  _getProfile() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUser = prefs.getString('email').toString();
      DocumentSnapshot documents = await Firestore.instance.collection('users').document('user')
          .collection(_currentUser)
          .document("profile")
          .get();

      var data = documents.data;
      setState(() {
        _passwordController.text = data['password'];
        _rePasswordController.text = data['password'];
        _nameController.text = data['name'];
        _phoneController.text = data['phone'];
        _imageUrl = data['image'];
      });
    }
  }

  @override
  void initState() {
    _getProfile();
    super.initState();
  }

  Future<String> _pickSaveImage(String imageId) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(imageId)
        .child("profile")
        .child("profileImage.jpg");
    StorageUploadTask uploadTask = ref.putFile(_image);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }
}
