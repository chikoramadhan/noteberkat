import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:provider/provider.dart';

class NoteUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NoteUI>
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
        title: "Notes",
        action: _action(),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<NoteProvider>(context, listen: false).note = null;
          Navigator.of(context).pushNamed(kRouteNoteAdd);
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.blue,
          size: 26.0,
        ),
      ),
    );
  }

  Widget _body() {
    return _buildList();
  }

  List<Widget> _action() {
    List<Widget> temp = new List();
    /*temp.add(
      Container(
        width: 60.0,
        height: 60.0,
        padding: EdgeInsets.all(10.0),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onTap: () {
            showSearch(
              context: context,
              delegate: DataSearch(),
            );
          },
          child: Icon(
            Icons.search,
            color: Colors.black,
          ),
        ),
      ),
    );*/
    return temp;
  }

  Widget _buildList() {
    double _radius = 15;
    int _crossAxisCount = (MediaQuery.of(context).size.width / 300).floor() + 1;

    return Consumer<NoteProvider>(builder: (context, note, child) {
      if (note.data.length > 0) {
        return new StaggeredGridView.countBuilder(
          crossAxisCount: _crossAxisCount,
          padding: EdgeInsets.all(10.0),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: note.data.length,
          itemBuilder: (BuildContext context, int index) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Container(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(_radius),
                  ),
                  onTap: () {
                    Provider.of<NoteProvider>(context, listen: false)
                        .editNote(index);
                    Navigator.of(context).pushNamed(kRouteNoteAdd);
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.data.elementAt(index).title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              new DateFormat("dd MMM yyyy").format(
                                new DateFormat("yyyy-MM-dd").parse(
                                  note.data.elementAt(index).updated,
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 18.0,
                            ),
                            Text(
                              note.data.elementAt(index).content,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.15,
                            child: Image.asset(
                              "images/backdrop.png",
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0396ff), Color(0xffabdcff)],
                  stops: [0.0, 0.7],
                  begin: Alignment(-1.0, -4.0),
                  end: Alignment(1.0, 4.0),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(_radius),
                ),
              ),
            ),
            elevation: 1.0,
            color: Color(0xffffefefe),
          ),
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        );
      } else {
        return Center(
          child: Text("No note found"),
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
