import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Auth/Registration/UI/register_page.dart';
import 'package:user/Auth/login_navigator.dart';
import 'package:user/Components/entry_field.dart';
import 'package:user/HomeOrderAccount/Home/UI/new_home.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:http/http.dart' as http;

import 'blockButtonWidget.dart';

class Login extends StatefulWidget {
  @override
  _Logintate createState() => _Logintate();
}

class _Logintate extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  var fullNameError = "";

  bool showDialogBox = false;
  dynamic token = '';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    firebaseMessagingListner();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Positioned(
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.37,
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.37 - 50,
            child: Container(
              decoration: BoxDecoration(
                  color: kCardBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 50,
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                    )
                  ]),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding:
                  EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
              width: MediaQuery.of(context).size.width * 0.88,
//              height: config.App(context).appHeight(55),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (input) => !input.contains('@')
                          ? 'Debe ser un email válido'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        contentPadding: EdgeInsets.all(12),
                        hintText: 'carlosc@ejemplo.com',
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.alternate_email,
                            color: Theme.of(context).accentColor),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.5))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2))),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      obscureText: hidePassword,
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      validator: (input) => input.length < 3
                          ? 'Debe tener mas de 3 caracteres'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        contentPadding: EdgeInsets.all(12),
                        hintText: '••••••••••••',
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).accentColor),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          color: Theme.of(context).focusColor,
                          icon: Icon(hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.5))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2))),
                      ),
                    ),
                    SizedBox(height: 30),
                    BlockButtonWidget(
                      text: Text(
                        'Entrar',
                        style: TextStyle(color: kWhiteColor),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        login(_emailController.text, _passwordController.text,
                            context);
                      },
                    ),
                    SizedBox(height: 15),
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                      },
                      shape: StadiumBorder(),
                      textColor: Theme.of(context).hintColor,
                      child: Text('No tengo una Cuenta'),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    ),
//                      SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/ForgetPassword');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text('Olvidé mi Contraseña'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void login(String email, String pssw, BuildContext context) {
    Navigator.popAndPushNamed(context, LoginRoutes.homepage);
  }

  void hitService(String name, String email, BuildContext context) async {
    if (token != null && token.toString().length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phoneNumber = prefs.getString('user_phone');
      var url = registerApi;
      http.post(url, body: {
        'user_name': name,
        'user_email': email,
        'user_phone': phoneNumber,
        'user_password': 'no',
        'device_id': '${token}',
        'user_image': 'usre.png'
      }).then((value) {
        print('Response Body: - ${value.body.toString()}');
        if (value.statusCode == 200) {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.homepage);
        }
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        setState(() {
          token = value;
        });
        print('${value}');
        hitService(name, email, context);
      });
    }
  }

  void firebaseMessagingListner() async {
    if (Platform.isIOS) iosPermission();
    firebaseMessaging.getToken().then((value) {
      setState(() {
        token = value;
      });
    });
  }

  void iosPermission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered.listen((event) {});
  }
}
