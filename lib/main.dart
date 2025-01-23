import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/providers/app_provider.dart';
import 'package:versus/src/providers/archive_provider.dart';
import 'package:versus/src/providers/chat_provider.dart';
import 'package:versus/src/providers/filter_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/report_provider.dart';
import 'package:versus/src/providers/request_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/providers/setting_provider.dart';
import 'package:versus/src/providers/testing_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/uis/app_ui.dart';
import 'package:versus/src/uis/archive_ui.dart';
import 'package:versus/src/uis/chat_ui.dart';
import 'package:versus/src/uis/front_page_ui.dart';
import 'package:versus/src/uis/history_ui.dart';
import 'package:versus/src/uis/merge_ui.dart';
import 'package:versus/src/uis/note_add_ui.dart';
import 'package:versus/src/uis/request_add_ui.dart';
import 'package:versus/src/uis/request_ui.dart';
import 'package:versus/src/uis/select_master_ui.dart';
import 'package:versus/src/uis/testing_add_ui.dart';
import 'package:versus/src/uis/testing_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MainProvider().getMember().then((value) {
    userModel = value;
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
        ChangeNotifierProvider(create: (context) => SelectMasterProvider()),
        ChangeNotifierProvider(create: (context) => SettingProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => ReportProvider()),
        ChangeNotifierProvider(create: (context) => ArchiveProvider()),
        ChangeNotifierProvider(create: (context) => RequestProvider()),
        ChangeNotifierProvider(create: (context) => FilterProvider()),
        ChangeNotifierProvider(create: (context) => TestingProvider()),
      ],
      child: Main(
        loggedIn: _loggedIn,
      ),
    ));
  });
}

class Main extends StatelessWidget {
  final bool loggedIn;

  Main({this.loggedIn = false});

  @override
  Widget build(BuildContext context) {
    // MainProvider().initFirebase();

    return MaterialApp(
      routes: {
        kRouteApp: (context) => AppUI(),
        kRouteFrontPage: (context) => FrontPageUI(),
        kRouteNoteAdd: (context) => NoteAddUI(),
        kRouteTestingAdd: (context) => TestingAddUI(),
        kRouteRequestAdd: (context) => RequestAddUI(),
        kRouteFriendAdd: (context) => SelectMasterUI(),
        kRouteChat: (context) => ChatUI(),
        kRouteArchive: (context) => ArchiveUI(),
        kRouteRequest: (context) => RequestUI(),
        kRouteTesting: (context) => TestingUI(),
        kRouteMerge: (context) => MergeUI(),
        kRouteHistory: (context) => HistoryUI(),
      },
      initialRoute: loggedIn ? kRouteApp : kRouteFrontPage,
    );
  }
}
