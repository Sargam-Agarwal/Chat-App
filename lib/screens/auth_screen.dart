import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  UserCredential _authResult;
  File _userDP;
  String _email;
  String _username;
  String _password;
  var _isSignUp = true;
  var _isLoading = false;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 80, maxWidth: 150);

    setState(() {
      if (pickedImage != null) _userDP = File(pickedImage.path);
    });
  }

  String _validateEmail(String value) {
    if (value == null) return 'Please enter the email id!';
    return null;
  }

  String _validateUsername(String value) {
    if (value == null) return 'Please enter a username!';
    if (value.length < 8)
      return 'Username should contain at least 8 characters.';
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Please enter a password!';
    if (value.length < 8)
      return 'Password should contain at least 8 characters.';
    return null;
  }

  void _trySubmit() async {
    if (_userDP == null && _isSignUp) {
      /*Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please take a picture.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );*/
      return;
    }

    //Focus.of(context).unfocus();
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      _formKey.currentState.save();

      try {
        setState(() {
          _isLoading = true;
        });

        if (!_isSignUp)
          _authResult = await _auth
              .signInWithEmailAndPassword(email: _email, password: _password)
              .catchError((error) =>
                  print('LOGIN PROBLEM ##### : ' + error.toString()));
        else {
          _authResult = await _auth.createUserWithEmailAndPassword(
              email: _email, password: _password);

          final ref = FirebaseStorage.instance
              .ref(); // since the path is empty, it returns bucket
          final refPath = ref
              .child('user_dp')
              .child(_authResult.user.uid + '.jpg'); // this return the path now
          await refPath.putFile(_userDP);
          final dpUrl =
              await refPath.getDownloadURL(); // file stored in firebase storage

          await FirebaseFirestore.instance
              .collection('users')
              .doc(_authResult.user.uid)
              .set({
            'username': _username,
            'email': _email,
            'dpUrl': dpUrl
          }).catchError((error) =>
                  print('FIRESTORE PROBLEM ##### : ' + error.toString()));
        }
      } on PlatformException catch (error) {
        var message =
            'Something went wrong! Check your credentials and try again.';

        if (error != null) message = error.message;
        print('PLATFORM EXCEPTION ######: ' + message);
        /*Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );*/
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        /*Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );*/
        print('OTHER ERROR ##### : ' + error.message);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              if (_isSignUp)
                CircleAvatar(
                  radius: 45,
                  backgroundImage: _userDP == null ? null : FileImage(_userDP),
                ),
              if (_isSignUp) SizedBox(height: 5),
              if (_isSignUp)
                FlatButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera),
                  label: Text('Take a picture'),
                ),
              TextFormField(
                key: ValueKey(1),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
                onSaved: (value) {
                  _email = value.trim();
                },
              ),
              if (_isSignUp)
                TextFormField(
                  key: ValueKey(2),
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: _validateUsername,
                  onSaved: (value) {
                    _username = value.trim();
                  },
                ),
              TextFormField(
                key: ValueKey(3),
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: _validatePassword,
                onSaved: (value) {
                  _password = value.trim();
                },
              ),
              if (_isLoading) CircularProgressIndicator(),
              if (!_isLoading)
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  onPressed: _trySubmit,
                  child: Text(_isSignUp ? 'Sign Up' : 'Log In'),
                ),
              if (!_isLoading)
                FlatButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(_isSignUp
                      ? 'Already have an account? LogIn!'
                      : 'Create new account'),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
