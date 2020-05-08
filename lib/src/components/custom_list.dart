import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  CustomList({this.title, this.subtitle, this.trailing});

  final String title, subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0.0),
      leading: CircleAvatar(
        child: Text("C"),
        backgroundColor: Colors.blue,
        radius: 40.0,
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
    );
  }
}
