import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';

void main(){
  runApp(new MyApp());
}

class MyApp extends StatelessWidget{

  final routes = <String, WidgetBuilder>{
    HomePage.tag: (context) => HomePage(),
    LoginPage.tag: (context) => LoginPage(),
    RegisterPage.tag: (context) => RegisterPage(),
  };
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: "Flutter test ",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      home: SplashScreen(),
      routes: routes,
    );
  }

}