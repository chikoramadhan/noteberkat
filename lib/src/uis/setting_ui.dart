import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/providers/setting_provider.dart';
import 'package:provider/provider.dart';

class SettingUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SettingUI> {
  BuildContext _context;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Settings",
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _content("Logout", Colors.red, Icons.exit_to_app, _doLogout),
      ],
    );
  }

  Widget _content(String title, MaterialColor colors, IconData icons,
      VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        child: ListTile(
          contentPadding: EdgeInsets.all(0.0),
          leading: Container(
            height: 36.0,
            width: 36.0,
            child: Icon(
              icons,
              color: Colors.white,
              size: 18.0,
            ),
            decoration: BoxDecoration(
              color: colors,
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.black,
            size: 22.0,
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 0.15,
      width: double.infinity,
      color: Colors.grey,
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
    );
  }

  void _doLogout() async {
    Provider.of<SettingProvider>(context, listen: false).doLogout(context);
  }
}
