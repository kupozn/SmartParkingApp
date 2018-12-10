import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart' as random;



abstract class BaseAuth {
  Future<String> signInwithEmailAndPassWord(String email, String password);
  Future<String> createUserwithEmailAndPassWord(String email, String password);
  Future<String> currentUser();
  Future<Image> test1234();
}

class Auth implements BaseAuth {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
  Future<String> signInwithEmailAndPassWord(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserwithEmailAndPassWord(
    String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.email;
  }

  Future<Image> test1234()  async {
    var data = random.randomAlphaNumeric(20);
    String url = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$data";
    print('**************************Img Data : $data**************************');
    Image image = await Image.network(url);
    return image;
  }
}
