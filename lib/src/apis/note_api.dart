import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:note_berkat/src/apis/main_api.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/models/note_model.dart';
import 'package:note_berkat/src/providers/note_provider.dart';

class NoteApi extends MainApi {
  StreamSubscription _addListener, _changedListener, _deleteListener;

  fetchAllNote(BuildContext context, String userId) async {
    Query _query = database.reference().child("note").child(userId);

    _addListener = _query.onChildAdded.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .updateData(event.snapshot);
    });

    _changedListener = _query.onChildChanged.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .updateData(event.snapshot);
    });

    _deleteListener = _query.onChildRemoved.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .removeData(event.snapshot);
    });
  }

  Future<String> addNote(NoteModel note, String userId) async {
    DatabaseReference _query = database.reference().child("note").child(userId);

    if (note.id == null) {
      _query = _query.push();
    } else {
      _query = _query.child(note.id);
      note.id = null;
    }

    await _query.set(note.toJson());
    return _query.key;
  }

  Future sendNote(
      NoteModel note, List<MemberModel> friend, BuildContext context) async {
    NoteModel temp = new NoteModel(note.title, note.creator, note.content);
    friend.forEach((element) async {
      DatabaseReference _query =
          database.reference().child("note").child(element.id).push();
      await _query.set(temp.toJson());
    });
  }

  closeNote() {
    if (_addListener != null) _addListener.cancel();
    if (_changedListener != null) _changedListener.cancel();
    if (_deleteListener != null) _deleteListener.cancel();
  }
}
