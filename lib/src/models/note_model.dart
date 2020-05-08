import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:note_berkat/src/models/member_model.dart';

class NoteModel {
  String id;
  String title;
  String content;
  MemberModel creator;
  String updated;

  NoteModel(this.title, this.creator, this.content) {
    updated = new DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
  }

  NoteModel.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        creator = snapshot.value["Creator"] != null
            ? MemberModel.fromJson(
                jsonDecode(jsonEncode(snapshot.value["Creator"])),
              )
            : null,
        title = snapshot.value["Title"] != null ? snapshot.value["Title"] : "",
        content =
            snapshot.value["Content"] != null ? snapshot.value["Content"] : "",
        updated =
            snapshot.value["Updated"] != null ? snapshot.value["Updated"] : "";

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "Creator": creator.toJson(),
      "Title": title,
      "Content": content,
      "Updated": updated,
    };
  }
}
