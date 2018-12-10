import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';
import 'ReservedPage.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  final routes = <String, WidgetBuilder>{
    HomePage.tag: (context) => HomePage(),
    LoginPage.tag: (context) => LoginPage(),
    RegisterPage.tag: (context) => RegisterPage(),
    ReservedPage.tag: (context) => ReservedPage(),
  };
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Smart-Parking",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}
