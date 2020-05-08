import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/models/note_model.dart';
import 'package:note_berkat/src/providers/main_provider.dart';

class NoteProvider extends MainProvider {
  final List<NoteModel> _data = new List();

  NoteModel note;

  bool showSnackbar = false;

  List<NoteModel> get data => _data;

  editNote(int index) {
    note = _data.elementAt(index);
  }

  addData(String title, String content, VoidCallback callback) {
    getUser().then((member) {
      MemberModel creator;
      if (note == null || (note != null && note.creator == null)) {
        creator = new MemberModel(
            id: member.uid, name: member.displayName, email: member.email);
      } else {
        creator = note.creator;
      }

      NoteModel temp = new NoteModel(title, creator, content);

      if (note != null && note.id != null) {
        temp.id = note.id;
      }

      repository.addNote(note: temp, userId: member.uid).then((value) {
        print(value);
        note = temp;
        note.id = value;
        notifyListeners();
        callback();
      });
    });
  }

  newData(DataSnapshot snapshot) {
    print(snapshot.value);
    note = NoteModel.fromSnapshot(snapshot);
    showSnackbar = true;
    notifyListeners();
  }

  updateData(DataSnapshot snapshot) {
    NoteModel noteModel = NoteModel.fromSnapshot(snapshot);
    _data.removeWhere((element) => element.id == noteModel.id);
    _data.insert(0, noteModel);
    notifyListeners();
  }

  removeData(DataSnapshot snapshot) {
    NoteModel noteModel = NoteModel.fromSnapshot(snapshot);
    _data.removeWhere((element) => element.id == noteModel.id);
    notifyListeners();
  }

  loadAllData(BuildContext context) async {
    getUser().then((member) {
      repository.fetchAllNote(context: context, userId: member.uid);
    });
  }

  sendData(List<MemberModel> friend, void callback) {
    repository.sendNote(note: note, friend: friend).then((value) => callback);
  }

  clear() {
    _data.clear();
    note = null;
    repository.closeNote();
  }

  dispose() {
    clear();
    super.dispose();
  }
}
