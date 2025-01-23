import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  CustomFilterChip(
      {required this.selected, required this.callback, required this.title});

  bool selected;
  dynamic callback;
  String? title;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Container(
        constraints: new BoxConstraints(
          minWidth: 80.0,
        ),
        child: Text(
          title ?? "",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
      selected: selected,
      onSelected: (_) => callback(_),
      selectedColor: Colors.white,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.green,
      shape: StadiumBorder(
        side: BorderSide(
          color: Colors.black38,
          width: 0.5,
        ),
      ),
    );
  }
}
