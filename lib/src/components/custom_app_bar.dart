import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({this.title, this.action, this.leading, this.customTitle});

  final String title;
  final List<Widget> action;
  final Widget leading;
  final Widget customTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: customTitle == null
          ? Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            )
          : customTitle,
      centerTitle: true,
      actions: action,
      leading: leading,
      elevation: 1.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
