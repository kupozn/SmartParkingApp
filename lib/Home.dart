import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  static String tag = 'HomePage';

  @override
  Widget build(BuildContext context){
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Welcome To My',
        style: TextStyle(fontSize: 30.0, color: Colors.black)
      ),
    );

    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 30.0,), 
            text,
          ],
        ),
      ),
    );
  }
}