import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'Home.dart';
import 'qrcode.dart';
import 'dart:math' as math;

class ReservedPage extends StatefulWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  static String tag = 'ReservedPage';

  final String userName;
  final String userkey;
  final String status;
  final String place;
  final Duration time;

  ReservedPage({Key key, @required this.userName, this.userkey, this.status, this.place, this.time}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ReservedPage(userName, userkey, status, place, time);
}

class _ReservedPage extends State<ReservedPage> with TickerProviderStateMixin {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  _ReservedPage(String userName, String userkey, String status, String place, var time){
    this.userName = userName;
    this.userkey = userkey;
    this.status = status;
    this.place = place;
    this.time = time;
  }
  int _bottomNavIndex = 0;
  String _value = '';
  List<String> textei = ['count', 'reserve', 'uid'];
  DocumentSnapshot dataDocument;
  String userName;
  String userkey;
  String status;
  String place;
  Duration time;

  //*****TIMER CREATOR*********
  AnimationController controller;
  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    
    
  }

  @override
  void initState(){
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: time.inMinutes, seconds: time.inSeconds % 60),
    );
  }


  @override
  Widget build(BuildContext context) {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(textei[_bottomNavIndex],
          style: TextStyle(fontSize: 30.0, color: Colors.black)),
    );
    if (_bottomNavIndex == 0) {
      return _stateReserve();
    } else {
      return profile();
    }
  }

  Widget buildButtomBar() {
    final icon1 = Icon(
      Icons.airport_shuttle,
      color: Colors.blueAccent,
      size: 30.0,
    );
    return new BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (int index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        items: [
          new BottomNavigationBarItem(
            icon: icon1,
            title: new Text('Reserve'),
          ),
          new BottomNavigationBarItem(
            icon: icon1,
            title: new Text('Profile'),
          ),
        ]);
  }


  Widget _stateReserve() {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      backgroundColor: Colors.limeAccent,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: FractionalOffset.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Count Down", 
                    style: TextStyle(fontSize: 30.0, color: Colors.black)
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  new QrImage(
                    data: "$userkey",
                    size: 250.0,
                  ),
                  // getImage(),
                  SizedBox(
                    height: 10.0,
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (BuildContext context, Widget child) {
                    return new Text(
                      timerString,
                      style: TextStyle(fontSize: 30.0, color: Colors.black),
                    );
                  }),
                  SizedBox(
                    height: 20.0,
                  ),
                  buildButton('Cancle', cancleQueue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // getTime() async{
  //   DocumentSnapshot data = await Firestore.instance.collection('Reserved Data').document('$userkey').get();
  //   DateTime time = data['time'];
  //   var now = new DateTime.now();
  //   var timediff = now.difference(time);
  //   min = timediff.inMinutes;
  // }

  cancleQueue() async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("ยืนยันการยกเลิกการจองคิว"),
          content: new Text("การยกเลิกการจองคิวจะไม่สามารถเรียกคืนคิวได้ ยืนยันที่ยกเลิกการจอง"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ยกเลิก"),
              onPressed: () {Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("ตกลง"),
              onPressed: () {routeHomepage();
              },
            ),
          ],
        );
      }
    );
  }


  routeHomepage() async{
    var _status;
    var numm;
    var data;
    DocumentSnapshot snapshot = await Firestore.instance.collection('Parking').document('$place').get();
    data = snapshot;
    numm = data['count'];
    DocumentSnapshot dataStatus = await Firestore.instance.collection('Username').document('$userName').get();
    _status = dataStatus['status'];
    print(status);
    if(_status != 'Not Reserve'){
      await Firestore.instance.collection('Parking').document('$place').updateData({'count' : numm+1});
      await Firestore.instance.collection('Username').document('$userName').updateData({'status' : "Not Reserve", 'place' : ""});
      await Firestore.instance.collection('ScanerTest').document('$userkey').delete();
      status = 'Not Reserve';
      Navigator.push(context,  MaterialPageRoute(builder: (context) => new HomePage(userName: '$userName', userkey: '$userkey', status: '$status')));
    }else{
      sessionOut();
    }
  }

  Scaffold profile() {
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Username : $userName', style: TextStyle(fontSize: 30.0, color: Colors.black)),
    );

    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      backgroundColor: Colors.limeAccent,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            text,SizedBox(
                height: 50.0,
              ),
              buildButton('SignOut', signOut)
          ],
        ),
      ),
    );
  }
  sessionOut(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("เกิดข้อผิดพลาด"),
          content: new Text("การจองของท่านถูกยกเลิกแล้ว อาจเกิดจากการเข้าระบบจากที่อื่น กรุณาเข้าระบบใหม่อีกครั้งเพื่อเริ่มต้นการใช้งาน"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pushNamed(LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
  }
void signOut(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("ยืนยันที่จะลงชื่อออก"),
          content: new Text("หากท่านออกจากระบบแล้ว สถานะการจองของท่านจะถูกยกเลิกทันที ยืนยันที่จะออกจากระบบหรือไม่"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("ยกเลิก"),
              onPressed: () {Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("ตกลง"),
              onPressed: () {
                signOutAction();
                Navigator.of(context).pushNamed(LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
  }

  signOutAction() async{
    var numm;
    var data;
    DocumentSnapshot snapshot = await Firestore.instance.collection('Parking').document('$place').get();
    data = snapshot;
    numm = data['count'];
    await Firestore.instance.collection('Parking').document('$place').updateData({'count' : numm+1});
    await Firestore.instance.collection('Username').document('$userName').updateData({'userkey' : "", 'status' : "Not Reserve", 'place' : ""});
    await Firestore.instance.collection('ScanerTest').document('$userkey').delete();
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

class TimerPainter extends CustomPainter {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
