import 'package:flutter/material.dart';
import 'login_page.dart';
import 'SplashScreen.dart';

void main(){
  runApp(new MyApp());
}

class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: "Flutter login page",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen()
    );
  }

}