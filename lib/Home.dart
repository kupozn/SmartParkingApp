import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'ReservedPage.dart';
import 'SplashScreen.dart';
import 'dart:math' as math;
import 'qrcode.dart';

class HomePage extends StatefulWidget {
  static String tag = 'HomePage';
  static String status = 'No';
  static DocumentSnapshot test;
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>  with TickerProviderStateMixin  {
  int _bottomNavIndex = 0;
  String _value = '';
  String uid = 'asd';
  void getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      uid = user.email;
    } catch (e) {
      print('Error: $e');
    }
  }

  AnimationController controller;
  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    if(HomePage.status != 'No'){
      super.initState();
      controller = AnimationController(
        vsync: this,
        duration: Duration(minutes: 15, seconds: 30),
      );
    }
    // controller.addListener((controller.value == 1.0 ? test1234 : test123));
  }
  
  @override
  Widget build(BuildContext context) {
    if (_bottomNavIndex == 0) {
      getCurrentUser();
      if(HomePage.status == 'No') {
        return _stateReserve();
      }else{
        return _stateReserved();
      }
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

  Scaffold profile() {
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(uid, style: TextStyle(fontSize: 30.0, color: Colors.black)),
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

  Widget _stateReserve() {
    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      backgroundColor: Colors.limeAccent,
      body: StreamBuilder(
        stream: Firestore.instance.collection('Parking').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SplashScreen();
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) => 
              buildListItemPark(context, snapshot.data.documents[index]),
          );
        },
      ),
    );
  }

  Widget _stateReserved() {
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
                      data: "Hello, world in QR form!",
                      size: 250.0,
                    ),
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

  void signOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamed(LoginPage.tag);
      } catch (e) {
        print('Error: $e');
      }
  }

  cancleQueue() {
    HomePage.status = 'No';
    Navigator.of(context).pushNamed(HomePage.tag);
  }

  changeStatus(DocumentSnapshot document){
    if(HomePage.status == 'No'){
      document.reference.updateData({'count': (document['count'] > 0 ? document['count']-1 : document['count'])});
      HomePage.status = "Reserved";
    }
    Navigator.of(context).pushNamed(HomePage.tag);
  } 

  List<String> _itemDrop(){
    List<String> list = [];
    StreamBuilder(
        stream: Firestore.instance.collection('Parking').snapshots(),
        builder: (context, snapshot) {
          for(int i=0; i <= snapshot.data.documents.length;i++){
            list.add(snapshot.data.documents[i].toString());
            }
          }
        );
    return list;

  }

  Widget buildListItemPark(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(children: [
        Expanded(
          child: Text(
            document['name'],
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.pinkAccent,
          ),
          padding: const EdgeInsets.all(10.0),
          child: Text(
            document['count'].toString().padLeft(3, '0'),
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      ]),
      onTap: () {showDialog(
            context: context,
            builder: (BuildContext context) {if(document['count'] == 0){
              return AlertDialog(
                title: new Text("ไม่สามารถจองที่จอดได้"),
                content: new Text("ที่จอดที่นี่ได้ถูกจองเต็มจำนวนแล้ว กรุณาเลือกที่จอดที่อื่น"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("ตกลง"),
                    onPressed: () {Navigator.of(context).pop();
                      // if(HomePage.status == 'No'){
                      //     document.reference.updateData({'count': (document['count'] > 0 ? document['count']-1 : document['count'])});
                      //     HomePage.status = "Reserved";
                      //   }
                      //   Navigator.of(context).pushNamed(HomePage.tag);
                    },
                  ),
                ],
              );
            }else{
              // return object of type AlertDialog
              return AlertDialog(
                title: new Text("ยืนยันนการจองที่จอด"),
                content: new Text("You can only reserve parking at once"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("ยกเลิก"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("ตกลง"),
                    onPressed: () {changeStatus(document);
                      // if(HomePage.status == 'No'){
                      //     document.reference.updateData({'count': (document['count'] > 0 ? document['count']-1 : document['count'])});
                      //     HomePage.status = "Reserved";
                      //   }
                      //   Navigator.of(context).pushNamed(HomePage.tag);
                    },
                  ),
                ],
              );
            }
            },
          );
        
      },
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

  /*ANOTHER CODE*/
  Scaffold drop() {

    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(uid, style: TextStyle(fontSize: 30.0, color: Colors.black)),
    );
    List<String> nameDrop = _itemDrop();
    _value = nameDrop.elementAt(0);
    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            new DropdownButton(
              value: _value,
              items: nameDrop.map((String value){
                return new DropdownMenuItem(
                  value: value,
                  child: new Row(
                    children: <Widget>[
                        new Text('${value}')
                      ],
                    ),
                  );
                }).toList(),
              onChanged: null,
            ),
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
  
}

class TimerPainter extends CustomPainter {
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
    canvas.drawArc(Offset.zero & size, math.pi* 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }

}