import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'ReservedPage.dart';

class HomePage extends StatefulWidget {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  static String tag = 'HomePage';

  final String userName;
  final String userkey;
  final String status;

  // In the constructor, require a userName, userkey, status, dataDocument
  HomePage({Key key, @required this.userName, this.userkey, this.status})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _HomePageState(userName, userkey, status);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  _HomePageState(String userName, String userkey, String status) {
    this.userName = userName;
    this.userkey = userkey;
    this.status = status;
  }
  int _bottomNavIndex = 0;
  String userName;
  String userkey;
  String status;
  var dataDocument;
  var refData;
  DocumentSnapshot refDocument;
  Widget qrcode;

  @override
  Widget build(BuildContext context) {
    if (_bottomNavIndex == 0) {
      return _stateReserve();
    } else {
      return profile();
    }
  }

  //**************** WIDGET ****************/

  Widget buildButtomBar() {
    final icon1 = Icon(
      Icons.airport_shuttle,
      color: Colors.blueAccent,
      size: 30.0,
    );
    return BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (int index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: icon1,
            title: Text('Reserve'),
          ),
          BottomNavigationBarItem(
            icon: icon1,
            title: Text('Profile'),
          ),
        ]);
  }

  Scaffold profile() {
    //************************PROFILE PAGE********************/
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text('Username : $userName',
          style: TextStyle(fontSize: 30.0, color: Colors.black)),
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
    /*******************HOME PAGE *******************/
    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      backgroundColor: Colors.limeAccent,
      body: StreamBuilder(
        stream: Firestore.instance.collection('numPark').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Text('Loading',
                style: TextStyle(fontSize: 30.0, color: Colors.black));
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

  Widget buildListItemPark(BuildContext context, DocumentSnapshot document) {
    /************************LIST ITEM IN HOME PAGE ***********************************/
    return ListTile(
      title: Row(children: [
        Expanded(
          child: Text(
            document.documentID,
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
      onTap: () {
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
            } else {
              // return object of type AlertDialog
              return AlertDialog(
                title: Text("ยืนยันนการจองที่จอด"),
                content: Text("ท่านสามารถจองที่จอดได้เพียงครั้งละ 1 ที่เท่านั้น กดตกลงเพื่อยืนยันการจอง"),
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
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
            )));
  }

  //***************************************METHOD*************************************/

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
          .setData({'status': 'Not Active', 'place': "$place", 'time': now});
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
          time.millisecondsSinceEpoch + (1000 * 60 * 1));
      var timediff = test.difference(now);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReservedPage(
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
                Navigator.of(context).pushNamed(LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(context).pushNamed(LoginPage.tag);
              },
            ),
          ],
        );
      },
    );
  }
}
