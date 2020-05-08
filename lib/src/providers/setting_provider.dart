import 'package:flutter/material.dart';
import 'package:note_berkat/src/providers/app_provider.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/providers/main_provider.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:provider/provider.dart';

class SettingProvider extends MainProvider {
  doLogout(BuildContext context) async {
    getUser().then((member) {
      getToken().then((token) {
        repository.deleteToken(token: token, userId: member.uid).then((value) {
          repository.doLogout().then((value) {
            Provider.of<NoteProvider>(context, listen: false).clear();
            Provider.of<FriendProvider>(context, listen: false).clear();
            Provider.of<AppProvider>(context, listen: false).clear();
            Navigator.of(context).pushReplacementNamed(kRouteFrontPage);
          });
        });
      });
    });
  }

  dispose() {
    super.dispose();
  }
}
