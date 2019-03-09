import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';
import 'ReservedPage.dart';
import 'login/login_page.dart' as newlogin;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => newlogin.LoginPage(),
    RegisterPage.tag: (context) => RegisterPage(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart-Parking",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      home: newlogin.LoginPage(),
      routes: routes,
    );
  }
}
