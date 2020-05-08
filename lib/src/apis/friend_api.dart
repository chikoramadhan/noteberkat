import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_berkat/src/apis/main_api.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:provider/provider.dart';

class FriendApi extends MainApi {
  StreamSubscription _addListener, _changedListener, _deleteListener;
  Map<String, StreamSubscription> _profileListener = new HashMap();

  initFriend(BuildContext context, String userId) async {
    Query _query = database.reference().child("friend").child(userId);

    _addListener = _query.onChildAdded.listen(
      (event) {
        database
            .reference()
            .child("profile")
            .child(event.snapshot.value)
            .once()
            .then(
          (value) {
            listenProfile(context, value.key);
            return Provider.of<FriendProvider>(context, listen: false)
                .updateData(value);
          },
        );
      },
    );

    _changedListener = _query.onChildChanged.listen(
      (event) {
        database
            .reference()
            .child("profile")
            .child(event.snapshot.key)
            .once()
            .then(
          (value) {
            listenProfile(context, value.key);
            return Provider.of<FriendProvider>(context, listen: false)
                .updateData(value);
          },
        );
      },
    );

    _deleteListener = _query.onChildRemoved.listen(
      (event) {
        if (_profileListener.containsKey(event.snapshot.key)) {
          _profileListener[event.snapshot.key].cancel();
          _profileListener.remove(event.snapshot.key);
        }

        Provider.of<FriendProvider>(context, listen: false)
            .removeData(event.snapshot);
      },
    );
  }

  Future<DataSnapshot> fetchAllMemberByName(String name) async {
    Query _query = database
        .reference()
        .child("profile")
        .orderByChild("name")
        .startAt(name)
        .endAt(name + "\uf8ff");

    return _query.once();
  }

  listenProfile(BuildContext context, String id) {
    if (!_profileListener.containsKey(id)) {
      _profileListener.addAll({
        id: database
            .reference()
            .child("profile")
            .child(id)
            .onChildChanged
            .listen((event) {
          Provider.of<FriendProvider>(context, listen: false)
              .updateProfile(event.snapshot, id);
        })
      });
    }
  }

  Future addFriend(String userId, MemberModel friend) async {
    DatabaseReference _query;

    _query = database.reference().child("friend").child(userId).push();
    await _query.set(friend.id);

    _query = database.reference().child("friend").child(friend.id).push();
    await _query.set(userId);
  }

  closeFriend() {
    if (_addListener != null) _addListener.cancel();
    if (_changedListener != null) _changedListener.cancel();
    if (_deleteListener != null) _deleteListener.cancel();
    if (_profileListener != null)
      _profileListener.forEach((key, value) {
        value.cancel();
      });
  }
}
