import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../resources/repository.dart';

class MainProvider extends ChangeNotifier {
  final repository = Repository();
  final _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await repository.getUser();
    return user;
  }

  Future<String> getToken() async {
    return _firebaseMessaging.getToken();
  }

  sendToken() {
    getUser().then((member) {
      if (member != null) {
        getToken().then((token) {
          repository.sendToken(token: token, userId: member.uid);
        });
      }
    });
  }

  void initFirebase() async {
    if (Platform.isIOS) iosPermission();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (_) {});

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _showNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _showNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        _showNotification(message);
      },
    );
  }

  Future _selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    /*await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
    );*/
  }

  Future _showNotification(Map<String, dynamic> data) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'note', 'note', 'note',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().show(
      (new DateTime.now().millisecondsSinceEpoch / 10000).toInt(),
      data["notification"]["title"],
      data["notification"]["body"],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void iosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
