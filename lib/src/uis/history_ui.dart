import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/providers/note_provider.dart';

class HistoryUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HistoryUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            leading: BackButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });
              },
            ),
            customTitle: Text(
              "History",
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            ),
          ),
          body: _body(),
        ),
      ],
    );
  }

  Widget _body() {
    return _buildList();
  }

  Widget _buildList() {
    double _radius = 15;
    int _crossAxisCount = 1;

    return Consumer<NoteProvider>(builder: (context, note, child) {
      List<String>? _list = note.chat!.history?.split("\n==========\n").map((e) {
        List<String> _temp = e.split("\n\n");
        Map<String, dynamic> data = json.decode(_temp[1]);
        String text = "";

        data.keys.forEach((element) {
          text += "\n" + element + " : " + data[element];
        });

        return _temp[0] + "\n" + text;
      }).toList();

      if (_list == null || _list.length == 0) {
        return Center(
          child: Text("No history found"),
        );
      } else {
        return new ListView.builder(
          padding: EdgeInsets.all(10.0),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Container(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 25.0),
                      child: Stack(
                        children: [
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
                          Text(
                            _list.elementAt(_list.length - 1 - index),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
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
