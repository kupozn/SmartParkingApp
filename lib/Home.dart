import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  static String tag = 'HomePage';
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
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
            ],
          ),
        ),
      );
    } else if (_bottomNavIndex == 1) {
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
            title: new Text('Main'),
          ),
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
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
            document['status'],
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      ]),
      onTap: () {
        document.reference
            .updateData({'status': document['status'] == 'F' ? 'R' : 'F'});
      },
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
                _buildListItem(context, snapshot.data.documents[index]),
          );
        },
      ),
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

  void signOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamed(LoginPage.tag);
      } catch (e) {
        print('Error: $e');
      }
  }
}
