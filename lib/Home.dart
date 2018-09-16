import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  static String tag = 'HomePage';

  @override
  State<StatefulWidget> createState() => new _HomePageState();

  
}

class _HomePageState extends State<HomePage> {

  int _bottomNavIndex = 0;
  List<String> texteiei = ['test1', 'test2', 'test3'];

  @override
  Widget build(BuildContext context){
    final text = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        texteiei[_bottomNavIndex],
        style: TextStyle(fontSize: 30.0, color: Colors.black)
      ),
    );
    final icon1 =  Icon(Icons.airport_shuttle,
                          color: Colors.yellowAccent,
                          size: 30.0,
                        );
  

    return Scaffold(
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (int index){
          setState((){
            _bottomNavIndex = index;
            }
          );
        },
        items: [new BottomNavigationBarItem(
            icon: icon1,
            title: new Text('test'),
          ),
          new BottomNavigationBarItem(
            icon: icon1,
            title: new Text('test1'),
          ),
          new BottomNavigationBarItem(
            icon: icon1,
            title: new Text('test2'),
          ),
        ]
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 50.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 30.0,), 
            text,
          ],
        ),
      ),
    );
  }
    
  }