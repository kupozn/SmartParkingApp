import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {

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
          print('Signed in: ${user.uid}');
        }else{
          FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password); 
          print('Registered with: ${user.uid}');
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter login'),
      ),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: formkey,
          child: new Column(
            children: buildInputs() + buildButton(),
          )
        ),
      )
    );
  }

  List<Widget> buildInputs(){
    return [new TextFormField(
                decoration: new InputDecoration(labelText: 'Email'),
                validator: (value) => value.isEmpty ? 'Email can not be empty' : null,
                onSaved: (value) => _email = value,
              ),
              new TextFormField(
                decoration: new InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value.isEmpty ? 'Password can not be empty' : null,
                onSaved: (value) => _password = value,
              )
    ];
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
                )
              ];
    }
      
  }
}