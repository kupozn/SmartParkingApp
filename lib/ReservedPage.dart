import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'qrcode.dart';
import 'dart:math' as math;

class ReservedPage extends StatefulWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  static String tag = 'ReservedPage';
  @override
  State<StatefulWidget> createState() => new _ReservedPage();
}

class _ReservedPage extends State<ReservedPage> with TickerProviderStateMixin {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
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

  List<String> textei = ['count', 'reserve', 'uid'];

  //*****TIMER CREATOR*********
  AnimationController controller;
  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );
    controller.addListener((controller.value == 1.0 ? test1234 : test123));
  }

  void test1234() {
    Log();
  }

  Widget Log() {
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
          onPressed: () {},
        ),
      ],
    );
  }

  void test123() {}

  @override
  Widget build(BuildContext context) {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(textei[_bottomNavIndex],
          style: TextStyle(fontSize: 30.0, color: Colors.black)),
    );
    if (_bottomNavIndex == 0) {
      getCurrentUser();
      return _stateReserve();
    } else {
      return test();
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

  Scaffold test() {
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(uid, style: TextStyle(fontSize: 30.0, color: Colors.black)),
    );

    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            text,
            SizedBox(
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
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            Align(
              alignment: FractionalOffset.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Count Down",
                      style: TextStyle(fontSize: 30.0, color: Colors.black)),
                  // new QrImage(
                  //   data: "Hello, world in QR form!",
                  //   size: 200.0,
                  // ),
                  AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {
                        return new Text(
                          timerString,
                          style: TextStyle(fontSize: 30.0, color: Colors.black),
                        );
                      }),
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
            color: Colors.grey,
          ),
          padding: const EdgeInsets.all(10.0),
          child: Text(
            document['count'].toString().padLeft(3, '0'),
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      ]),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
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
                  onPressed: () {
                    document.reference
                        .updateData({'count': document['count'] - 1});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
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
