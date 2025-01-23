import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/app_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/uis/admin2_ui.dart';
import 'package:versus/src/uis/admin_ui.dart';
import 'package:versus/src/uis/note_ui.dart';
import 'package:versus/src/uis/setting_ui.dart';

class AppUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AppUI> with AfterLayoutMixin {
  PageController _controller = new PageController();

  UserModel? user;
  bool updating = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    //Provider.of<AppProvider>(context, listen: false).sendToken();

    await checkUpdate();
    await Provider.of<NoteProvider>(context, listen: false)
        .loadAllData(context: context);
    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  Future checkUpdate() async {
    final shorebirdCodePush = ShorebirdCodePush();
    final isUpdateAvailable =
        await shorebirdCodePush.isNewPatchAvailableForDownload();

    if (isUpdateAvailable) {
      setState(() {
        updating = true;
      });

      await Future.wait([
        shorebirdCodePush.downloadUpdateIfAvailable(),
        Future<void>.delayed(const Duration(seconds: 6)),
      ]);

      Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    if (updating) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Text("Updating Apps...")
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              onPageChanged: (index) {
                Provider.of<AppProvider>(context, listen: false)
                    .changePage(index);
              },
              children: _screen(),
            ),
          ),
          _bottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          child: Container(
            height: 57.0,
            color: Colors.grey[300],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          child: Consumer<AppProvider>(builder: (context, app, child) {
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              onTap: (index) {
                Provider.of<AppProvider>(context, listen: false)
                    .changePage(index);
                _controller.jumpToPage(
                    index /*,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear*/
                    );
              },
              currentIndex: app.active,
              items: _items(),
              showUnselectedLabels: true,
            );
          }),
        )
      ],
    );
  }

  List<Widget> _screen() {
    List<Widget> _list = [];

    if (user == null) {
      return _list;
    }

    _list.add(NoteUI());
    if (user != null && isAdmin(user)) {
      _list.add(AdminUI());
      _list.add(Admin2UI());
    }
    _list.add(SettingUI());
    return _list;
  }

  List<BottomNavigationBarItem> _items() {
    List<BottomNavigationBarItem> _list = [];
    _list.add(BottomNavigationBarItem(
      icon: Icon(Icons.note),
      label: "Search",
    ));

    if (user != null && isAdmin(user)) {
      _list.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.check_box_rounded,
          color: Colors.green,
        ),
        label: 'Report',
      ));

      _list.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.close,
          color: Colors.red,
        ),
        label: 'Report',
      ));
    }

    _list.add(BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: "Settings",
    ));
    return _list;
  }
}
