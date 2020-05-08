import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_berkat/src/components/custom_app_bar.dart';
import 'package:note_berkat/src/models/note_model.dart';
import 'package:note_berkat/src/providers/note_provider.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:provider/provider.dart';

class NoteAddUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NoteAddUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _contentController = new TextEditingController();

  final FocusNode _contentNode = new FocusNode();
  final GlobalKey _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    NoteModel noteModel =
        Provider.of<NoteProvider>(context, listen: false).note;
    if (noteModel != null) {
      _titleController.text = noteModel.title;
      _contentController.text = noteModel.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Notes",
        action: _action(),
        leading: _leading(),
      ),
      body: _body(),
      floatingActionButton: _fab(),
    );
  }

  Widget _body() {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(fontSize: 14.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Title",
                        counterText: "${_titleController.text.length}/50",
                        counterStyle: TextStyle(
                            color: _titleController.text.length == 50
                                ? Colors.red
                                : Colors.grey),
                      ),
                      maxLines: 1,
                      maxLength: 50,
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _contentNode.requestFocus();
                      },
                    ),
                    Divider(
                      thickness: 1.5,
                    ),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(fontSize: 14.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Content",
                        ),
                        //textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: _contentController,
                        focusNode: _contentNode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
          onTap: save,
          child: Icon(
            Icons.check,
            color: Colors.black,
          ),
        ),
      ),
    );
    return temp;
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

  Widget _fab() {
    return Consumer<NoteProvider>(
      builder: (context, value, child) {
        if (value.note != null) {
          return FloatingActionButton(
            onPressed: () async {
              var success =
                  await Navigator.of(context).pushNamed(kRouteNoteShare);

              if (success != null) {
                showMessage(_scaffoldKey, "Note sent !");
              }
              FocusScope.of(context).requestFocus(FocusNode());
            },
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Icon(
                Icons.send,
                color: Colors.blue,
                size: 26.0,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void save() {
    FocusScope.of(context).requestFocus(FocusNode());
    Provider.of<NoteProvider>(context, listen: false)
        .addData(_titleController.text, _contentController.text, saveCallback);
  }

  void saveCallback() {
    showMessage(_scaffoldKey, "Note updated");
  }
}
