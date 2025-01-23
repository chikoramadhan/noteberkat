import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/filter_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/resources/helper.dart';

class FilterUI extends StatefulWidget {
  FilterUI({
    required this.requestModel,
    this.onlyTransactionsLocations = false,
    Key? key,
  }) : super(key: key);
  final RequestModel? requestModel;
  final bool onlyTransactionsLocations;
  late void Function(RequestModel?) refreshCallback;

  @override
  _State createState() => _State();
}

class _State extends State<FilterUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  late FilterProvider filterProvider;
  String searchQuery = "";
  int sort = 0;
  int page = 0;
  RequestModel? request;
  UserModel? user;
  bool _copyMode = false;
  List<ChatModel?> _listCopy = [];

  @override
  void initState() {
    super.initState();
    request = widget.requestModel;
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0) {
        Provider.of<FilterProvider>(context, listen: false).scrollData(
            param: filterProvider.selectedFilter != null
                ? filterProvider.selectedFilter!.data
                : _param());
      }
    });

    widget.refreshCallback = (_) {
      request = _;
      filterProvider.newData(param: _param());
    };

    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
        if (!filterProvider.doneInit) {
          filterProvider.newData(param: _param());
          filterProvider.doneInit = true;
        }
      });
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<FilterProvider>(
      builder: (context, value, child) {
        return _body(value);
      },
    );
  }

  Map<String, dynamic> _param() {
    Map<String, dynamic> _temp = {};

    _temp[kParamSort] = kSortDateDesc;

    if (widget.onlyTransactionsLocations) {
      _temp["chat_contains"] = "vslst";
      if (request!.transactionTypeID != null &&
          request!.transactionTypeID != "0") {
        _temp[kTransactionTypeID + "_in"] = [request!.transactionTypeID, 3];

        if (request!.transactionTypeID == "1") {
          _temp[kParamSort] = kSortPerMeterJualAsc;
        } else if (request!.transactionTypeID == "2") {
          _temp[kParamSort] = kSortPerMeterSewaAsc;
        }
      }

      if (request!.areas!.length > 0) {
        _temp["specific_location.sub_area.area.id_in"] =
            request!.areas!.map((e) => e.id).toList();
      }

      if (request!.subAreas!.length > 0) {
        _temp["specific_location.sub_area.id_in"] =
            request!.subAreas!.map((e) => e.id).toList();
      }

      if (request!.specificLocations!.length > 0) {
        _temp["specific_location.id_in"] =
            request!.specificLocations!.map((e) => e.id).toList();
      }
    } else {
      if (request!.keyword != null) {
        request!.keyword!.asMap().forEach((i, element) {
          _temp['_where[$i][chat_contains]'] = element;
        });
      } else {
        _temp["chat_contains"] = "vslst";
      }

      if (request!.transactionTypeID != null &&
          request!.transactionTypeID != "0") {
        _temp[kTransactionTypeID + "_in"] = [request!.transactionTypeID, 3];

        if (request!.transactionTypeID == "1") {
          _temp[kParamSort] = kSortPerMeterJualAsc;
        } else if (request!.transactionTypeID == "2") {
          _temp[kParamSort] = kSortPerMeterSewaAsc;
        }

        if (request!.budgetMax != null &&
            request!.budgetMax!.isNotEmpty &&
            request!.budgetMax != "0") {
          if (request!.transactionTypeID == "1") {
            _temp[kParamHargaJual + "_lte"] =
                (int.parse(request!.budgetMax!) * 1.1).toInt();
          } else if (request!.transactionTypeID == "2") {
            _temp[kParamHargaSewa + "_lte"] =
                (int.parse(request!.budgetMax!) * 1.1).toInt();
          }
        }

        if (request!.global != null &&
            request!.global!.isNotEmpty &&
            request!.global != "0") {
          if (request!.transactionTypeID == "1") {
            _temp[kBreakdownJualLower + "_lte"] =
                (int.parse(request!.global!) * 1.1).toInt();
          } else if (request!.transactionTypeID == "2") {
            _temp[kHargaSewaLower + "_lte"] =
                (int.parse(request!.global!) * 1.1).toInt();
          }
        }
      }

      if (request!.luasMin != null &&
          request!.luasMin!.isNotEmpty &&
          request!.luasMin != "0") {
        _temp[kParamLT + "_gte"] = (int.parse(request!.luasMin!) * 0.9).toInt();
      }

      if (request!.luasMax != null &&
          request!.luasMax!.isNotEmpty &&
          request!.luasMax != "0") {
        _temp[kParamLT + "_lte"] = (int.parse(request!.luasMax!) * 1.1).toInt();
      }

      _temp[kParamPropertyCategory + ".id_in"] =
          request!.propertyCategory!.map((e) => e.id).toList();

      if (request!.buildingType!.length > 0) {
        _temp[kParamBuildingType + ".id_in"] =
            request!.buildingType!.map((e) => e.id).toList();
      }

      if (request!.areas!.length > 0) {
        _temp["specific_location.sub_area.area.id_in"] =
            request!.areas!.map((e) => e.id).toList();
      }

      if (request!.subAreas!.length > 0) {
        _temp["specific_location.sub_area.id_in"] =
            request!.subAreas!.map((e) => e.id).toList();
      }

      if (request!.specificLocations!.length > 0) {
        _temp["specific_location.id_in"] =
            request!.specificLocations!.map((e) => e.id).toList();
      }
    }

    return _temp;
  }

  Widget _body(FilterProvider value) {
    return RefreshIndicator(
      child: Column(
        children: [
          Divider(
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Data : " + value.total.toString()),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Data Baru : " + value.baru.toString())
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Visibility(
                    child: Text(
                      _listCopy.length.toString(),
                    ),
                    visible: _copyMode,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Visibility(
                    visible: _copyMode,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _copyMode = false;
                          _listCopy.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.cancel),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Visibility(
                    visible: _copyMode,
                    child: InkWell(
                      onTap: () {
                        chatToClipboard(_listCopy, user, context, full: false);
                        setState(() {
                          _listCopy.clear();
                          _copyMode = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.copy),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Divider(
            height: 1,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _child(value),
            ),
          ),
        ],
      ),
      onRefresh: () {
        filterProvider.newData(param: _param());
        return Future.value(true);
      },
    );
  }

  Widget _child(FilterProvider note) {
    if (note.data == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * (1 / 3),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (note.data!.length == 0) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * (1 / 3),
        child: Center(
          child: Text("No listing found"),
        ),
      );
    }

    double _radius = 15;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Container(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(_radius),
                ),
                onLongPress: () {
                  if (isAdmin(user) || isMarketing(user)) {
                    this.setState(() {
                      _listCopy.add(note.data!.elementAt(index));
                      _copyMode = true;
                    });
                  }
                },
                onTap: () {
                  if (_copyMode) {
                    setState(() {
                      if (_listCopy.firstWhere(
                              (element) => element == note.data![index],
                              orElse: () => null) !=
                          null) {
                        _listCopy.remove(note.data![index]);
                      } else {
                        _listCopy.add(note.data![index]);
                      }
                    });
                  } else {
                    Provider.of<NoteProvider>(context, listen: false).chat =
                        note.data!.elementAt(index);
                    Navigator.of(context).pushNamed(kRouteNoteAdd);
                  }
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 25.0),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.data!
                                          .elementAt(index)!
                                          .id
                                          .toString(),
                                      style: TextStyle(
                                        color: note.data!
                                                        .elementAt(index)!
                                                        .updateAgent ==
                                                    null &&
                                                isStaff(user)
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    note.data!.elementAt(index)!.labelNew!,
                                    style: TextStyle(
                                      color: note.data!
                                                      .elementAt(index)!
                                                      .updateAgent ==
                                                  null &&
                                              isStaff(user)
                                          ? Colors.black
                                          : Colors.white,
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
                                        Icons.looks_one,
                                        color: note.data!
                                                        .elementAt(index)!
                                                        .updateAgent ==
                                                    null &&
                                                isStaff(user)
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    visible:
                                        note.data!.elementAt(index)!.check!,
                                  ),
                                  Visibility(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Icon(
                                        Icons.looks_two,
                                        color: note.data!
                                                        .elementAt(index)!
                                                        .updateAgent ==
                                                    null &&
                                                isStaff(user)
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    visible:
                                        note.data!.elementAt(index)!.check2!,
                                  ),
                                  Visibility(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Icon(
                                        Icons.looks_3,
                                        color: note.data!
                                                        .elementAt(index)!
                                                        .updateAgent ==
                                                    null &&
                                                isStaff(user)
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    visible:
                                        note.data!.elementAt(index)!.check3!,
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
                                    visible:
                                        note.data!.elementAt(index)!.ai == true,
                                  ),
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
                                    note.data!.elementAt(index)!.date!,
                                  ),
                                ),
                                style: TextStyle(
                                  color: note.data!
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
                              ..._info(note.data!.elementAt(index)!),
                              SizedBox(
                                height: 18.0,
                              ),
                              Text(
                                note.data!.elementAt(index)!.chat!,
                                style: TextStyle(
                                  color: note.data!
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
                    Visibility(
                      child: Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_radius),
                            color: Colors.black38,
                          ),
                          child: Center(
                            child: Visibility(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40.0,
                              ),
                              visible: _listCopy.firstWhere(
                                      (element) => element == note.data![index],
                                      orElse: () => null) !=
                                  null,
                            ),
                          ),
                        ),
                      ),
                      visible: _copyMode,
                    )
                  ],
                ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  note.data!.elementAt(index)!.updateAgent == null &&
                          isStaff(user)
                      ? Colors.white
                      : Color(0xff0396ff),
                  note.data!.elementAt(index)!.updateAgent == null &&
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
              note.data!.elementAt(index)!.updateAgent == null && isStaff(user)
                  ? Colors.black
                  : Color(0xffffefefe),
        );
      },
      itemCount: note.data!.length,
    );
  }

  List<Widget> _info(ChatModel chat) {
    Color textColor =
        chat.updateAgent == null && isStaff(user) ? Colors.black : Colors.white;
    Color labelColor = chat.updateAgent == null && isStaff(user)
        ? Colors.black87
        : Colors.white;

    Color labelGlobal =
        chat.updateAgent == null && isStaff(user) ? Colors.blue : Colors.white;

    Color labelBreakdown =
        chat.updateAgent == null && isStaff(user) ? Colors.red : Colors.white;
    CurrencyTextInputFormatter formatter =
        CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0);
    String transaksi = "-";
    String? subArea = "-";
    String? luas = "-";
    String? LB = "-";
    List<String> harga = ["-", "-"];
    List<String> permeter = ["-", "-"];
    String nilaiBangunan = "-";
    String nilaiTanah = "-";
    String breakdownJual = "-";
    String globalSewa = "-";
    String hargaSubArea = "-";
    String hargaLokasi = "-";

    if (chat.transactionTypeID == "1") {
      transaksi = "Jual";
    } else if (chat.transactionTypeID == "2") {
      transaksi = "Sewa";
    } else if (chat.transactionTypeID == "3") {
      transaksi = "Jual / Sewa";
    }

    if (chat.specificLocation != null &&
        chat.specificLocation!.subArea != null) {
      subArea = chat.specificLocation!.subArea!.title;
    }
    if (chat.lT != null && chat.lT!.isNotEmpty) {
      luas = chat.lT;
    }

    if (chat.lB != null && chat.lB!.isNotEmpty) {
      LB = chat.lB;
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

    if (chat.nilaiBangunan != null && chat.nilaiBangunan!.isNotEmpty) {
      nilaiBangunan = formatter.format(chat.nilaiBangunan!);
    }

    if (chat.nilaiTanah != null && chat.nilaiTanah!.isNotEmpty) {
      nilaiTanah = formatter.format(chat.nilaiTanah!);
    }

    if (chat.breakdownJual != null && chat.breakdownJual!.isNotEmpty) {
      breakdownJual = formatter.format(chat.breakdownJual!);
    }

    if (chat.globalSewa != null && chat.globalSewa!.isNotEmpty) {
      globalSewa = formatter.format(chat.globalSewa!);
    }

    if (chat.specificLocation != null && chat.specificLocation!.price != null) {
      hargaLokasi = formatter.format(chat.specificLocation!.price.toString());
    }

    if (chat.specificLocation != null &&
        chat.specificLocation!.subArea != null &&
        chat.specificLocation!.subArea!.price != null) {
      hargaSubArea =
          formatter.format(chat.specificLocation!.subArea!.price.toString());
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
                  "Sub Area",
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
                  subArea!,
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
                  transaksi,
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
                  "LT",
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
                  luas!,
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
                  "LB",
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
                  LB!,
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
                  "Harga Jual",
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
                  harga[0],
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
                  "Harga Sewa",
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
                  harga[1],
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
                  "Global /m2 Jual",
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
                  permeter[0],
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
                  "Global /m2 LT Sewa",
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
                  permeter[1],
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
                  "Global /m2 LB Sewa",
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
                  globalSewa,
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
                  "Nilai Bangunan",
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
                  nilaiBangunan,
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
                  "Nilai Tanah",
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
                  nilaiTanah,
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
                  "Breakdown /m2 Jual",
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
                  breakdownJual,
                  style: TextStyle(
                    color: labelBreakdown,
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
      SizedBox(
        height: 10,
      ),
      Center(
        child: Text(
          "Harga jual rata-rata tanah",
          style: TextStyle(
            color: labelColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Sub Area",
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
                  hargaSubArea,
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
                  "Lokasi",
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
                  hargaLokasi,
                  style: TextStyle(
                    color: labelColor,
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

    super.dispose();
  }
}

class KeywordList {
  TextEditingController? controller;
  List<String>? list;

  KeywordList({required List<String>? list}) {
    this.controller = new TextEditingController();
    this.list = list;
  }
}
