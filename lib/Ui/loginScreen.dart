import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String messageValidation = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/loginImg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                    margin: EdgeInsets.all(30),
                    child: Text(
                      'Rate Your Article ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueGrey),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Number cannot be empty';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                      cursorColor: Color(0xFF9b9b9b),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_android,
                          color: Colors.cyanAccent,
                        ),
                        hintText: 'Input Email',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(
                            Radius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value.isEmpty) return 'Password cannot be empty';
                        return null;
                      },
                      obscureText: true,
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                      cursorColor: Color(0xFF9b9b9b),
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.vpn_key, color: Colors.cyanAccent),
                        hintText: 'Input Password',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 30, top: 30, right: 30),
                    child: RaisedButton(
                      elevation: 10,
                      color: Colors.pink,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      onPressed: _login,
                      child: Text(
                        _isLoading ? 'Login..' : 'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    messageValidation,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        messageValidation = '';
        _isLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final url = 'https://iotait.tech/ArticleRating/public/articles/user';
      Map data = {
        'email': emailController.text,
        'password': passwordController.text
      };

      var bodyValue = json.encode(data);

      http.Response response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: bodyValue);

      Map<String, dynamic> user = jsonDecode(response.body);

      if (user['success'] == 1 || user['success'] == 2) {
        prefs.setString("userEmail", user['email']);

        emailController.clear();
        passwordController.clear();
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      } else {
        setState(() {
          messageValidation = user['msg'];
          _isLoading = false;
        });
      }
    }
  }
}
