import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';
import 'Auth.dart';

void main(){
  runApp(new MyApp());
}

class MyApp extends StatelessWidget{

  final routes = <String, WidgetBuilder>{
    HomePage.tag: (context) => HomePage(),
    LoginPage.tag: (context) => LoginPage(auth: new Auth()),
    RegisterPage.tag: (context) => RegisterPage(),
  };
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: "Smart-Parking",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      home: HomePage(),
      routes: routes,
    );
  }

}