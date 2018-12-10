import 'package:flutter/material.dart';
import 'Home.dart';
import 'LoginPage.dart';
import 'SplashScreen.dart';
import 'RegisterPage.dart';
import 'Auth.dart';
import 'ReservedPage.dart';
// import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  final routes = <String, WidgetBuilder>{
    HomePage.tag: (context) => HomePage(),
    LoginPage.tag: (context) => LoginPage(auth: new Auth()),
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

  // void getCurrentUser() async {
  //   String uid = 'asd';
  //   try {
  //     FirebaseUser user = await FirebaseAuth.instance.currentUser();
  //     uid = user.email;
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
}
