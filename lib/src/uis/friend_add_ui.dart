import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/components/custom_list.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:provider/provider.dart';

class FriendAddUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<FriendAddUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _searchController = new TextEditingController();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer _timer;
  String _keyword = "";

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<FriendProvider>(context, listen: false).clearSearch();
    _searchController.addListener(() {
      if (_keyword != _searchController.text) {
        _keyword = _searchController.text;
        if (_searchController.text.length > 0)
          Provider.of<FriendProvider>(context, listen: false).loadingSearch();
        else
          Provider.of<FriendProvider>(context, listen: false).clearSearch();

        if (_timer != null) {
          _timer.cancel();
          _timer = null;
        }
        _timer = new Timer(Duration(milliseconds: 700), () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            Provider.of<FriendProvider>(context, listen: false)
                .loadAllMemberByName(_searchController.text);
          });
          _timer.cancel();
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Add Friends",
        leading: _leading(),
        customTitle: _searchBar(),
      ),
      body: _body(),
    );
  }

  Widget _leading() {
    return Container(
      width: 60.0,
      height: 60.0,
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.chevron_left,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextFormField(
      maxLines: 1,
      controller: _searchController,
      style: TextStyle(fontSize: 14.0),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Search Friends",
      ),
    );
  }

  Widget _body() {
    return _buildList();
  }

  Widget _loading(FriendProvider value) {
    if (value.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (value.done && value.listSearch.length == 0) {
      return Center(child: Text("No data found"));
    } else {
      return Container();
    }
  }

  Widget _buildList() {
    return Consumer<FriendProvider>(builder: (context, friend, child) {
      if (friend.listSearch.length > 0) {
        return new StaggeredGridView.countBuilder(
          crossAxisCount: 1,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: friend.listSearch.length,
          itemBuilder: (BuildContext context, int index) => Container(
            width: double.infinity,
            child: CustomList(
              title: friend.listSearch.elementAt(index).name,
              subtitle: friend.listSearch.elementAt(index).email,
              trailing: _buttonAdd(
                  friend.listSearch.elementAt(index),
                  friend.listAdd.firstWhere(
                          (element) =>
                              element.id ==
                              friend.listSearch.elementAt(index).id,
                          orElse: () => null) !=
                      null),
            ),
          ),
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        );
      } else {
        return _loading(friend);
      }
    });
  }

  Widget _buttonAdd(MemberModel memberModel, bool adding) {
    if (adding) {
      return Container(
        height: 30.0,
        width: 30.0,
        margin: EdgeInsets.only(right: 20.0),
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      );
    } else {
      return Container(
        height: 60,
        width: 60,
        margin: EdgeInsets.only(right: 20.0),
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Provider.of<FriendProvider>(context, listen: false)
                .addFriend(memberModel, addFriendCallback);
          },
          child: Icon(Icons.person_add),
        ),
      );
    }
  }

  void addFriendCallback() {
    showMessage(_scaffoldKey, "Success add friend");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
