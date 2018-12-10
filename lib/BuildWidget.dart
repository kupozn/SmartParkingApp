import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'qrcode.dart';

abstract class BaseWidget {
  Widget buildButton(words, cmd);
  Widget buildListItemPark(BuildContext context, DocumentSnapshot document);
  
}

class BuildWidget implements BaseWidget{
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  static String tag = 'BuildWidget';


  /*List of Parking Builder */
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
                content: new QrImage(
                    data: "Hello, world in QR form!",
                    size: 100.0,
                  ),
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
                      document.reference.updateData({'count': document['count']-1});
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
  //*Button's Builder */
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

  //Widget _buildDropButtom(BuildContext context, DocumentSnapshot document) {
  //   final text = Padding(
  //     padding: EdgeInsets.all(8.0),
  //     child: Text(uid, style: TextStyle(fontSize: 30.0, color: Colors.black)),
  //   );
  //   return Center(
  //     child: ListView(
  //       shrinkWrap: true,
  //       padding: EdgeInsets.only(left: 50.0, right: 24.0),
  //       children: <Widget>[
  //         new DropdownButton(
  //           items: document['name'],
  //           onChanged: (String value) {
  //             setState(() {
  //               _value = value;
  //             });
  //           },
  //         ),
  //         SizedBox(
  //           height: 30.0,
  //         ),
  //         text,SizedBox(
  //             height: 50.0,
  //           ),
  //           buildButton('SignOut', signOut)
  //       ],
  //     ),
  //   );
  // }

  
}
