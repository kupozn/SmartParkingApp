import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'LoginPage';
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType{
  login, 
  register
}

class _LoginPageState extends State<LoginPage>{

  final formkey = new GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

  bool validateAndSave(){
    final form = formkey.currentState;
    if (form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async{
    if (validateAndSave()){
      try{
        if(_formType == FormType.login){
          FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password); 
          print('Signed in  : email = ${_email}');
        }else{
          FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password); 
          print('Registered with : email = ${_email}');
        }
          
      } catch(e){
        print('Error: $e');
      }
      }
  }

  void moveToRegister(){
    formkey.currentState.reset();
    setState((){
      _formType = FormType.register;
    });
  }

  void moveToLogin(){
    formkey.currentState.reset();
    setState((){
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context){

    final textbox = TextFormField(
                autofocus: false,
                decoration: new InputDecoration(
                hintText: 'Email',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                obscureText: true,
                //validator: (value) => value.isEmpty ? 'Email can not be empty' : null,
                //onSaved: (value) => _password = value,
              );
    final button = Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(30.0),
                    shadowColor: Colors.lightBlueAccent.shade100,
                    elevation: 5.0,
                    child: MaterialButton(
                      minWidth: 200.0,
                      height: 42.0,
                      onPressed:(){Navigator.of(context).pushNamed(HomePage.tag);},
                      color: Colors.lightBlueAccent,
                      child: Text('Login', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                      )
                    )
                  );
    final logo = CircleAvatar(
                        backgroundColor: Colors.lightBlueAccent,
                        radius: 50.0,
                        child: Icon(
                          Icons.airport_shuttle,
                          color: Colors.yellowAccent,
                          size: 50.0,
                        ),
                      );
    return new Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo, SizedBox(height: 30.0,), 
            textbox, SizedBox(height: 10.0,),
            textbox, SizedBox(height: 10.0,),
            buildInputs('Hello'), SizedBox(height: 10.0,),
            button
          ],
        ),
      ),
      // body: new Container(
      //   padding: EdgeInsets.all(16.0),
      //   child: new Form(
      //     key: formkey,
      //     child: new Column(
      //       children: buildInputs('Login', 10.0) + buildInputs('Password', 10.0)+ buildButton(),
      //     )
      //   ),
      // )
    );
  }

  Widget buildInputs(words){
    return TextFormField(
                autofocus: false,
                decoration: new InputDecoration(
                hintText: words,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                obscureText: true,
                validator: (value) => value.isEmpty ? words+' can not be empty' : null,
                onSaved: (value) => _password = value,
              );
    
  }
  List<Widget> buildButton(){
    if(_formType == FormType.login){
      return [new RaisedButton(
                  child: new Text('Login', style: new TextStyle(fontSize: 20.0)),
                  onPressed: validateAndSubmit,
                ),
                new FlatButton(
                  child: new Text('Create an Account', style: new TextStyle(fontSize: 20.0)),
                  onPressed: moveToRegister,
                )
      ];
    }else{
      return [new RaisedButton(
                  child: new Text('Create an Account', style: new TextStyle(fontSize: 20.0)),
                  onPressed: validateAndSubmit,
                ),
                new FlatButton(
                  child: new Text('Go to sign in', style: new TextStyle(fontSize: 20.0)),
                  onPressed: moveToLogin,
                ),
                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(30.0),
                    shadowColor: Colors.lightBlueAccent.shade100,
                    elevation: 5.0,
                    child: MaterialButton(
                      minWidth: 200.0,
                      height: 42.0,
                      onPressed: validateAndSubmit,
                      color: Colors.lightBlueAccent,
                      child: Text('Login', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                    ),
                  
                  ),
                )
              ];
    }
      
  }
}