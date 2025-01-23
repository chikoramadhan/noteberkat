import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/resources/helper.dart';

import '../resources/repository.dart';

class MainProvider extends ChangeNotifier {
  final repository = Repository();
  //final _firebaseMessaging = FirebaseMessaging.instance;

  Future<UserModel?> getMember() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    return _prefs.then((value) {
      String? str = value.getString(kMemberLower);
      if (str == null || str.isEmpty) {
        return null;
      } else {
        return UserModel.fromJson(
          jsonDecode(
            str,
          ),
        );
      }
    });
  }

  void iosPermission() {
    /*_firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });*/
  }
}
