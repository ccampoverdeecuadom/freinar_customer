import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_translate/global.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Components/entry_field.dart';
import 'package:user/Pages/blockButtonWidget.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';

import '../../login_navigator.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kMainTextColor),
        title: Text(
          'Registrar',
          style: TextStyle(
              fontSize: 18, color: kMainTextColor, fontWeight: FontWeight.w600),
        ),
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  var fullNameError = "";
  bool hidePassword = true;


  bool showDialogBox = false;
  dynamic token = '';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    firebaseMessagingListner();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Divider(
          color: kCardBackgroundColor,
          thickness: 8.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 10.0,
                left: 2.0,
                right: 2.0,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Crear Nueva cuenta',
                            style: TextStyle(
                                color: kMainTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 25),
                          )),

                      Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              validator: (input) => !input.contains(' ')
                                  ? 'Debe ser Nombre Completo'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Nombre Completo',
                                labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'Nombre Completo',
                                hintStyle: TextStyle(
                                    color:
                                    Theme.of(context).focusColor.withOpacity(0.7)),
                                prefixIcon: Icon(Icons.person,
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
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              validator: (input) => input.length < 10
                                  ? 'Debe ser un número de celular válido'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Teléfono',
                                labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: '0987654321',
                                hintStyle: TextStyle(
                                    color:
                                    Theme.of(context).focusColor.withOpacity(0.7)),
                                prefixIcon: Icon(Icons.phone,
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
                            TextFormField(
                              obscureText: hidePassword,
                              keyboardType: TextInputType.text,
                              controller: _confirmPasswordController,
                              validator: (input) => _passwordController.text == _confirmPasswordController.text
                                  ? 'Las contraseñas deben conincidir'
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Contraseña',
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

                            SizedBox(height: 15),

//                      SizedBox(height: 10),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "Al registrarte aceptas los",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: kMainTextColor,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w500,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          ' Términos y Condiciones',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: appbar_color,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w500,
                                      ))
                                ])),
                      ),
                      SizedBox(height: 10.0),
                      Visibility(
                          visible: showDialogBox,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 20,
                right: 20.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showDialogBox = true;
                    });
                    if (_nameController.text.isEmpty) {
                      Toast.show("Ingresa tu Nombre Completo", context,
                          gravity: Toast.BOTTOM);
                      setState(() {
                        showDialogBox = false;
                      });
                    } else if (_emailController.text.isEmpty ||
                        !_emailController.text.contains('@') ||
                        !_emailController.text.contains('.')) {
                      setState(() {
                        showDialogBox = false;
                      });
                      Toast.show("Enter valied Email address!", context,
                          gravity: Toast.BOTTOM);
                    } else {
                      hitService(_nameController.text, _emailController.text, _phoneController.text,
                          _passwordController.text, _confirmPasswordController.text, context);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: kMainColor),
                    child: Text(
                      translate('continue'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void hitService(
      String name, String email, String phone, String password, String confirmPass, BuildContext context) async {
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
          Navigator.pushNamed(context, LoginRoutes.verification);
        }
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        setState(() {
          token = value;
        });
        print('${value}');
        hitService(name, email, phone, password, confirmPass, context);
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
