import 'package:flutter/material.dart';
import 'package:note_berkat/src/providers/app_provider.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/providers/main_provider.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/providers/setting_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:note_berkat/src/uis/app_ui.dart';
import 'package:note_berkat/src/uis/friend_add_ui.dart';
import 'package:note_berkat/src/uis/front_page_ui.dart';
import 'package:note_berkat/src/uis/note_add_ui.dart';
import 'package:note_berkat/src/uis/note_share_ui.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MainProvider().getUser().then((value) {
    bool _loggedIn;

    if (value == null) {
      _loggedIn = false;
    } else {
      _loggedIn = true;
    }

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => NoteProvider()),
        ChangeNotifierProvider(create: (context) => FriendProvider()),
        ChangeNotifierProvider(create: (context) => SettingProvider()),
      ],
      child: Main(
        loggedIn: _loggedIn,
      ),
    ));
  });
}

class Main extends StatelessWidget {
  final bool loggedIn;

  Main({this.loggedIn});

  @override
  Widget build(BuildContext context) {
    MainProvider().initFirebase();

    return MaterialApp(
      routes: {
        kRouteApp: (context) => AppUI(),
        kRouteFrontPage: (context) => FrontPageUI(),
        kRouteNoteAdd: (context) => NoteAddUI(),
        kRouteFriendAdd: (context) => FriendAddUI(),
        kRouteNoteShare: (context) => NoteShareUI(),
      },
      initialRoute: loggedIn ? kRouteApp : kRouteFrontPage,
    );
  }
}
