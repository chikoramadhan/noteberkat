import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kRouteApp = "frontPage";
const kRouteFrontPage = "/";
const kRouteNoteAdd = "noteAdd";
const kRouteFriendAdd = "friendAdd";
const kRouteNoteShare = "noteShare";

const PARAM_AUTHORIZATION = "Authorization";

void showMessage(GlobalKey<ScaffoldState> key, String message) {
  key.currentState.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
}
