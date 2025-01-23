import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/app_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/resources/helper.dart';

class SettingProvider extends MainProvider {
  doLogout(BuildContext context) async {
    UserModel? user = await getMember();
    if (user != null) {
      repository.logout(user: user).then((value) {});
    }

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.remove("lokasiupdate");
    await _prefs.remove("areaupdate");
    await _prefs.remove("subareaupdate");
    await _prefs.remove(kSpecificLocationLower);
    await _prefs.remove(kAreaLower);
    await _prefs.remove(kSubAreaLower);
    await _prefs.remove(kPropertyCategoryLower);
    await _prefs.remove(kVersionLower);

    _prefs.remove(kMemberLower).then((value) {
      Provider.of<NoteProvider>(context, listen: false).clear();
      Provider.of<AppProvider>(context, listen: false).clear();
      Navigator.of(context).pushReplacementNamed(kRouteFrontPage);
    });
  }

  dispose() {
    super.dispose();
  }
}
