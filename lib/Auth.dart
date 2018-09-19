import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInwithEmailAndPassWord(String email, String password);
  Future<String> createUserwithEmailAndPassWord(String email, String password);
  Future<String> currentUser();
}

class Auth implements BaseAuth {
  Future<String> signInwithEmailAndPassWord(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }


  Future<String> createUserwithEmailAndPassWord(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.email;
  }
}
