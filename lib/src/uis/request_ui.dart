import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:badges/badges.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_sliver.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/request_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/views/request_view.dart';

class RequestUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<RequestUI>
    with AfterLayoutMixin
    implements RequestView {
  final ScrollController _scrollController = new ScrollController();

  Map<String, dynamic> _data = {
    kDateLower: [null, null],
    "filterBerdasarkan": 0,
    "tampilan": 0,
    "hasil": -1,
    kKeywordLower: [<String>[]],
    kCombinationLower: [],
    "dikerjakan": [0, 1, 2, 3, 4],
  };

  late RequestProvider requestProvider;
  NoteProvider? noteProvider;
  int sort = 0;
  int page = 0;
  bool loading = false;

  UserModel? user;

  @override
  void initState() {
    super.initState();
    requestProvider = Provider.of<RequestProvider>(context, listen: false);
    noteProvider = Provider.of<NoteProvider>(context, listen: false);
    requestProvider.view = this;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0) {
        Provider.of<RequestProvider>(context, listen: false).scrollData(
            param: requestProvider.selectedFilter != null
                ? requestProvider.selectedFilter!.data
                : _param(_data));
      }
    });
    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
        _data[kAdminLower] = isAdmin(user);
      });
    });
    requestProvider.loadFilterData();
    requestProvider.newData(param: _param(_data));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: _body(),
          floatingActionButton: fab(),
          drawerEnableOpenDragGesture: false,
        ),
        Visibility(
            visible: loading,
            child: Container(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ))
      ],
    );
  }

  Widget fab() {
    return Badge(
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.transparent,
            builder: (builder) {
              return ModalBottomSheet(
                user: user,
                data: _data,
                param: (_) {
                  return _param(_);
                },
                callback: (_) {
                  setState(() {
                    if (_[kReset] == true) {
                      page = 0;
                    }

                    (_ as Map<String, dynamic>).remove(kReset);
                    _data = _;
                    Provider.of<RequestProvider>(context, listen: false)
                        .newData(param: _param(_data));
                  });
                },
              );
            },
          );
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.filter_list,
          color: Colors.blue,
          size: 26.0,
        ),
      ),
      badgeContent: Text(
        _countBadge().toString(),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      badgeStyle: BadgeStyle(
        padding: EdgeInsets.all(8),
      ),
      showBadge: _countBadge() > 0,
    );
  }

  _countBadge() {
    int count = 0;

    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(0) != null
        ? 1
        : 0;
    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(1) != null
        ? 1
        : 0;
    count += (_data["tampilan"] != 0 ? 1 : 0);
    count +=
        _data[kKeywordLower].length > 0 && _data[kKeywordLower][0].length > 0
            ? 1
            : 0;

    return count;
  }

  Map<String, dynamic> _param(Map<String, dynamic> _data) {
    Map<String, dynamic> _temp = {};
    _temp[kParamSort] = kSortDateAsc;

    List<String?> _date = _data[kDateLower] as List<String?>;

    if (_date[0] != null) {
      _temp[kDateLower + "_gte"] = _date[0]! + "T00:00:00.000Z";

      List<int> parsed = _date[0]!.split("-").map((e) => int.parse(e)).toList();
      DateTime selected = DateTime(parsed[0], parsed[1], parsed[2]).toUtc();
      late DateTime start, end;
      if (_data["filterBerdasarkan"] == 2) {
        start = selected.subtract(Duration(hours: 8));

        end = selected.add(Duration(hours: 16));
      } else if (_data["filterBerdasarkan"] == 1) {
        start = selected;
        end = selected.add(Duration(hours: 23, minutes: 59, seconds: 59));
      }
      _temp[kDateLower + "_gte"] = start.toIso8601String();
      _temp[kDateLower + "_lte"] = end.toIso8601String();
    }

    if (_data["tampilan"] == 0) {
      _temp["request"] = true;
    } else if (_data["tampilan"] == 1) {
      _temp["request"] = false;
      if (_data["dikerjakan"].length > 0) {
        _temp["hasil_in"] = _data["dikerjakan"];
      } else {
        _temp["hasil"] = -1;
      }
    }

    List<String>? _keyword = [];

    if (_data[kKeywordLower].length > page) {
      _keyword = _data[kKeywordLower][page] as List<String>?;
    }

    if (_keyword!.length > 0) {
      _keyword.asMap().forEach((i, element) {
        //_temp['_where[$i][chat_contains]'] = element;
      });
    }

    if (_data[kCombinationLower].length > 0 &&
        _data[kCombinationLower][page].length > 0) {
      int chatIndex = 0;
      List<int> _tag = [];
      int idIndex = 0;
      int posIndex = -1;
      print(_data[kCombinationLower][page]);
      (_data[kCombinationLower][page] as List<Map<String, dynamic>>)
          .forEach((combination) {
        if (combination['type'] == "Keyword") {
          List<String> split = combination['value'].split(" ");

          if (split.length == 2 &&
              split[0].toLowerCase() == "id" &&
              (double.tryParse(split[1]) != null)) {
            if (posIndex == -1) {
              posIndex = chatIndex;
            }

            _temp['_where[$posIndex][id_in][$idIndex]'] = split[1];

            idIndex++;
          } else {
            _temp['_where[$chatIndex][chat_contains]'] = combination['value'];
          }

          chatIndex++;
        } else if (combination['type'] == "Tag") {
          _tag.add(int.parse(combination['id']!));
        }
      });

      if (_tag.length > 0) {
        _temp[kTagsLower + "_in"] = _tag;
      }
    }

    return _temp;
  }

  Widget _body() {
    return Consumer<RequestProvider>(builder: (context, value, child) {
      return RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            DynamicSliverAppBar(
              timestamp: new DateTime.now().millisecond,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Data : " + value.total.toString())
                            /*SizedBox(
                                    height: 8,
                                  ),
                                  Text("Data Baru : " + value.baru.toString())*/
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                  ],
                ),
              ),
              maxHeight: 200.0,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: CustomAppBar(
                  customTitle: Text(
                    "List Request",
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                  ),
                  action: [
                    _upload(),
                    /*PopupMenuButton<int>(
                      onSelected: (item) {
                        setState(() {
                          sort = item;
                        });

                        Provider.of<NoteProvider>(context, listen: false)
                            .newData(param: _param(_data));
                      },
                      icon: Icon(Icons.sort),
                      offset: Offset(0, 60),
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tanggal Request Terbaru',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Visibility(
                                child: Icon(Icons.check),
                                visible: sort == 0,
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tanggal Request Terlama',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Visibility(
                                child: Icon(Icons.check),
                                visible: sort == 3,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            ),
            _buildList(),
          ],
          controller: _scrollController,
        ),
        onRefresh: () {
          Provider.of<RequestProvider>(context, listen: false)
              .newData(param: _param(_data));
          return Future.value(true);
        },
      );
    });
  }

  Widget _upload() {
    if (!isAdmin(user) && !isMarketing(user)) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () async {
          RequestProvider provider =
              Provider.of<RequestProvider>(context, listen: false);

          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['txt', 'json'],
          );

          if (result != null) {
            List<File> files = result.paths.map((path) => File(path!)).toList();
            setState(() {
              loading = true;
            });

            requestProvider.uploadFile(files: files).then((response) {
              setState(() {
                loading = false;
              });
              Provider.of<RequestProvider>(context, listen: false)
                  .newData(param: _param(_data));
            });
          } else {
            // User canceled the picker
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  SliverList _buildList() {
    double _radius = 15;

    SliverList list = SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          if (requestProvider.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (requestProvider.data!.length > 0) {
              return StatefulBuilder(
                builder: (context, setState) {
                  Widget button = Container();

                  if (requestProvider.data!.elementAt(index)!.hasil == -1 &&
                      isAdmin(user)) {
                    button = Padding(
                      padding: const EdgeInsets.only(
                        top: 15,
                        right: 20,
                      ),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: Text("Confirmation"),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text('Bukan request?'),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: Text("OK"),
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      RequestProvider provider =
                                          Provider.of<RequestProvider>(context,
                                              listen: false);

                                      provider.editRequest(
                                        param: {"request": false, "hasil": 0},
                                        request: requestProvider.data!
                                            .elementAt(index),
                                      ).then((value) {});
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text("CANCEL"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.red,
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }

                  requestProvider.data!.elementAt(index)!.callback = () {
                    setState(() {});
                  };

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_radius),
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Container(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.all(
                            Radius.circular(_radius),
                          ),
                          onTap: () {
                            requestProvider.request =
                                requestProvider.data!.elementAt(index);
                            Navigator.of(context).pushNamed(kRouteRequestAdd);
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 25.0),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            String status = "";
                                            int? hasil = requestProvider.data!
                                                .elementAt(index)!
                                                .hasil;
                                            MaterialColor color = Colors.red;
                                            if (hasil == 0) {
                                              status = "Bukan request";
                                            } else if (hasil == 1) {
                                              status =
                                                  "Ada listing Versus yang sesuai";
                                              color = Colors.green;
                                            } else if (hasil == 2) {
                                              status =
                                                  "Hanya lokasi yang sesuai";
                                              color = Colors.blue;
                                            } else if (hasil == 3) {
                                              status =
                                                  "Tidak ada listing Versus yang sesuai";
                                            } else if (hasil == 4) {
                                              status =
                                                  "Request kembar dengan sebelumnya";
                                            }

                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    requestProvider.data!
                                                        .elementAt(index)!
                                                        .id
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: requestProvider
                                                                      .data!
                                                                      .elementAt(
                                                                          index)!
                                                                      .updateAgent ==
                                                                  null &&
                                                              isStaff(user)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  status,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          new DateFormat("dd MMM yyyy HH:mm")
                                              .format(
                                            new DateFormat("yyyy-MM-ddTHH:mm")
                                                .parse(
                                                    requestProvider.data!
                                                        .elementAt(index)!
                                                        .date!,
                                                    true)
                                                .toLocal(),
                                          ),
                                          style: TextStyle(
                                            color: requestProvider.data!
                                                            .elementAt(index)!
                                                            .updateAgent ==
                                                        null &&
                                                    isStaff(user)
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 18.0,
                                        ),
                                        ..._info(requestProvider.data!
                                            .elementAt(index)!),
                                        SizedBox(
                                          height: 18.0,
                                        ),
                                        Text(
                                          requestProvider.data!
                                              .elementAt(index)!
                                              .chat!,
                                          style: TextStyle(
                                            color: requestProvider.data!
                                                            .elementAt(index)!
                                                            .updateAgent ==
                                                        null &&
                                                    isStaff(user)
                                                ? Colors.black
                                                : Colors.white,
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
                              button
                            ],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            requestProvider.data!
                                            .elementAt(index)!
                                            .updateAgent ==
                                        null &&
                                    isStaff(user)
                                ? Colors.white
                                : Color(0xff0396ff),
                            requestProvider.data!
                                            .elementAt(index)!
                                            .updateAgent ==
                                        null &&
                                    isStaff(user)
                                ? Colors.white
                                : Color(0xffabdcff)
                          ],
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
                    color:
                        requestProvider.data!.elementAt(index)!.updateAgent ==
                                    null &&
                                isStaff(user)
                            ? Colors.black
                            : Color(0xffffefefe),
                  );
                },
              );
            } else {
              return Center(
                child: Text("No request found"),
              );
            }
          }
        },
        childCount:
            requestProvider.data == null || requestProvider.data!.length == 0
                ? 1
                : requestProvider.data!.length,
      ),
    );

    return list;
  }

  List<Widget> _info(RequestModel chat) {
    Color textColor =
        chat.updateAgent == null && isStaff(user) ? Colors.black : Colors.white;
    Color labelColor = chat.updateAgent == null && isStaff(user)
        ? Colors.black87
        : Colors.white;

    Color labelGlobal =
        chat.updateAgent == null && isStaff(user) ? Colors.blue : Colors.white;

    String budget = chat.budgetMax ?? "-";
    if (budget == "0" || budget.isEmpty || budget == "-") {
      budget = "-";
    } else {
      CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
          locale: "id", symbol: "", decimalDigits: 0);

      budget = "Rp. " + formatter.format(budget);
    }

    String transaksi = "-";

    if (chat.transactionTypeID == "1") {
      transaksi = "Jual";
    } else if (chat.transactionTypeID == "2") {
      transaksi = "Sewa";
    } else if (chat.transactionTypeID == "3") {
      transaksi = "Jual / Sewa";
    }

    return [
      Divider(
        color: textColor,
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Transaksi",
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  transaksi ?? "-",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Budget Max",
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  budget,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Luas Min",
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  chat.luasMin ?? "-",
                  style: TextStyle(
                    color: labelGlobal,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Luas Max",
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  chat.luasMax ?? "-",
                  style: TextStyle(
                    color: labelGlobal,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Divider(
        color: textColor,
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();

    requestProvider.clear();

    super.dispose();
  }

  @override
  void reload() {
    setState(() {});
  }
}

class ModalBottomSheet extends StatefulWidget {
  ModalBottomSheet(
      {required this.data,
      required this.callback,
      required this.param,
      required this.user});

  final Map<String, dynamic> data;
  final dynamic callback;
  final dynamic param;
  final UserModel? user;

  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  List<String?> _date = [];
  int? _filterBerdasarkan = 0;
  int? _tampilan = 0;
  List<int> _dikerjakan = [];
  List<KeywordList> _keyword = [];
  List<SelectAbleModel?> _tags = [];
  List<List<Map<String, String?>>> _combination = [];

  @override
  void initState() {
    super.initState();

    _date.addAll(widget.data[kDateLower]);
    _filterBerdasarkan = widget.data["filterBerdasarkan"];
    _tampilan = widget.data["tampilan"];
    _dikerjakan = widget.data["dikerjakan"];
    (widget.data[kKeywordLower] as List<List<String>?>).forEach((element) {
      if (element != null) {
        _keyword.add(new KeywordList(list: element));
      }
    });
    if (_keyword.length == 0) {
      _keyword.add(new KeywordList(list: []));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.25,
      builder: (context, scrollController) {
        return Consumer<RequestProvider>(
          builder: (context, value, child) {
            return SingleChildScrollView(
              controller: scrollController,
              child: new Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(10.0)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: 30.0,
                        height: 3.0,
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 20.0),
                      child: Row(
                        children: [
                          Text(
                            kFilter,
                            style: TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Expanded(child: Container()),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                kReset,
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _date = [null, null];

                                _filterBerdasarkan = 0;
                                _tampilan = 0;
                                _dikerjakan = [0, 1, 2, 3, 4];
                                _keyword.clear();

                                _submit();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 20.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _listKeyword(),
                          Text("Filter Berdasarkan",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, top: 20),
                            child: Column(
                              children: [
                                RadioListTile(
                                  value: 0,
                                  groupValue: _filterBerdasarkan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _filterBerdasarkan = _;
                                    });
                                  },
                                  title: Text("Semua"),
                                ),
                                RadioListTile(
                                  value: 1,
                                  groupValue: _filterBerdasarkan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _filterBerdasarkan = _;
                                    });
                                  },
                                  title: Text("Tanggal Real"),
                                ),
                                RadioListTile(
                                  value: 2,
                                  groupValue: _filterBerdasarkan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _filterBerdasarkan = _;
                                    });
                                  },
                                  title: Text("Tanggal Periode Kerja"),
                                ),
                              ],
                            ),
                          ),
                          _tanggal(),
                          SizedBox(
                            height: 40.0,
                          ),
                          Text("Tampilan",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, top: 20),
                            child: Column(
                              children: [
                                RadioListTile(
                                  value: 0,
                                  groupValue: _tampilan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _tampilan = _;
                                    });
                                  },
                                  title: Text("Belum Dikerjakan"),
                                ),
                                RadioListTile(
                                  value: 1,
                                  groupValue: _tampilan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _tampilan = _;
                                    });
                                  },
                                  title: Text("Sudah Dikerjakan"),
                                ),
                                RadioListTile(
                                  value: 2,
                                  groupValue: _tampilan,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _tampilan = _;
                                    });
                                  },
                                  title: Text("Semua"),
                                ),
                              ],
                            ),
                          ),
                          _belumKerja(),
                          SizedBox(
                            height: 30.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: MaterialButton(
                                    onPressed: () {
                                      _submit();
                                    },
                                    child: Container(
                                      height: 50.0,
                                      alignment: Alignment.center,
                                      child: Text(
                                        kFilter,
                                        style: new TextStyle(
                                          color: Colors.green,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0),
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Column _listKeyword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._keyword.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 40.0),
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: e.controller,
                            expands: false,
                            maxLines: 1,
                          ),
                        ),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Icon(
                              Icons.add,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () {
                            if (e.controller!.text.length > 0) {
                              setState(() {
                                e.list!.add(e.controller!.text);
                                e.controller!.text = "";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Wrap(
                            spacing: 10.0,
                            children: e.list!
                                .asMap()
                                .map(
                                  (i, t) => MapEntry(
                                      i,
                                      InputChip(
                                        label: Text(t),
                                        onDeleted: () {
                                          setState(() {
                                            e.list!.removeAt(i);
                                          });
                                        },
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            side: BorderSide(
                                                color: Colors.black,
                                                width: 0.3)),
                                      )),
                                )
                                .values
                                .toList(),
                          ),
                        ),
                      ),
                      Container(
                        child: Visibility(
                          child: Material(
                            child: InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.delete),
                              ),
                              onTap: () {
                                setState(() {
                                  _keyword.remove(e);
                                });
                              },
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          visible: _keyword.length > 1,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList()
      ],
    );
  }

  Widget _tanggal() {
    if (_filterBerdasarkan == 0) {
      return Container();
    }

    String title = "";

    if (_filterBerdasarkan == 1) {
      title = "Tanggal Real";
    } else if (_filterBerdasarkan == 2) {
      title = "Tanggal Periode Kerja";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            children: [
              SizedBox(
                width: 100.0,
                child: Text(
                  "Tanggal",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _date[0] == null ? "Select Date" : _date[0]!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue[900]),
                    ),
                  ),
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: new DateTime.now(),
                        firstDate: new DateTime.now().subtract(
                          Duration(days: 730),
                        ),
                        lastDate: new DateTime.now().add(
                          Duration(days: 365),
                        ),
                        currentDate: _date[0] != null
                            ? new DateFormat("yyyy-MM-dd").parse(_date[0]!)
                            : null);

                    if (date != null) {
                      setState(() {
                        _date[0] = date.toIso8601String().split("T")[0];
                      });
                    }
                  },
                ),
              ),
              InkWell(
                child: Icon(Icons.clear),
                onTap: () {
                  setState(() {
                    _date[0] = null;
                  });
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _belumKerja() {
    if (_tampilan != 1) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text("Tampilan Yang Sudah Dikerjakan",
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 20),
          child: Column(
            children: [
              CheckboxListTile(
                value: _dikerjakan.contains(0),
                onChanged: (_) {
                  setState(() {
                    _dikerjakan.contains(0)
                        ? _dikerjakan.remove(0)
                        : _dikerjakan.add(0);
                  });
                },
                title: Text("Bukan Request"),
              ),
              CheckboxListTile(
                value: _dikerjakan.contains(1),
                onChanged: (_) {
                  setState(() {
                    _dikerjakan.contains(1)
                        ? _dikerjakan.remove(1)
                        : _dikerjakan.add(1);
                  });
                },
                title: Text("Ada Listing Versus Yang Sesuai"),
              ),
              CheckboxListTile(
                value: _dikerjakan.contains(2),
                onChanged: (_) {
                  setState(() {
                    _dikerjakan.contains(2)
                        ? _dikerjakan.remove(2)
                        : _dikerjakan.add(2);
                  });
                },
                title: Text(
                    "Hanya Lokasi Yang Sesuai Tapi Isi Request Tidak Sesuai"),
              ),
              CheckboxListTile(
                value: _dikerjakan.contains(3),
                onChanged: (_) {
                  setState(() {
                    _dikerjakan.contains(3)
                        ? _dikerjakan.remove(3)
                        : _dikerjakan.add(3);
                  });
                },
                title: Text("Tidak Ada Listing Versus Yang Sesuai"),
              ),
              CheckboxListTile(
                value: _dikerjakan.contains(4),
                onChanged: (_) {
                  setState(() {
                    _dikerjakan.contains(4)
                        ? _dikerjakan.remove(4)
                        : _dikerjakan.add(4);
                  });
                },
                title: Text("Request Kembar Dengan Sebelumnya"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _data() {
    List<List<String>?> _list = [];
    _keyword.forEach((element) {
      if (element.list!.isNotEmpty) {
        _list.add(element.list);
        if (_tags.length > 0) {
          _tags.forEach((tag) {
            List<Map<String, String?>> data = [];
            data.add(
                {"type": "Tag", "value": tag!.title, "id": tag.id.toString()});
            element.list!.forEach((e) {
              data.add({
                "type": "Keyword",
                "value": e,
              });
            });
            _combination.add(data);
          });
        } else {
          List<Map<String, String>> data = [];

          element.list!.forEach((e) {
            data.add({
              "type": "Keyword",
              "value": e,
            });
          });
          _combination.add(data);
        }
      }
    });

    if (_combination.length == 0 && _tags.length > 0) {
      _tags.forEach((element) {
        _combination.add([
          {"type": "Tag", "value": element!.title, "id": element.id.toString()}
        ]);
      });
    }

    return {
      kDateLower: _date,
      "filterBerdasarkan": _filterBerdasarkan,
      "tampilan": _tampilan,
      kCombinationLower: _combination,
      kKeywordLower: _list,
      "dikerjakan": _dikerjakan,
    };
  }

  _submit() {
    widget.callback(_data());
    Navigator.of(context).pop();
  }
}

class KeywordList {
  TextEditingController? controller;
  List<String>? list;

  KeywordList({required List<String> list}) {
    this.controller = new TextEditingController();
    this.list = list;
  }
}
