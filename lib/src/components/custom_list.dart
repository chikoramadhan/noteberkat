import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  CustomList(
      {this.id,
      this.title,
      this.subtitle,
      this.trailing,
      this.callback,
      this.color,
      this.expandSubtitle,
      this.expandKeterangan,
      this.withId = false});

  final int? id;
  final String? title, subtitle;
  final Widget? expandKeterangan;
  final Widget? expandSubtitle;
  final Widget? trailing;
  final dynamic callback;
  final Color? color;
  final bool withId;

  bool expand = false;

  @override
  Widget build(BuildContext context) {
    Widget? sub;

    if (expandSubtitle != null) {
      sub = StatefulBuilder(
        builder: (context, ss) {
          return InkWell(
            onTap: () {
              ss(() {
                expand = !expand;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: expandSubtitle != null
                  ? expandSubtitle
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        expand
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: expandKeterangan,
                              )
                            : Container(),
                        Text(
                          !expand ? "Keterangan" : "Tutup Keterangan",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
            ),
          );
        },
      );
    } else {
      sub = subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 15),
            )
          : null;
    }

    String t = title!;
    if (withId == true) {
      t = '${id} - ${title!}';
    }

    return Material(
      color: color ?? Colors.white,
      child: ListTile(
        onTap: callback,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        title: id == -1
            ? Divider(
                height: 1,
                color: Colors.black,
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                    vertical: expandSubtitle != null ? 8 : 0),
                child: Text(
                  t,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
                ),
              ),
        subtitle: sub,
        trailing: trailing,
      ),
    );
  }
}
