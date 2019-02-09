import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';
import 'ReservedPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
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
      home: SplashScreen(),
      routes: routes,
    );
  }
}
