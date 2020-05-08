import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/components/custom_list.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:provider/provider.dart';

class FriendUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<FriendUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Friends",
        action: _action(),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return _buildList();
  }

  List<Widget> _action() {
    List<Widget> temp = new List();
    temp.add(
      Container(
        width: 60.0,
        height: 60.0,
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(kRouteFriendAdd);
          },
          child: Icon(
            Icons.person_add,
            color: Colors.black,
          ),
        ),
      ),
    );
    return temp;
  }

  Widget _buildList() {
    return Consumer<FriendProvider>(builder: (context, friend, child) {
      if (friend.data.length > 0) {
        return new StaggeredGridView.countBuilder(
          crossAxisCount: 1,
          padding: EdgeInsets.symmetric(vertical: 10.0),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: friend.data.length,
          itemBuilder: (BuildContext context, int index) => Container(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: CustomList(
                  title: friend.data.elementAt(index).name,
                  subtitle: friend.data.elementAt(index).email,
                ),
              ),
            ),
          ),
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        );
      } else {
        return Center(
          child: Text("No friend found"),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
