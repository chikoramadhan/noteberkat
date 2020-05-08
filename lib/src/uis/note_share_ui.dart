import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/components/custom_dialog.dart';
import 'package:note_berkat/src/components/custom_list.dart';
import 'package:note_berkat/src/models/member_model.dart';
import 'package:note_berkat/src/providers/friend_provider.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';

class NoteShareUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NoteShareUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Share With",
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
            List<MemberModel> friend = new List();
            friend.addAll(
                Provider.of<FriendProvider>(context, listen: false).shareWith);
            if (friend.length == 0) {
              showMessage(_scaffoldKey, "Please select your friend to share.");
            } else {
              _confirmDialog(friend);
            }
          },
          child: Icon(
            Icons.send,
            color: Colors.black,
          ),
        ),
      ),
    );
    return temp;
  }

  void _confirmDialog(List<MemberModel> friend) {
    showDialog(
        context: context,
        child: CustomDialog(
          title: "Confirmation",
          description:
              "Are you sure want to share this note to ${friend.length} of your friend" +
                  (friend.length > 1 ? "s" : "") +
                  "?",
          confirmClick: () {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black12,
                  child: Center(
                    child: Lottie.asset(
                      'images/loading.json',
                      height: 100.0,
                    ),
                  ),
                ));
            Provider.of<NoteProvider>(context, listen: false)
                .sendData(friend, _successSend());
          },
        ));
  }

  void _successSend() {
    Provider.of<FriendProvider>(context, listen: false).shareWith.clear();
    Navigator.pop(context);
    Navigator.pop(context, true);
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
            child: CustomList(
              title: friend.data.elementAt(index).name,
              subtitle: friend.data.elementAt(index).email,
              trailing: _trailing(
                  friend.shareWith.firstWhere(
                          (element) =>
                              element.id == friend.data.elementAt(index).id,
                          orElse: () => null) !=
                      null,
                  friend.data.elementAt(index)),
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

  Widget _trailing(bool checked, MemberModel friend) {
    return Checkbox(
        value: checked,
        onChanged: (bool) {
          Provider.of<FriendProvider>(context, listen: false)
              .checkedShare(bool, friend);
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
