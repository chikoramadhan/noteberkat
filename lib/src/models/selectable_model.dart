import 'package:flutter/material.dart';

class SelectAbleModel {
  SelectAbleModel(
      {required this.id,
      required this.title,
      this.subtitle,
      this.trailing,
      this.optional});

  int? id;
  String? title;
  String? trailing;
  String? subtitle;
  dynamic optional;
}
