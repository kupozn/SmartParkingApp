import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'Auth.dart';

class RegisterPage extends StatefulWidget {
  static String tag = 'RegisterPage';
  RegisterPage({this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RegisterPageState();
}

enum FormType { login, register }

class _RegisterPageState extends State<RegisterPage> {
  final formkey = new GlobalKey<FormState>();

  String _email;
  String _password;

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    print('false');
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        String userId =
            await widget.auth.createUserwithEmailAndPassWord(_email, _password);
        print('Registered with : email = $userId');
        Navigator.of(context).pushNamed(LoginPage.tag);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void moveToLogin() {
    formkey.currentState.reset();
    setState(() {
      Navigator.of(context).pushNamed(LoginPage.tag);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: new Form(
          key: formkey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(
                height: 30.0,
              ),
              buildInputEmail('Email', false),
              SizedBox(
                height: 10.0,
              ),
              buildInputs('Password', true),
              SizedBox(
                height: 10.0,
              ),
              buildButton('Create an account', validateAndSubmit),
              SizedBox(
                height: 5.0,
              ),
              buildButton('Have an account?', moveToLogin)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputs(words, cmd) {
    return TextFormField(
      autofocus: false,
      decoration: new InputDecoration(
          hintText: words,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      obscureText: cmd,
      validator: (value) => value.isEmpty ? words + ' can not be empty' : null,
      onSaved: (value) => _password = value,
    );
  }

  Widget buildInputEmail(words, cmd) {
    return TextFormField(
      autofocus: false,
      decoration: new InputDecoration(
          hintText: words,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      obscureText: cmd,
      validator: (value) => value.isEmpty ? words + ' can not be empty' : null,
      onSaved: (value) => _email = value,
    );
  }

  Widget buildButton(words, cmd) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Material(
            borderRadius: BorderRadius.circular(30.0),
            shadowColor: Colors.lightBlueAccent.shade100,
            elevation: 5.0,
            child: MaterialButton(
              minWidth: 200.0,
              height: 50.0,
              onPressed: cmd,
              color: Colors.lightBlueAccent,
              child: Text(words,
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            )));
  }
}
