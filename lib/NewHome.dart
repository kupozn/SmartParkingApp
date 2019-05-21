import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_parking/login/theme.dart' as ThemeBase;
import 'package:smart_parking/login/bubble_indication_painter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login/login_page.dart'; 
import 'NewReserved.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePagee extends StatefulWidget {

  final String userName;
  final String userkey;
  final String status;
  HomePagee({Key key, @required this.userName, this.userkey, this.status})
      : super(key: key);

  static String tag = 'HomePagee';
  @override
  _HomePageState createState() => new _HomePageState(userName, userkey, status);
}

class _HomePageState extends State<HomePagee>
    with SingleTickerProviderStateMixin {
  _HomePageState(String userName, String userkey, String status) {
    this.userName = userName;
    this.userkey = userkey;
    this.status = status;
  }

  String userName;
  String userkey;
  String status;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  var snapshots;
  var place;
  var selectPlace;
  bool chkSelect = false;
  bool isValidUser = false;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  static const LatLng _center = const LatLng(13.730718, 100.781385);
   Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                              this.chkSelect = false;
                            });
                          } else if (i == 1) {
                            setState(() {
                              right = Colors.black;
                              left = Colors.white;
                              this.chkSelect = false;
                            });
                          }
                        },
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: _buildmenu(context),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: _buildprofile(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: _buildMenuBar(context),
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  Widget _buildMenuBar(BuildContext context) {
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

  Widget _buildmenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topCenter,
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          width: 350.0,
                          height: 250.0,
                          child: Stack(
                            children: <Widget>[
                              GoogleMap(
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                                initialCameraPosition: CameraPosition(
                                  target: _center,
                                  zoom: 11.0,
                                ),
                                mapType: _currentMapType,
                                markers: _markers,
                                onCameraMove: _onCameraMove,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 285.0),
                child: Card(
                elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: 350.0,
                    height: 250.0,
                    child: StreamBuilder(
                      stream: Firestore.instance.collection('numPark').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(child :CircularProgressIndicator());
                        return ListView.builder(
                          itemExtent: 80.0,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) =>
                            buildListItemPark(context, snapshot.data.documents[index]),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 530.0),
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
                        "RESERVE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () => reserveButton(this.selectPlace),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildListItemPark(BuildContext context, DocumentSnapshot document) {
    /************************LIST ITEM IN HOME PAGE ***********************************/
    return ListTile(
      title: Row(children: [
        Expanded(
          child: Text(
            document.documentID,
            style: TextStyle(
              fontSize: 22.0,
              fontFamily: "WorkSansMedium"
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.pinkAccent,
          ),
          padding: const EdgeInsets.all(10.0),
          child: Text(
            document['count'].toString().padLeft(3, '0'),
            style: TextStyle(
              fontSize: 22.0,
              fontFamily: "WorkSansMedium"
            ),
          ),
        ),
      ]),
      onTap: () {
        changePlace(document);
        _onAddMarkerButtonPressed(document.documentID, document['count'], document['lad'], document['long']);
      },
    );
  }

  Widget _buildprofile(BuildContext context) {
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
                    onPressed: ()  {
                      signOut();
                    },
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

  void _onAddMarkerButtonPressed(String name, var count, var lad, var long) {
    this._markers = {};
    setState(() {
      this.chkSelect = true;
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: LatLng(lad, long),
        infoWindow: InfoWindow(
          title: '$name',
          snippet: 'Parking avalable $count slots.',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  changeStatus(DocumentSnapshot document) async {
    var place = document.documentID;
    var now = DateTime.now();
    DocumentSnapshot data = await Firestore.instance
        .collection('Username')
        .document('$userName')
        .get();
    status = data['status'];
    print(status);
    if (status == 'Not Reserve') {
      document.reference.updateData({
        'count':
            (document['count'] > 0 ? document['count'] - 1 : document['count'])
      });
      Firestore.instance
          .collection('Username')
          .document('$userName')
          .updateData({'status': "Reserved", 'place': "$place"});
      Firestore.instance
          .collection('Reserved Data')
          .document('$userkey')
          .setData({'status': 'Not Active', 'place': "$place", 'time': now, 'user': '$userName'});
      Firestore.instance
          .collection('ScanerTest')
          .document('$userkey')
          .setData({'place': "$place"});
      DocumentSnapshot dataTime = await Firestore.instance
          .collection('Reserved Data')
          .document('$userkey')
          .get();
      DateTime time = dataTime['time'];
      DateTime test = DateTime.fromMillisecondsSinceEpoch(
          time.millisecondsSinceEpoch + (1000 * 3600 * 1));
      var timediff = test.difference(now);
      print('timediff  $timediff');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReservedPagee(
                    userName: '$userName',
                    userkey: '$userkey',
                    status: '$status',
                    place: '$place',
                    time: timediff,
                  )));
    } else {
      alreadyReserve();
    }
  }

  alreadyReserve() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("เกิดข้อผิดพลาด"),
          content: Text(
              "ไม่สามารถจองได้ เนื่องจากบัญชีของท่านได้ใช้งานการจองไปแล้วกรุณาเข้าสู่ระบบอีกครั้งเพื่อไปหน้าการจอง"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("ตกลง"),
              onPressed: () {
              //   Navigator.of(context).pushNamed(newlogin.LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
  }

  changePlace(DocumentSnapshot document) {
    this.selectPlace = document;
    this.chkSelect = true;
    print(this.chkSelect);
    var lad = document['lad'];
    var long = document['long'];
    var name = document.documentID;
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lad, long),
        15.0, // Zoom factor
      ),
    );
  }

  reserveButton(DocumentSnapshot document) {
    print(this.chkSelect);
    if(this.chkSelect){
      showDialog(
      context: context,
      builder: (BuildContext context) {
        if (document['count'] == 0) {
          return AlertDialog(
            title: Text("ไม่สามารถจองที่จอดได้"),
            content: Text(
                "ที่จอดที่นี่ได้ถูกจองเต็มจำนวนแล้ว กรุณาเลือกที่จอดที่อื่น"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
          }else {
          // return object of type AlertDialog
            return AlertDialog(
              title: new Text("ยืนยันนการจองที่จอด"),
              content: new Text("ท่านสามารถจองที่จอดได้เพียงครั้งละ 1 ที่เท่านั้น กดตกลงเพื่อยืนยันการจอง"),
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
                    changeStatus(document);
                  },
                ),
              ],
            );
          }
        }
      );
    }else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("กรุณาเลือกสถานที่จอด"),
            content: Text(
                "กรุณาเลือกสถานที่จอดก่อนทำการกดจอง"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text("ตกลง"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      );
    }
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

}
