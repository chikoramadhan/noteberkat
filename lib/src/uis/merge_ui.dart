import 'package:after_layout/after_layout.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/resources/helper.dart';

class MergeUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MergeUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  bool _isMerging = false;
  List<int?> _listMerge = [];

  UserModel? user;

  @override
  void afterFirstLayout(BuildContext context) {
    NoteProvider noteProvider =
        Provider.of<NoteProvider>(context, listen: false);

    noteProvider.newData(param: _param(), ignoreTotal: true);
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0) {
        noteProvider.scrollData(param: _param());
      }
    });
    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
      });
    });
  }

  Map<String, dynamic> _param() {
    NoteProvider noteProvider =
        Provider.of<NoteProvider>(context, listen: false);
    Map<String, dynamic> chat = noteProvider.chat!.toJson();

    Map<String, dynamic> temp = {};

    if (noteProvider.param!["chat_contains"] != null) {
      temp["chat_contains"] = noteProvider.param!["chat_contains"];
    }
    temp[kCheckLower] = true;
    List<String> _listKey = [
      kParamHargaJual,
      kParamHargaSewa,
      kPerMeterJualLower,
      kPerMeterSewaLower,
      kParamTransactionTypeID,
      kParamLT
    ];

    _listKey.forEach((element) {
      if (chat[element] != null) {
        temp[element] = chat[element];
      } else {
        temp[element + "_null"] = true;
      }
    });

    return temp;
  }

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
              "Merge",
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            ),
            action: _buildActions(),
          ),
          body: _body(),
        ),
        Visibility(
            visible: _isMerging,
            child: Container(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ))
      ],
    );
  }

  Widget _body() {
    return _buildList();
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.merge_type),
        onPressed: () {
          if (_listMerge.length > 1) {
            showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: Text("Merge Confirmation"),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(
                            'Are you sure want to merge ${_listMerge.length} selected chat?'),
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text("OK"),
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _isMerging = true;
                              Provider.of<NoteProvider>(context, listen: false)
                                  .mergeChat(_listMerge)
                                  .then((value) {
                                if (value != null) {
                                  Navigator.of(this.context).pop();
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Merge success"),
                                  ));
                                }
                              });
                            });
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
          } else {
            ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
              content: Text("Please select more than 1 chat"),
            ));
          }
        },
      ),
    ];
  }

  Widget _buildList() {
    double _radius = 15;
    //int _crossAxisCount = (MediaQuery.of(context).size.width / 300).floor() + 1;

    return Consumer<NoteProvider>(builder: (context, note, child) {
      if (note.dataMerge == null) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        if (note.dataMerge!.length > 0) {
          return new ListView.builder(
            padding: EdgeInsets.all(10.0),
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: note.dataMerge!.length,
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
                      Provider.of<NoteProvider>(context, listen: false).chat =
                          note.dataMerge!.elementAt(index);
                      Navigator.of(context).pushNamed(kRouteNoteAdd);
                    },
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
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.dataMerge!
                                              .elementAt(index)!
                                              .id
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        note.dataMerge!
                                            .elementAt(index)!
                                            .labelNew!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Visibility(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                        ),
                                        visible: note.dataMerge!
                                            .elementAt(index)!
                                            .check!,
                                      ),
                                      Visibility(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: Icon(
                                            Icons.warning,
                                            color: Colors.yellow,
                                          ),
                                        ),
                                        visible: note.dataMerge!
                                                .elementAt(index)!
                                                .ai ==
                                            true,
                                      ),
                                      Checkbox(
                                          value: _listMerge.firstWhere(
                                                  (element) =>
                                                      element ==
                                                      note.dataMerge![index]!
                                                          .id,
                                                  orElse: () => null) !=
                                              null,
                                          onChanged: (_) {
                                            setState(() {
                                              if (_!) {
                                                _listMerge.add(
                                                    note.dataMerge![index]!.id);
                                              } else {
                                                _listMerge.remove(
                                                    note.dataMerge![index]!.id);
                                              }
                                            });
                                          })
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    new DateFormat("dd MMM yyyy").format(
                                      new DateFormat("yyyy-MM-dd").parse(
                                        note.dataMerge!.elementAt(index)!.date!,
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
                                  ..._info(note.dataMerge!.elementAt(index)!),
                                  SizedBox(
                                    height: 18.0,
                                  ),
                                  Text(
                                    note.dataMerge!.elementAt(index)!.chat!,
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
                            ],
                          ),
                        ),
                      ],
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
          );
        } else {
          return Center(
            child: Text("No note found"),
          );
        }
      }
    });
  }

  List<Widget> _info(ChatModel chat) {
    CurrencyTextInputFormatter formatter =
        CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0);
    String transaksi = "-";
    String? luas = "-";
    List<String> harga = ["-", "-"];
    List<String> permeter = ["-", "-"];

    if (chat.transactionTypeID == "1") {
      transaksi = "Jual";
    } else if (chat.transactionTypeID == "2") {
      transaksi = "Sewa";
    } else if (chat.transactionTypeID == "3") {
      transaksi = "Jual / Sewa";
    }

    if (chat.lT != null && chat.lT!.isNotEmpty) {
      luas = chat.lT;
    }

    if (chat.hargaJual != null && chat.hargaJual!.isNotEmpty) {
      harga[0] = formatter.format(chat.hargaJual!);
    }

    if (chat.hargaSewa != null && chat.hargaSewa!.isNotEmpty) {
      harga[1] = formatter.format(chat.hargaSewa!);
    }

    if (chat.perMeterJual != null && chat.perMeterJual!.isNotEmpty) {
      permeter[0] = formatter.format(chat.perMeterJual!);
    }

    if (chat.perMeterSewa != null && chat.perMeterSewa!.isNotEmpty) {
      permeter[1] = formatter.format(chat.perMeterSewa!);
    }

    return [
      Divider(
        color: Colors.white,
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "Transaksi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            transaksi,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "LT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            luas!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "Harga Jual",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            harga[0],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "Harga Sewa",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            harga[1],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "Global /m2 Jual",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            permeter[0],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              "Global /m2 LT Sewa",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
            child: Text(
              ":",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            permeter[1],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      Divider(
        color: Colors.white,
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
