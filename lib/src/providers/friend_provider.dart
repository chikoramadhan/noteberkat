import 'dart:convert';

import 'package:async/async.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/providers/main_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FriendProvider extends MainProvider {
  final List<MemberModel> _data = new List();
  final List<MemberModel> _listSearch = new List();
  final List<MemberModel> _listAdd = new List();
  final List<MemberModel> _shareWith = new List();

  CancelableOperation<DataSnapshot> _cancelableOperation;

  bool loading = false;
  bool done = false;

  List<MemberModel> get data => _data;

  List<MemberModel> get listSearch => _listSearch;

  List<MemberModel> get listAdd => _listAdd;

  List<MemberModel> get shareWith => _shareWith;

  addFriend(MemberModel memberModel, VoidCallback callback) {
    _listAdd.add(memberModel);
    notifyListeners();
    getUser().then((member) {
      repository
          .addFriend(userId: member.uid, memberModel: memberModel)
          .then((value) {
        successAddFriend(memberModel.id);
        callback();
      });
    });
  }

  successAddFriend(String id) {
    _listAdd.removeWhere((element) => element.id == id);
    _listSearch.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  updateData(DataSnapshot snapshot) {
    MemberModel memberModel = MemberModel.fromSnapshot(snapshot);
    _data.removeWhere((element) => element.id == memberModel.id);
    _data.insert(0, memberModel);
    notifyListeners();
  }

  updateProfile(DataSnapshot snapshot, String id) {
    MemberModel member =
        _data.firstWhere((element) => element.id == id, orElse: () => null);

    if (member != null) {
      member.update(snapshot);
      notifyListeners();
    }
  }

  removeData(DataSnapshot snapshot) {
    _data.removeWhere((element) => element.id == snapshot.value);
    notifyListeners();
  }

  initFriend(BuildContext context) async {
    getUser().then((member) {
      repository.initFriend(context: context, userId: member.uid);
    });
  }

  loadAllMemberByName(String name) async {
    if (name.length == 0) {
      _cancelSearch();
    } else {
      if (_cancelableOperation != null) {
        _cancelableOperation.cancel();
        _cancelableOperation = null;
      }

      _cancelableOperation = CancelableOperation.fromFuture(
        repository.fetchAllMemberByName(name: name),
        onCancel: () => {},
      );

      _cancelableOperation.value.then((value) {
        if (value.value != null) {
          resultSearch(value);
        }
        doneSearch();
      });
    }
  }

  resultSearch(DataSnapshot snapshot) {
    Map<String, dynamic> json = jsonDecode(jsonEncode(snapshot.value));
    getUser().then((member) {
      json.forEach((key, value) {
        String id = key;
        String name = value["name"];
        String email = value["email"];
        if (member.uid != id) {
          MemberModel memberModel = _data
              .firstWhere((element) => element.id == id, orElse: () => null);
          if (memberModel == null) {
            memberModel = new MemberModel(id: id, email: email, name: name);
            _listSearch.add(memberModel);
          }
        }
      });

      notifyListeners();
      _cancelSearch();
    });
  }

  _cancelSearch() {
    loading = false;
    notifyListeners();
  }

  _loadingSearch() {
    loading = true;
    notifyListeners();
  }

  loadingSearch() {
    done = false;
    if (!loading) {
      if (_listSearch.length > 0) _listSearch.clear();
      _loadingSearch();
    }
  }

  clearSearch() {
    _listSearch.clear();
    done = false;
    loading = false;
    notifyListeners();
  }

  doneSearch() {
    loading = false;
    done = true;
    notifyListeners();
  }

  checkedShare(bool checked, MemberModel friend) {
    if (checked)
      _shareWith.add(friend);
    else
      _shareWith.removeWhere((element) => element.id == friend.id);
    notifyListeners();
  }

  clear() {
    _data.clear();
    _listSearch.clear();
    _shareWith.clear();
    _listAdd.clear();
    repository.closeFriend();
  }

  dispose() {
    clear();
    super.dispose();
  }
}
