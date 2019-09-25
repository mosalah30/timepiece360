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
import 'package:easy_dialog/easy_dialog.dart';

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
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String _errorMessageEvent = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentUser;

  _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, "/LoginScreen");
  }

  _isValidPassword(String oldPassword, String newPassword) {
    if (oldPassword == null ||
        oldPassword.trim().isEmpty ||
        oldPassword.length < 7) {
      _errorMessageEvent =
          "you must write your  password  more than 8 character";
      return false;
    }

    if (oldPassword == oldPassword.toLowerCase ||
        oldPassword == oldPassword.toUpperCase) {
      _errorMessageEvent = "Password must include small and capital letter";
      return false;
    }
    if (newPassword == null ||
        newPassword.trim().isEmpty ||
        oldPassword == newPassword) {
      _errorMessageEvent = "old password must  not equal new password";
      return false;
    }

    return true;
  }

  _isValidSignUpdateProfile(
    String name,
    String phone,
  ) {
    if (name == null || name.trim().isEmpty) {
      _errorMessageEvent = "you must write your right name ";
      return false;
    }

    if (phone == null || phone.trim().isEmpty || phone.length < 9) {
      _errorMessageEvent = "you must write your right number phone ";
      return false;
    }

    return true;
  }

  _updatePassword(String newPassword) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final user = await _auth.currentUser();
        if (user != null) {
          user.updatePassword(_oldPasswordController.value.text);
          await Firestore.instance
              .collection('users')
              .document('user')
              .collection(user.email.toString())
              .document("password")
              .setData({
            'password': _oldPasswordController.value.text,
          });
        }
      } catch (error) {
        if (error.toString().contains("ERROR_WRONG_PASSWORD")) {
          _errorMessageEvent =
              "The old password is not true";
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

  _updateProfile() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final user = await _auth.currentUser();
        if (user != null) {
          String imageUrl = await _pickSaveImage(user.email.toString());
          await Firestore.instance
              .collection('users')
              .document('user')
              .collection(user.email.toString())
              .document("profile")
              .setData({
            'phone': _phoneController.value.text,
            'name': _nameController.value.text,
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

  Widget customText(String text) => Padding(
        padding: EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      );

  _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getProfile();
    super.initState();
  }

  _pickSaveImage(String imageId) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(imageId)
        .child("profile")
        .child("profileImage.jpg");
    StorageUploadTask uploadTask = ref.putFile(_image);
    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  _getProfile() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUser = prefs.getString('email').toString();
      DocumentSnapshot documents = await Firestore.instance
          .collection('users')
          .document('user')
          .collection(_currentUser)
          .document("profile")
          .get();

      var data = documents.data;
      setState(() {
        _nameController.text = data['name'];
        _phoneController.text = data['phone'];
        _imageUrl = data['image'];
      });
    }
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
                        _nameController.value.text,
                        _phoneController.value.text,
                      )) {
                        _updateProfile();
                      } else {
                        setState(() {
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text(_errorMessageEvent)));
                        });
                      }
                    },
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
                    child: Text('Change Password'),
                    onPressed: () {
                      EasyDialog(
                          cornerRadius: 15.0,
                          fogOpacity: 0.1,
                          width: 300,
                          height: 250,
                          contentPadding: EdgeInsets.only(top: 12.0),
                          // Needed for the button design
                          contentList: [
                            Container(
                                color: Theme.of(context).backgroundColor,
                                child: Card(
                                    color: Colors.green,
                                    child: customText('Change Password'))),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: 250,
                                child: Column(
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        controller: _oldPasswordController,
                                        maxLines: 1,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            labelText:
                                                'Enter your Old Password',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Flexible(
                                      child: TextField(
                                        controller: _newPasswordController,
                                        maxLines: 1,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            labelText:
                                                'Enter your New Password',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    FlatButton(
                                        child: Card(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            child: customText("Cancel")),
                                        onPressed: () =>
                                            Navigator.of(context).pop()),
                                    FlatButton(
                                        child: Card(
                                            color: Colors.green,
                                            child: customText("update")),
                                        onPressed: ()  {
                                          if (_isValidPassword(
                                              _oldPasswordController.text,
                                              _newPasswordController.text)) {
                                              _updatePassword(
                                                  _newPasswordController.text);
                                              Navigator.of(context).pop();
                                          }else{
                                            setState(() {
                                              _scaffoldKey.currentState.showSnackBar(
                                                  SnackBar(content: Text(_errorMessageEvent)));
                                            });
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          ]).show(context);
                    },
                  )
                ],
              ),
            ],
          )),
    );
  }
}
