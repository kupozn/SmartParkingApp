import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'ReservedPage.dart';

class HomePage extends StatefulWidget {
  static String tag = 'HomePage';
  static String status = 'No';
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  
  @override
  Widget build(BuildContext context) {
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
            text,SizedBox(
                height: 50.0,
              ),
              buildButton('SignOut', signOut)
          ],
        ),
      ),
    );
  }

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

  Widget _stateReserve() {
    return Scaffold(
      bottomNavigationBar: buildButtomBar(),
      body: StreamBuilder(
        stream: Firestore.instance.collection('Parking').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Text('Loading...', style: TextStyle(fontSize: 100.0));
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

  void signOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamed(LoginPage.tag);
      } catch (e) {
        print('Error: $e');
      }
  }

  void changeStatus() => HomePage.status == 'No' ? "No" : "Reserved";

  List<String> _itemDrop(){
    List<String> list = [];
    StreamBuilder(
        stream: Firestore.instance.collection('numPark').snapshots(),
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
            color: Colors.grey,
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
                      changeStatus();
                      document.reference.updateData({'count': document['count']-1});
                      Navigator.of(context).pushNamed(ReservedPage.tag);
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
