import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:note_berkat/src/providers/app_provider.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/uis/friend_ui.dart';
import 'package:note_berkat/src/uis/note_ui.dart';
import 'package:note_berkat/src/uis/setting_ui.dart';
import 'package:provider/provider.dart';

class AppUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AppUI> with AfterLayoutMixin {
  TextStyle _bottomNavStyle = new TextStyle(fontSize: 12.0);

  PageController _controller = new PageController();

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<AppProvider>(context, listen: false).sendToken();
    Provider.of<NoteProvider>(context, listen: false).loadAllData(context);
    Provider.of<FriendProvider>(context, listen: false).initFriend(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                Provider.of<AppProvider>(context, listen: false)
                    .changePage(index);
              },
              children: <Widget>[
                NoteUI(),
                FriendUI(),
                SettingUI(),
              ],
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
                _controller.animateToPage(index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.linear);
              },
              currentIndex: app.active,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.note),
                  title: Text(
                    'Note',
                    style: _bottomNavStyle,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  title: Text(
                    'Friend',
                    style: _bottomNavStyle,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  title: Text(
                    'Settings',
                    style: _bottomNavStyle,
                  ),
                ),
              ],
              showUnselectedLabels: true,
            );
          }),
        )
      ],
    );
  }
}
