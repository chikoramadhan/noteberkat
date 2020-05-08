import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:note_berkat/src/apis/main_api.dart';

class FrontApi extends MainApi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> doLogin(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;

    return user;
  }

  Future<FirebaseUser> doRegister(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;

    return user;
  }

  Future<void> doLogout() async {
    return _firebaseAuth.signOut();
  }

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  void sendToken(String token, String userId) async {
    DatabaseReference _query =
        database.reference().child("token").child(userId).child(token);
    _query.set("");
  }

  Future sendToDatabase(FirebaseUser user) async {
    DatabaseReference _query =
        database.reference().child("profile").child(user.uid);
    Map<String, String> data = new HashMap();
    data.addAll({"name": user.email.substring(0, user.email.indexOf("@"))});
    data.addAll({"email": user.email});
    await _query.set(data);
  }

  Future deleteToken(String token, String userId) async {
    DatabaseReference _query =
        database.reference().child("token").child(userId).child(token);
    return _query.remove();
  }
}
