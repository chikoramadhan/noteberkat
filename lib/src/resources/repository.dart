import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_berkat/src/apis/friend_api.dart';
import 'package:note_berkat/src/apis/front_api.dart';
import 'package:note_berkat/src/apis/note_api.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/models/note_model.dart';

class Repository {
  final noteApi = NoteApi();
  final friendApi = FriendApi();
  final frontApi = FrontApi();

  void fetchAllNote({BuildContext context, String userId}) =>
      noteApi.fetchAllNote(context, userId);

  Future<String> addNote({NoteModel note, String userId}) =>
      noteApi.addNote(note, userId);

  Future sendNote(
          {NoteModel note, List<MemberModel> friend, BuildContext context}) =>
      noteApi.sendNote(note, friend, context);

  void closeNote() => noteApi.closeNote();

  void initFriend({BuildContext context, String userId}) =>
      friendApi.initFriend(context, userId);

  Future<DataSnapshot> fetchAllMemberByName({String name}) =>
      friendApi.fetchAllMemberByName(name);

  Future addFriend({String userId, MemberModel memberModel}) =>
      friendApi.addFriend(userId, memberModel);

  closeFriend() => friendApi.closeFriend();

  Future<FirebaseUser> doLogin(String email, String password) =>
      frontApi.doLogin(email, password);

  Future<FirebaseUser> doRegister(String email, String password) =>
      frontApi.doRegister(email, password);

  Future doLogout() => frontApi.doLogout();

  Future<FirebaseUser> getUser() => frontApi.getUser();

  Future sendToDatabase({FirebaseUser user}) => frontApi.sendToDatabase(user);

  void sendToken({String token, String userId}) =>
      frontApi.sendToken(token, userId);

  Future deleteToken({String token, String userId}) =>
      frontApi.deleteToken(token, userId);
}
