import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_parking/login/theme.dart' as ThemeBase;
import 'package:smart_parking/login/bubble_indication_painter.dart';
import 'package:random_string/random_string.dart' as random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_parking/Home.dart';
import 'package:smart_parking/ReservedPage.dart';
import 'login/login_page.dart'; 
import 'qrcode.dart';
import 'NewHome.dart';

class ReservedPagee extends StatefulWidget {

  final String userName;
  final String userkey;
  final String status;
  final String place;
  final Duration time;

  ReservedPagee({Key key, @required this.userName, this.userkey, this.status, this.place, this.time})
      : super(key: key);

  static String tag = 'ReservedPagee';
  @override
  _ReservedPageState createState() => new _ReservedPageState(userName, userkey, status, place, time);
}

class _ReservedPageState extends State<ReservedPagee>
    with SingleTickerProviderStateMixin {
  _ReservedPageState(String userName, String userkey, String status, String place, var time) {
    this.userName = userName;
    this.userkey = userkey;
    this.status = status;
    this.place = place;
    this.time = time;
  }

  String userName;
  String userkey;
  String status;
  String place;
  Duration time;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  var snapshots;
  bool isValidUser = false;

  AnimationController controller;
  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '       ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    return new Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height >= 600.0
                    ? MediaQuery.of(context).size.height
                    : 600.0,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        ThemeBase.Colors.loginGradientStart,
                        ThemeBase.Colors.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) {
                          if (i == 0) {
                            setState(() {
                              right = Colors.white;
                              left = Colors.black;
                            });
                          } else if (i == 1) {
                            setState(() {
                              right = Colors.black;
                              left = Colors.white;
                            });
                          }
                        },
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: _buildProfile(context),
                            ),
                          ),
                          new ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: _buildSignUp(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: _buildCode(context),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: time.inMinutes, seconds: time.inSeconds % 60),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  Widget _buildCode(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(top: 100.0),
      width: 420.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        // borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController, dxTarget: 180.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "RESERVE",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "PROFILE",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    controller.reverse(from: controller.value == 0.0 ? 1.0 : controller.value);
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 350.0,
                  height: 530.0,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 20.0),
                        child: QrImage(
                          data: "$userkey",
                          size: 250.0,
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 30.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            Text('       $userName', style: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 20.0
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.car,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return Text(
                                '       $place',
                                style: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 20.0, color: Colors.black),
                              );
                            }),
                          ],
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.clock,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return Text(
                                timerString,
                                style: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 20.0, color: Colors.black),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 480.0),
                child : Container(
                  margin: EdgeInsets.only(top: 20.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: ThemeBase.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: ThemeBase.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: new LinearGradient(
                        colors: [
                          ThemeBase.Colors.loginGradientEnd,
                          ThemeBase.Colors.loginGradientStart
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: ThemeBase.Colors.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () => cancleQueue(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 300.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 130.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            Text('       $userName', style: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 20.0
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.car,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            Text('       -', style: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 20.0
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 250.0),
                child : Container(
                  margin: EdgeInsets.only(top: 20.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: ThemeBase.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: ThemeBase.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: new LinearGradient(
                        colors: [
                          ThemeBase.Colors.loginGradientEnd,
                          ThemeBase.Colors.loginGradientStart
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: ThemeBase.Colors.loginGradientEnd,
                    onPressed: () =>  signOut(),
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN OUT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ยืนยันที่จะลงชื่อออก"),
          content: Text(
              "หากท่านออกจากระบบแล้ว สถานะการจองของท่านจะถูกยกเลิกทันที ยืนยันที่จะออกจากระบบหรือไม่"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("ยกเลิก"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("ตกลง"),
              onPressed: () {
                Firestore.instance
                    .collection('Username')
                    .document('$userName')
                    .updateData(
                        {'userkey': "", 'status': "Not Reserve", 'place': ''});
                Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage()));
              },
            ),
          ],
        );
      },
    );
  }

  cancleQueue() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ยืนยันการยกเลิกการจองคิว"),
            content: Text(
                "การยกเลิกการจองคิวจะไม่สามารถเรียกคืนคิวได้ ยืนยันที่ยกเลิกการจอง"),
            actions: <Widget>[
              FlatButton(
                child: Text("ยกเลิก"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("ตกลง"),
                onPressed: () {
                  routeHomepage();
                },
              ),
            ],
          );
        });
  }

  routeHomepage() async {
    var _status;
    var numm;
    var data;
    DocumentSnapshot snapshot = await Firestore.instance.collection('numPark').document('$place').get();
    data = snapshot;
    numm = data['count'];
    DocumentSnapshot dataStatus = await Firestore.instance
        .collection('Username')
        .document('$userName')
        .get();
    _status = dataStatus['status'];
    print(status);
    if (_status != 'Not Reserve') {
      await Firestore.instance
          .collection('numPark')
          .document('$place')
          .updateData({'count': numm + 1});
      await Firestore.instance
          .collection('Username')
          .document('$userName')
          .updateData({'status': "Not Reserve", 'place': ""});
      await Firestore.instance
          .collection('ScanerTest')
          .document('$userkey')
          .delete();
      status = 'Not Reserve';
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePagee(
                  userName: '$userName',
                  userkey: '$userkey',
                  status: '$status')));
    } else {
      sessionOut();
    }
  }

  sessionOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("เกิดข้อผิดพลาด"),
          content: Text(
              "การจองของท่านถูกยกเลิกแล้ว อาจเกิดจากการเข้าระบบจากที่อื่น กรุณาเข้าระบบใหม่อีกครั้งเพื่อเริ่มต้นการใช้งาน"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("ตกลง"),
              onPressed: () {
                Navigator.of(context).pushNamed(LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
  }

}
