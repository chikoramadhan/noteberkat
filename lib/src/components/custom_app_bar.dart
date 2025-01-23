import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    this.title,
    this.action,
    this.leading,
    this.customTitle,
    this.callback,
  });

  final String? title;
  final List<Widget>? action;
  final Widget? leading;
  final Widget? customTitle;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: customTitle == null
          ? InkWell(
              child: Text(
                title!,
                style: TextStyle(color: Colors.black, fontSize: 14.0),
              ),
              onTap: callback,
            )
          : customTitle,
      centerTitle: true,
      actions: action,
      leading: leading,
      elevation: 1.0,
      iconTheme: IconThemeData(color: Colors.black87),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
