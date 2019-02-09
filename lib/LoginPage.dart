import 'package:flutter/material.dart';
import 'Home.dart';
import 'RegisterPage.dart';
import 'package:random_string/random_string.dart' as random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReservedPage.dart';


class LoginPage extends StatefulWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);

  static String tag = 'LoginPage';
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
  
}

class _LoginPageState extends State<LoginPage> {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  final formkey = new GlobalKey<FormState>();

  String _userName;
  String _password;
  String _userkey;
  String _status;
  var snapshots;
  var place;
  bool isValidUser = false;
  
  

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        getChannelName(_userName, _password);
      } catch (e) {
        print('Error: $e');
      }
    }
  }
  void getChannelName(String username, String password) async {
    var userData;
    var data;
    
    try{
      DocumentSnapshot snapshot = await Firestore.instance.collection('Username').document('$username').get();
      userData = snapshot;
      data = userData['username'];
      if(username == userData['username'] && password == userData['password']){
        if(userData['userkey'] == null || userData['userkey'] == ''){
          _userkey = random.randomAlphaNumeric(20);
          Firestore.instance.collection('Username').document('$username').updateData({'userkey' : "$_userkey"});
          
        }else{
          _userkey = userData['userkey'];
          
        }
        _status = userData['status'];
        if(_status != 'Not Reserve'){
          place = userData['place'];
          DocumentSnapshot dataTime = await Firestore.instance.collection('Reserved Data').document('$_userkey').get();
          DateTime time = dataTime['time'];
          String dataStatus = dataTime['status'];
          DateTime test = DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch+(1000*60*1));
          var now = new DateTime.now();
          var timediff = test.difference(now);
          if(now.millisecondsSinceEpoch < test.millisecondsSinceEpoch || ((now.millisecondsSinceEpoch > test.millisecondsSinceEpoch) && dataStatus == 'Active')){
            Navigator.push(context, new MaterialPageRoute(builder: (context) => 
              new ReservedPage(userName: '$username', userkey: '$_userkey', status: '$_status', place: '$place', time: timediff,)));
          }else{
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: new Text("หมดเวลา"),
                  content: new Text("การจองของท่านได้ถูกยกเลิก เนื่องจากโค้ดหมดอายุการใช้งาน"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("ตกลง"),
                      onPressed: () {
                        timeOut();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }else{
          Navigator.push(context, new MaterialPageRoute(builder: (context) => 
            new HomePage(userName: '$username', userkey: '$_userkey', status: '$_status',)));
        }
        
        
      }else{
        invalidPassword();
      }
    }catch(e){
      invalidUser();
    }
  }
  void invalidUser(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("เกิดข้อผิดพลาด"),
          content: new Text("ชื่อผู้ใช้นี้ไม่มีอยู่ในระบบ กรุณาตรวจสอบชื่อผู้ใช้งานให้ถูกต้อง"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ตกลง"),
              onPressed: () {Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  timeOut() async{
    DocumentSnapshot snapshot = await Firestore.instance.collection('numPark').document('$place').get();
    var data = snapshot;
    var numm = data['count'];
    await Firestore.instance.collection('numPark').document('$place').updateData({'count' : numm+1});
    Firestore.instance.collection('Username').document('$_userName').updateData({'userkey' : "", 'status' : "Not Reserve", 'place' : ''});
    Navigator.push(context, new MaterialPageRoute(builder: (context) => 
      new HomePage(userName: '$_userName', userkey: '$_userkey', status: '$_status',)));;
  }

  void invalidPassword(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("เกิดข้อผิดพลาด"),
          content: new Text("ชื่อผู้ใช้กับรหัสผ่านไม่ตรงกันนี้ กรุณาตรวจสอบข้อมูลให้ถูกต้อง"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ตกลง"),
              onPressed: () {Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void moveToRegister() {
    formkey.currentState.reset();
    setState(() {
      Navigator.of(context).pushNamed(RegisterPage.tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    // authUserAndPassword();
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
      backgroundColor: Colors.yellowAccent,
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
              buildInputEmail('Username', false),
              SizedBox(
                height: 10.0,
              ),
              buildInputs('Password', true),
              SizedBox(
                height: 10.0,
              ),
              buildButton('Login', validateAndSubmit),
              SizedBox(
                height: 5.0,
              ),
              buildButton('Sign-up', moveToRegister),

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
      validator: (value) => value.isEmpty ? 'Password can not be empty' : null,
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
      validator: (value) => value.isEmpty ? 'Email can not be empty' : null,
      onSaved: (value) => _userName = value,
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
