import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:versus/src/apis/main_api.dart';
import 'package:versus/src/models/user.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/resources/helper.dart';

class FrontApi extends MainApi {
  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserModel?> doLogin(String email, String password) async {
    Response response = await dio
        .post(kLoginUrl, data: {kIdentifier: email, kPassword: password});
    userModel = UserModel.fromJson(response.data);
    return userModel;
  }

  Future<User?> doRegister(String email, String password) async {
    /* UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;

    return user;*/
    return null;
  }

  Future<UserModel?> me({required UserModel user}) async {
    Response response = await dio.get('$kMeUrl?$kNumberLower=5',
        options: new Options(headers: {
          PARAM_AUTHORIZATION: "Bearer " + user.jwt!,
        }));
    userModel!.user = new User.fromJson(response.data);
    return userModel;
  }

  Future<void> doLogout() async {
    //return _firebaseAuth.signOut();
  }

  void sendToken(String? token, String? userId) async {
    /*   DatabaseReference _query =
        database.reference().child("token").child(userId).child(token);
    _query.set("");*/
  }

  Future sendToDatabase(User user) async {
    /*DatabaseReference _query =
        database.reference().child("profile").child(user.uid);
    Map<String, String> data = new HashMap();
    data.addAll({"name": user.email.substring(0, user.email.indexOf("@"))});
    data.addAll({"email": user.email});
    await _query.set(data);*/
    return null;
  }

  Future deleteToken(String? token, String? userId) async {
/*    DatabaseReference _query =
        database.reference().child("token").child(userId).child(token);
    return _query.remove();*/
    return null;
  }

  Future logout({required UserModel user}) async {
    await dio.post(kLogoutUrl,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return true;
  }
}
