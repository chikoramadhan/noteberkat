import 'dart:async';
import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:badges/badges.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_filter_chip.dart';
import 'package:versus/src/components/custom_sliver.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/providers/testing_provider.dart';
import 'package:versus/src/resources/helper.dart';

class TestingUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<TestingUI> with AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  Map<String, dynamic> _data = {
    kTransaksiLower: [false, false],
    kPropertyCategoryLower: <int>[],
    kLokasiLower: <int>[],
    kBuildingTypeLower: <int>[],
    kJenisLokasiLower: "-",
    kLtLower: [kMinLT, kMaxLT],
    kHargaJualLower: [kMinHargaJual, kMaxHargaJual],
    kHargaSewaLower: [kMinHargaSewa, kMaxHargaSewa],
    kPerMeterJualLower: [kMinHargaJual, kMaxHargaJual],
    kPerMeterSewaLower: [kMinHargaSewa, kMaxHargaSewa],
    kBreakdownJualLower: [kMinHargaJual, kMaxHargaJual],
    kGlobalSewaLower: [kMinHargaSewa, kMaxHargaSewa],
    kKeywordLower: [<String>[]],
    kOnlyNew: null,
    kCheckLower: null,
    kTagsLower: <SelectAbleModel>[],
    kAdminLower: false,
    kDateLower: [null, null],
    kCombinationLower: [],
    kFilterKategoriLower: 0,
  };

  late TestingProvider testingProvider;
  late NoteProvider noteProvider;
  String searchQuery = "";
  int sort = 0;
  int page = 0;

  UserModel? user;

  _countBadge() {
    int count = 0;
    count += (_data[kTransaksiLower] as List<bool>)
        .where((element) => element == true)
        .length;
    count += (_data[kPropertyCategoryLower] as List<int?>).length;
    count += (_data[kLokasiLower] as List<int?>).length;
    count += (_data[kBuildingTypeLower] as List<int?>).length;
    count += (_data[kLtLower] as List<int?>).elementAt(0) != kMinLT ? 1 : 0;
    count += (_data[kLtLower] as List<int?>).elementAt(1) != kMaxLT ? 1 : 0;
    count += (_data[kTagsLower] as List<SelectAbleModel?>).length > 0 ? 1 : 0;

    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(0) != null
        ? 1
        : 0;
    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(1) != null
        ? 1
        : 0;

    count += (_data[kHargaJualLower] as List<int>).elementAt(0) != kMinHargaJual
        ? 1
        : 0;
    count += (_data[kHargaJualLower] as List<int>).elementAt(1) != kMaxHargaJual
        ? 1
        : 0;
    count += (_data[kHargaSewaLower] as List<int>).elementAt(0) != kMinHargaSewa
        ? 1
        : 0;
    count += (_data[kHargaSewaLower] as List<int>).elementAt(1) != kMaxHargaSewa
        ? 1
        : 0;
    count +=
        (_data[kPerMeterJualLower] as List<int>).elementAt(0) != kMinHargaJual
            ? 1
            : 0;
    count +=
        (_data[kPerMeterJualLower] as List<int>).elementAt(1) != kMaxHargaJual
            ? 1
            : 0;
    count +=
        (_data[kPerMeterSewaLower] as List<int>).elementAt(0) != kMinHargaSewa
            ? 1
            : 0;
    count +=
        (_data[kPerMeterSewaLower] as List<int>).elementAt(1) != kMaxHargaSewa
            ? 1
            : 0;

    count +=
        (_data[kBreakdownJualLower] as List<int>).elementAt(0) != kMinHargaJual
            ? 1
            : 0;
    count +=
        (_data[kBreakdownJualLower] as List<int>).elementAt(1) != kMaxHargaJual
            ? 1
            : 0;
    count +=
        (_data[kGlobalSewaLower] as List<int>).elementAt(0) != kMinHargaSewa
            ? 1
            : 0;
    count +=
        (_data[kGlobalSewaLower] as List<int>).elementAt(1) != kMaxHargaSewa
            ? 1
            : 0;

    count +=
        _data[kKeywordLower].length > 0 && _data[kKeywordLower][0].length > 0
            ? 1
            : 0;
    count += _data[kOnlyNew] != null ? 1 : 0;
    count += _data[kCheckLower] != null ? 1 : 0;

    return count;
  }

  @override
  void initState() {
    super.initState();
    testingProvider = Provider.of<TestingProvider>(context, listen: false);
    noteProvider = Provider.of<NoteProvider>(context, listen: false);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0) {
        Provider.of<TestingProvider>(context, listen: false).scrollData(
            param: testingProvider.selectedFilter != null
                ? testingProvider.selectedFilter!.data
                : _param(_data));
      }
    });
    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
        _data[kAdminLower] = isAdmin(user);
      });
    });
    testingProvider.loadAllData(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<TestingProvider>(
          builder: (context, value, child) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: _body(),
              floatingActionButton: _fab(),
              drawerEnableOpenDragGesture: false,
            );
          },
        ),
      ],
    );
  }

  Widget _fab() {
    return Container();

    return testingProvider.selectedFilter != null
        ? FloatingActionButton(
            onPressed: () {
              testingProvider.selectedFilter = null;
              testingProvider.data!.clear();
              testingProvider.newData(param: _param(_data));
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.close,
              color: Colors.red,
              size: 26.0,
            ),
          )
        : Badge(
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
                          Provider.of<TestingProvider>(context, listen: false)
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
              style: TextStyle(color: Colors.white),
            ),
            badgeStyle: BadgeStyle(
              padding: EdgeInsets.all(8.0),
            ),
            showBadge: _countBadge() > 0,
          );
  }

  Map<String, dynamic> _param(Map<String, dynamic> _data) {
    print(_data);
    //print(searchQuery);
    Map<String, dynamic> _temp = {};

    if (sort == 0) {
      _temp[kParamSort] = kSortDateDesc;
    } else {
      if ((_data[kTransaksiLower] as List<bool>)
              .indexWhere((element) => element == true) ==
          1) {
        //sewa
        if (sort == 1) {
          _temp[kParamSort] = kSortPerMeterSewaAsc;
        } else {
          _temp[kParamSort] = kSortGlobalSewaAsc;
        }
      } else {
        //jual
        if (sort == 1) {
          _temp[kParamSort] = kSortPerMeterJualAsc;
        } else {
          _temp[kParamSort] = kSortBreakdownJualAsc;
        }
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
      (_data[kCombinationLower][page] as List<Map<String, String>>)
          .forEach((combination) {
        if (combination['type'] == "Keyword") {
          _temp['_where[$chatIndex][chat_contains]'] = combination['value'];
          chatIndex++;
        } else if (combination['type'] == "Tag") {
          _tag.add(int.parse(combination['id']!));
        }
      });

      if (_tag.length > 0) {
        _temp[kTagsLower + "_in"] = _tag;
      }
    }

    List<bool> _transaksi = _data[kTransaksiLower] as List<bool>;
    if (searchQuery.length > 0) {
      _temp[kChatLower + kParamContains] = searchQuery;
    }
    if (_transaksi.elementAt(0) ||
        (!_transaksi.elementAt(0) && !_transaksi.elementAt(1) && sort == 1)) {
      if (_temp[kTransactionTypeID + "_in"] == null) {
        _temp[kTransactionTypeID + "_in"] = [];
      }
      _temp[kTransactionTypeID + "_in"].add("1");
      _temp[kTransactionTypeID + "_in"].add("3");
      if (_data[kHargaJualLower].elementAt(0) != kMinHargaJual) {
        _temp[kParamHargaJual + "_gte"] = _data[kHargaJualLower].elementAt(0);
      }
      if (_data[kHargaJualLower].elementAt(1) != kMaxHargaJual) {
        _temp[kParamHargaJual + "_lte"] = _data[kHargaJualLower].elementAt(1);
      }

      if (_data[kPerMeterJualLower].elementAt(0) != kMinHargaJual) {
        _temp[kPerMeterJualLower + "_gte"] =
            _data[kPerMeterJualLower].elementAt(0);
      }
      if (_data[kPerMeterJualLower].elementAt(1) != kMaxHargaJual) {
        _temp[kPerMeterJualLower + "_lte"] =
            _data[kPerMeterJualLower].elementAt(1);
      }

      if (_data[kBreakdownJualLower].elementAt(0) != kMinHargaJual) {
        _temp[kBreakdownJualLower + "_gte"] =
            _data[kBreakdownJualLower].elementAt(0);
      }
      if (_data[kBreakdownJualLower].elementAt(1) != kMaxHargaJual) {
        _temp[kBreakdownJualLower + "_lte"] =
            _data[kBreakdownJualLower].elementAt(1);
      }
    }

    if (_transaksi.elementAt(1)) {
      if (_temp[kTransactionTypeID + "_in"] == null) {
        _temp[kTransactionTypeID + "_in"] = [];
      }

      if (_temp[kTransactionTypeID + "_in"].indexOf("3") > -1) {
        _temp[kTransactionTypeID + "_in"].remove("3");
      }

      _temp[kTransactionTypeID + "_in"].add("2");
      _temp[kTransactionTypeID + "_in"].add("3");

      if (_data[kHargaSewaLower].elementAt(0) != kMinHargaSewa) {
        _temp[kParamHargaSewa + "_gte"] = _data[kHargaSewaLower].elementAt(0);
      }

      if (_data[kHargaSewaLower].elementAt(1) != kMaxHargaSewa) {
        _temp[kParamHargaSewa + "_lte"] = _data[kHargaSewaLower].elementAt(1);
      }

      if (_data[kPerMeterSewaLower].elementAt(0) != kMinHargaSewa) {
        _temp[kPerMeterSewaLower + "_gte"] =
            _data[kPerMeterSewaLower].elementAt(0);
      }

      if (_data[kPerMeterSewaLower].elementAt(1) != kMaxHargaSewa) {
        _temp[kPerMeterSewaLower + "_lte"] =
            _data[kPerMeterSewaLower].elementAt(1);
      }

      if (_data[kGlobalSewaLower].elementAt(0) != kMinHargaSewa) {
        _temp[kGlobalSewaLower + "_gte"] = _data[kGlobalSewaLower].elementAt(0);
      }

      if (_data[kGlobalSewaLower].elementAt(1) != kMaxHargaSewa) {
        _temp[kGlobalSewaLower + "_lte"] = _data[kGlobalSewaLower].elementAt(1);
      }
    }

    List<String?> _date = _data[kDateLower] as List<String?>;

    if (_date[0] != null) {
      _temp[kDateLower + "_gte"] = _date[0]! + "T00:00:00.000Z";
    }
    if (_date[1] != null) {
      _temp[kDateLower + "_lte"] = _date[1]! + "T23:59:59.000Z";
    }

    List<int?> _kategori = _data[kPropertyCategoryLower] as List<int?>;
    if (_kategori.length > 0) {
      _temp[kParamPropertyCategory + ".id_in"] = [];
    }
    _kategori.forEach((element) {
      _temp[kParamPropertyCategory + ".id_in"].add(element);
    });

    List<int?> _tipeBangunan = _data[kBuildingTypeLower] as List<int?>;
    if (_tipeBangunan.length > 0) {
      _temp[kParamBuildingType + ".id_in"] = [];
    }
    _tipeBangunan.forEach((element) {
      _temp[kParamBuildingType + ".id_in"].add(element);
    });

    List<int?> _lokasi = _data[kLokasiLower] as List<int?>;
    if (_lokasi.length > 0) {
      String? jenisLokasi = _data[kJenisLokasiLower];

      if (jenisLokasi == "Area") {
        jenisLokasi = "specific_location.sub_area.area";
      } else if (jenisLokasi == "Sub Area") {
        jenisLokasi = "specific_location.sub_area";
      } else {
        jenisLokasi = "specific_location";
      }

      _temp[jenisLokasi + ".id_in"] = [];
      _lokasi.forEach((element) {
        _temp[jenisLokasi! + ".id_in"].add(element);
      });
    }

    List<int?> _lt = _data[kLtLower] as List<int?>;
    if (_lt.elementAt(0) != kMinLT) {
      _temp[kParamLT + "_gte"] = _lt.elementAt(0);
    }

    if (_lt.elementAt(1) != kMaxLT) {
      _temp[kParamLT + "_lte"] = _lt.elementAt(1);
    }

    if (_data[kOnlyNew] != null) _temp[kOnlyNew] = _data[kOnlyNew];
    if (_data[kCheckLower] != null) {
      _temp.addAll(jsonDecode(_data[kCheckLower]));
    }

    _temp["created_at_gte"] = "2025-01-01T09:28:00.000Z";
    //_temp["update_agent_null"] = true;

    // List<SelectAbleModel> _tag = _data[kTagsLower] as List<SelectAbleModel>;
    //if (_tag.length > 0) {
    //  _temp[kTagsLower + "_in"] = _tag.map((e) => e.id).toList();
    //}

    return _temp;
  }

  Widget _body() {
    return Consumer<TestingProvider>(
      builder: (context, value, child) {
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
                              Text("Total Data : " + value.total.toString()),
                              /* SizedBox(
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
                      _data[kCombinationLower].length > 0
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 20.0),
                              child: Wrap(
                                spacing: 10.0,
                                children: (_data[kCombinationLower][page]
                                        as List<Map<String, String>>)
                                    .asMap()
                                    .map(
                                      (i, t) => MapEntry(
                                          i,
                                          Chip(
                                            label: Text(
                                                '${t['type']} : ${t['value']}'),
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
                            )
                          : Container(),
                      Visibility(
                        child: NumberPagination(
                          onPageChanged: (int pageNumber) {
                            //do somthing for selected page
                            setState(() {
                              page = pageNumber - 1;
                              Provider.of<TestingProvider>(context,
                                      listen: false)
                                  .newData(param: _param(_data));
                            });
                          },
                          pageTotal: _data[kCombinationLower].length,
                          pageInit: page + 1, // picked number when init page
                          colorPrimary: Colors.blue,
                          colorSub: Colors.white,
                          controlButton: Container(),
                        ),
                        visible: _data[kCombinationLower].length > 1,
                      ),
                    ],
                  ),
                ),
                maxHeight: 400.0,
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: CustomAppBar(
                    leading: null,
                    customTitle: Text(
                      "Testing AI",
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                    action: _buildActions(),
                  ),
                ),
              ),
              _buildList(value),
            ],
            controller: _scrollController,
          ),
          onRefresh: () {
            Provider.of<TestingProvider>(context, listen: false)
                .newData(param: _param(_data));
            return Future.value(true);
          },
        );
      },
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      PopupMenuButton<int>(
        onSelected: (item) {
          setState(() {
            sort = item;
          });

          Provider.of<TestingProvider>(context, listen: false)
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
                    'Tanggal Chat',
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
              value: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Permeter ${(_data[kTransaksiLower] as List<bool>).indexWhere((element) => element == true) == 1 ? "Sewa" : "Jual"}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Visibility(
                    child: Icon(Icons.check),
                    visible: sort == 1,
                  )
                ],
              )),
          PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${(_data[kTransaksiLower] as List<bool>).indexWhere((element) => element == true) == 1 ? "Global /m2 LB sewa" : "Breakdown /m2 jual"}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Visibility(
                    child: Icon(Icons.check),
                    visible: sort == 2,
                  )
                ],
              )),
        ],
      ),
    ];
  }

  SliverList _buildList(TestingProvider testing) {
    double _radius = 15;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          if (testing.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (testing.data!.length > 0) {
              return StatefulBuilder(
                builder: (context, setState) {
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
                            testing.chat = testing.data!.elementAt(index);
                            Navigator.of(context).pushNamed(kRouteTestingAdd);
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                testing.data!
                                                    .elementAt(index)!
                                                    .id
                                                    .toString(),
                                                style: TextStyle(
                                                  color: testing.data!
                                                                  .elementAt(
                                                                      index)!
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
                                              testing.data!
                                                  .elementAt(index)!
                                                  .date!,
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: testing.data!
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
                                        ..._info(
                                            testing.data!.elementAt(index)!),
                                        SizedBox(
                                          height: 18.0,
                                        ),
                                        Text(
                                          testing.data!.elementAt(index)!.chat!,
                                          style: TextStyle(
                                            color: testing.data!
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
                            ],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            testing.data!.elementAt(index)!.updateAgent ==
                                        null &&
                                    isStaff(user)
                                ? Colors.white
                                : testing.data!.elementAt(index)!.checker !=
                                        null
                                    ? Colors.green
                                    : Color(0xff0396ff),
                            testing.data!.elementAt(index)!.updateAgent ==
                                        null &&
                                    isStaff(user)
                                ? Colors.white
                                : testing.data!.elementAt(index)!.checker !=
                                        null
                                    ? Colors.green[200]!
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
                        testing.data!.elementAt(index)!.updateAgent == null &&
                                isStaff(user)
                            ? Colors.black
                            : Color(0xffffefefe),
                  );
                },
              );
            } else {
              return Center(
                child: Text("No listing found"),
              );
            }
          }
        },
        childCount: testing.data == null || testing.data!.length == 0
            ? 1
            : testing.data!.length,
      ),
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
                  subArea,
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

    testingProvider.clear();
    noteProvider.testing = false;

    super.dispose();
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
  List<bool> _transaksi = [];
  List<int?> _kategori = [];
  List<int?> _lokasi = [];
  List<int?> _tipeBangunan = [];
  List<int> _lt = [];
  List<int> _hargaJual = [];
  List<int> _hargaSewa = [];
  List<int> _perMeterJual = [];
  List<int> _perMeterSewa = [];
  List<int> _breakdownJual = [];
  List<int> _globalSewa = [];
  List<String?> _date = [];
  List<SelectAbleModel?> _tags = [];
  List<KeywordList> _keyword = [];
  List<List<Map<String, String?>>> _combination = [];
  bool? _onlyNew;
  String? _check;
  bool reset = false;
  bool? isAdmin = false;
  List<String> _itemLokasi = ["-", "Area", "Sub Area", "Lokasi Spesifik"];
  String? _itemSelected;
  List<dynamic>? display;
  List<dynamic>? displayFull;
  late List<BuildingTypesModel?> buildingTypeDisplay;
  late List<BuildingTypesModel> buildingTypeDisplayFull;
  late List<PropertyCategoryModel?> categoryDisplay;
  late List<PropertyCategoryModel> categoryDisplayFull;
  int? _filterKategori = 0;

  List<MoneyMaskedTextController> _ltController = [];
  List<MoneyMaskedTextController> _hargaJualController = [];
  List<MoneyMaskedTextController> _hargaSewaController = [];
  List<MoneyMaskedTextController> _perMeterJualController = [];
  List<MoneyMaskedTextController> _perMeterSewaController = [];
  List<MoneyMaskedTextController> _breakdownJualController = [];
  List<MoneyMaskedTextController> _globalSewaController = [];

  @override
  void initState() {
    super.initState();
    TestingProvider testingProvider =
        Provider.of<TestingProvider>(context, listen: false);

    _date.addAll(widget.data[kDateLower]);
    _transaksi.addAll(widget.data[kTransaksiLower]);
    _kategori.addAll(widget.data[kPropertyCategoryLower]);
    _lokasi.addAll(widget.data[kLokasiLower]);
    _tipeBangunan.addAll(widget.data[kBuildingTypeLower]);
    _lt.addAll(widget.data[kLtLower]);
    _hargaJual.addAll(widget.data[kHargaJualLower]);
    _hargaSewa.addAll(widget.data[kHargaSewaLower]);
    _perMeterJual.addAll(widget.data[kPerMeterJualLower]);
    _perMeterSewa.addAll(widget.data[kPerMeterSewaLower]);
    _breakdownJual.addAll(widget.data[kBreakdownJualLower]);
    _globalSewa.addAll(widget.data[kGlobalSewaLower]);
    _tags.addAll(widget.data[kTagsLower]);
    (widget.data[kKeywordLower] as List<List<String>?>).forEach((element) {
      if (element != null) {
        _keyword.add(new KeywordList(list: element));
      }
    });

    _filterKategori = widget.data[kFilterKategoriLower];

    isAdmin = widget.data[kAdminLower];
    _itemSelected = widget.data[kJenisLokasiLower];
    setCategory(testingProvider);
    setDisplay(_itemSelected, testingProvider);
    setBuildingType(testingProvider);

    if (_keyword.length == 0) {
      _keyword.add(new KeywordList(list: []));
    }

    _onlyNew = widget.data[kOnlyNew];
    _check = widget.data[kCheckLower];

    _ltController.add(new MoneyMaskedTextController(
        initialValue: _lt.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _ltController.add(new MoneyMaskedTextController(
        initialValue: _lt.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _hargaJualController.add(new MoneyMaskedTextController(
        initialValue: _hargaJual.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _hargaJualController.add(new MoneyMaskedTextController(
        initialValue: _hargaJual.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _hargaSewaController.add(new MoneyMaskedTextController(
        initialValue: _hargaSewa.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _hargaSewaController.add(new MoneyMaskedTextController(
        initialValue: _hargaSewa.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _perMeterJualController.add(new MoneyMaskedTextController(
        initialValue: _perMeterJual.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _perMeterJualController.add(new MoneyMaskedTextController(
        initialValue: _perMeterJual.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _perMeterSewaController.add(new MoneyMaskedTextController(
        initialValue: _perMeterSewa.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _perMeterSewaController.add(new MoneyMaskedTextController(
        initialValue: _perMeterSewa.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _breakdownJualController.add(new MoneyMaskedTextController(
        initialValue: _breakdownJual.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _breakdownJualController.add(new MoneyMaskedTextController(
        initialValue: _breakdownJual.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _globalSewaController.add(new MoneyMaskedTextController(
        initialValue: _globalSewa.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _globalSewaController.add(new MoneyMaskedTextController(
        initialValue: _globalSewa.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.25,
      builder: (context, scrollController) {
        return Consumer<TestingProvider>(
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
                                _transaksi[0] = false;
                                _transaksi[1] = false;
                                _onlyNew = null;
                                _check = null;
                                _kategori.clear();
                                _tipeBangunan.clear();
                                _lokasi.clear();
                                _itemSelected = "-";
                                _keyword.clear();
                                _filterKategori = 0;

                                _lt = [kMinLT, kMaxLT];
                                _hargaSewa = [kMinHargaSewa, kMaxHargaSewa];
                                _hargaJual = [kMinHargaJual, kMaxHargaJual];
                                _perMeterJual = [kMinHargaSewa, kMaxHargaSewa];
                                _perMeterSewa = [kMinHargaJual, kMaxHargaJual];
                                _breakdownJual = [kMinHargaSewa, kMaxHargaSewa];
                                _globalSewa = [kMinHargaJual, kMaxHargaJual];
                                _tags = [];
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
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    reset = true;
                                    _keyword.add(new KeywordList(list: []));
                                  });
                                },
                                child: Container(
                                  height: 20.0,
                                  width: 100.0,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "+ Multi Filter",
                                    style: new TextStyle(
                                      color: Colors.green,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Text(kTransaksi,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Wrap(
                              spacing: 10.0,
                              children: [
                                CustomFilterChip(
                                    selected: _transaksi[0],
                                    callback: (_) {
                                      setState(() {
                                        _transaksi[0] = _;
                                        if (!_) {
                                          _hargaJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _hargaJual[0] = 0;
                                          _hargaJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _hargaJual[1] = 0;

                                          _perMeterJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _perMeterJual[0] = 0;
                                          _perMeterJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _perMeterJual[1] = 0;

                                          _breakdownJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _breakdownJual[0] = 0;
                                          _breakdownJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _breakdownJual[1] = 0;
                                        } else {
                                          _transaksi[1] = false;
                                          _hargaSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _hargaSewa[0] = 0;
                                          _hargaSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _hargaSewa[1] = 0;

                                          _perMeterSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _perMeterSewa[0] = 0;
                                          _perMeterSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _perMeterSewa[1] = 0;

                                          _globalSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _globalSewa[0] = 0;
                                          _globalSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _globalSewa[1] = 0;
                                        }
                                      });
                                    },
                                    title: kJual),
                                CustomFilterChip(
                                    selected: _transaksi[1],
                                    callback: (_) {
                                      setState(() {
                                        _transaksi[1] = _;
                                        if (!_) {
                                          _hargaSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _hargaSewa[0] = 0;
                                          _hargaSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _hargaSewa[1] = 0;

                                          _perMeterSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _perMeterSewa[0] = 0;
                                          _perMeterSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _perMeterSewa[1] = 0;

                                          _globalSewaController
                                              .elementAt(0)
                                              .text = "0";
                                          _globalSewa[0] = 0;
                                          _globalSewaController
                                              .elementAt(1)
                                              .text = "0";
                                          _globalSewa[1] = 0;
                                        } else {
                                          _transaksi[0] = false;
                                          _hargaJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _hargaJual[0] = 0;
                                          _hargaJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _hargaJual[1] = 0;

                                          _perMeterJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _perMeterJual[0] = 0;
                                          _perMeterJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _perMeterJual[1] = 0;

                                          _breakdownJualController
                                              .elementAt(0)
                                              .text = "0";
                                          _breakdownJual[0] = 0;
                                          _breakdownJualController
                                              .elementAt(1)
                                              .text = "0";
                                          _breakdownJual[1] = 0;
                                        }
                                      });
                                    },
                                    title: kSewa),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text("Filter Kategori",
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
                                  groupValue: _filterKategori,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _filterKategori = _;
                                      setCategory(value);
                                    });
                                  },
                                  title: Text("Dari Kategori Saja"),
                                ),
                                RadioListTile(
                                  value: 1,
                                  groupValue: _filterKategori,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _filterKategori = _;
                                      setCategory(value);
                                    });
                                  },
                                  title: Text("Dari Tipe Bangunan"),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(kKategori,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              Expanded(child: Container()),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    kLihatSemua,
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: categoryDisplay.length == 0
                                            ? Colors.grey
                                            : Colors.green),
                                  ),
                                ),
                                onTap: categoryDisplay.length == 0
                                    ? null
                                    : () async {
                                        Provider.of<SelectMasterProvider>(
                                                context,
                                                listen: false)
                                            .setData(
                                                selectAbleModel:
                                                    categoryDisplayFull
                                                        .map((e) =>
                                                            e.selectAbleModel)
                                                        .toList(),
                                                selected: _kategori,
                                                title: kCariKategori);

                                        await Navigator.of(context)
                                            .pushNamed(kRouteFriendAdd);
                                        setState(() {
                                          _kategori.forEach((element) {
                                            if (categoryDisplay.firstWhere(
                                                    (ele) => ele!.id == element,
                                                    orElse: () => null) ==
                                                null) {
                                              categoryDisplay.add(
                                                  categoryDisplayFull
                                                      .firstWhereOrNull((ele) =>
                                                          ele.id == element));
                                            }
                                          });
                                          setBuildingType(value);
                                        });
                                      },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: categoryDisplay.length == 0
                                ? CircularProgressIndicator()
                                : Wrap(
                                    spacing: 10.0,
                                    children: categoryDisplay
                                        .map((e) => CustomFilterChip(
                                            selected:
                                                _kategori.indexOf(e!.id) > -1,
                                            callback: (_) {
                                              setState(() {
                                                if (_) {
                                                  _kategori.add(e.id);
                                                } else {
                                                  _kategori.remove(e.id);
                                                }
                                                setBuildingType(value);
                                              });
                                            },
                                            title: e.title))
                                        .toList(),
                                  ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          buildingTypeDisplay.isNotEmpty && _filterKategori == 1
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(kTipeBangunan,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87)),
                                        Expanded(child: Container()),
                                        InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Text(
                                              kLihatSemua,
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: buildingTypeDisplay
                                                              .length ==
                                                          0
                                                      ? Colors.grey
                                                      : Colors.green),
                                            ),
                                          ),
                                          onTap: buildingTypeDisplay.length == 0
                                              ? null
                                              : () async {
                                                  Provider.of<SelectMasterProvider>(
                                                          context,
                                                          listen: false)
                                                      .setData(
                                                          selectAbleModel:
                                                              buildingTypeDisplayFull
                                                                  .map((e) => e
                                                                      .selectAbleModel2)
                                                                  .toList(),
                                                          selected:
                                                              _tipeBangunan,
                                                          title:
                                                              kCariTipeBangunan);

                                                  await Navigator.of(context)
                                                      .pushNamed(
                                                          kRouteFriendAdd);
                                                  setState(() {
                                                    _tipeBangunan
                                                        .forEach((element) {
                                                      if (buildingTypeDisplay
                                                              .firstWhere(
                                                                  (ele) =>
                                                                      ele!.id ==
                                                                      element,
                                                                  orElse: () =>
                                                                      null) ==
                                                          null) {
                                                        buildingTypeDisplay.add(
                                                            buildingTypeDisplayFull
                                                                .firstWhereOrNull(
                                                                    (ele) =>
                                                                        ele.id ==
                                                                        element));
                                                      }
                                                    });
                                                  });
                                                },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: buildingTypeDisplay.length == 0
                                          ? CircularProgressIndicator()
                                          : Wrap(
                                              spacing: 10.0,
                                              children: buildingTypeDisplay
                                                  .map((e) => CustomFilterChip(
                                                      selected: _tipeBangunan
                                                              .indexOf(e!.id) >
                                                          -1,
                                                      callback: (_) {
                                                        setState(() {
                                                          if (_) {
                                                            _tipeBangunan
                                                                .add(e.id);
                                                          } else {
                                                            _tipeBangunan
                                                                .remove(e.id);
                                                          }
                                                        });
                                                      },
                                                      title: e.title))
                                                  .toList(),
                                            ),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                  ],
                                )
                              : Container(),
                          Row(
                            children: [
                              Text("Filter Berdasarkan",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              Expanded(child: Container()),
                            ],
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _itemSelected,
                              items: _itemLokasi
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(e),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (item) => {
                                setState(() {
                                  _itemSelected = item;

                                  setDisplay(item, value);

                                  _lokasi.clear();
                                })
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          _itemSelected != "-"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(_itemSelected!,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87)),
                                        Expanded(child: Container()),
                                        InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Text(
                                              kLihatSemua,
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      categoryDisplay.length ==
                                                              0
                                                          ? Colors.grey
                                                          : Colors.green),
                                            ),
                                          ),
                                          onTap: displayFull!.length == 0
                                              ? null
                                              : () async {
                                                  Provider.of<SelectMasterProvider>(
                                                          context,
                                                          listen: false)
                                                      .setData(
                                                          selectAbleModel: displayFull!
                                                              .map((e) => e
                                                                      .selectAbleModel
                                                                  as SelectAbleModel?)
                                                              .toList(),
                                                          selected: _lokasi,
                                                          title: "Cari " +
                                                              _itemSelected!);

                                                  await Navigator.of(context)
                                                      .pushNamed(
                                                          kRouteFriendAdd);
                                                  setState(() {
                                                    _lokasi.forEach((element) {
                                                      if (display!.firstWhere(
                                                              (ele) =>
                                                                  ele.id ==
                                                                  element,
                                                              orElse: () =>
                                                                  null) ==
                                                          null) {
                                                        display!.add(displayFull!
                                                            .firstWhere(
                                                                (ele) =>
                                                                    ele.id ==
                                                                    element,
                                                                orElse: () =>
                                                                    null));
                                                      }
                                                    });
                                                  });
                                                },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: display!.length == 0
                                          ? CircularProgressIndicator()
                                          : Wrap(
                                              spacing: 10.0,
                                              children: display!
                                                  .map((e) => CustomFilterChip(
                                                      selected: _lokasi
                                                              .indexOf(e.id) >
                                                          -1,
                                                      callback: (_) {
                                                        setState(() {
                                                          if (_) {
                                                            _lokasi.add(e.id);
                                                          } else {
                                                            _lokasi
                                                                .remove(e.id);
                                                          }
                                                        });
                                                      },
                                                      title: e.title))
                                                  .toList(),
                                            ),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                  ],
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              "LT",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: _ltController.elementAt(0),
                                    onChanged: (_) {
                                      int data = 0;
                                      if (_.length > 0) {
                                        data = int.parse(_.replaceAll(".", ""));
                                      }
                                      _lt[0] = data;
                                      _ltController
                                          .elementAt(0)
                                          .updateValue(data.toDouble());
                                    },
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (_) {},
                                    style: new TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: _ltController.elementAt(1),
                                    onChanged: (_) {
                                      int data = 0;
                                      if (_.length > 0) {
                                        data = int.parse(_.replaceAll(".", ""));
                                      }
                                      _lt[1] = data;
                                      _ltController
                                          .elementAt(1)
                                          .updateValue(data.toDouble());
                                    },
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (_) {},
                                    style: new TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    kHargaJual,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller:
                                              _hargaJualController.elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _hargaJual[0] = data;
                                            _hargaJualController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller:
                                              _hargaJualController.elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _hargaJual[1] = data;
                                            _hargaJualController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    kPerMeterJual,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _perMeterJualController
                                              .elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _perMeterJual[0] = data;
                                            _perMeterJualController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _perMeterJualController
                                              .elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _perMeterJual[1] = data;
                                            _perMeterJualController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    "Breakdown /m2 Jual",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _breakdownJualController
                                              .elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _breakdownJual[0] = data;
                                            _breakdownJualController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _breakdownJualController
                                              .elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _breakdownJual[1] = data;
                                            _breakdownJualController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    kHargaSewa,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller:
                                              _hargaSewaController.elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _hargaSewa[0] = data;
                                            _hargaSewaController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller:
                                              _hargaSewaController.elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _hargaSewa[1] = data;
                                            _hargaSewaController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    kPerMeterSewa,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _perMeterSewaController
                                              .elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _perMeterSewa[0] = data;
                                            _perMeterSewaController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _perMeterSewaController
                                              .elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _perMeterSewa[1] = data;
                                            _perMeterSewaController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _transaksi.elementAt(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    "Global /m2 LB Sewa",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _globalSewaController
                                              .elementAt(0),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _globalSewa[0] = data;
                                            _globalSewaController
                                                .elementAt(0)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: _globalSewaController
                                              .elementAt(1),
                                          onChanged: (_) {
                                            int data = 0;
                                            if (_.length > 0) {
                                              data = int.parse(
                                                  _.replaceAll(".", ""));
                                            }
                                            _globalSewa[1] = data;
                                            _globalSewaController
                                                .elementAt(1)
                                                .updateValue(data.toDouble());
                                          },
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) {},
                                          style: new TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "Tampilan New",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              children: [
                                RadioListTile(
                                  value: null,
                                  groupValue: _onlyNew,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _onlyNew = _;
                                    });
                                  },
                                  title: Text("Semua"),
                                ),
                                RadioListTile(
                                  value: true,
                                  groupValue: _onlyNew,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _onlyNew = _;
                                    });
                                  },
                                  title: Text("Hanya New"),
                                ),
                                RadioListTile(
                                  value: false,
                                  groupValue: _onlyNew,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _onlyNew = _;
                                    });
                                  },
                                  title: Text("Tanpa New"),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "Tampilan Check",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              children: [
                                RadioListTile(
                                  value: null,
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Semua"),
                                ),
                                RadioListTile(
                                  value: checkValue([true, false, false]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 1"),
                                  subtitle:
                                      Text("(terisi transaksi, LT dan harga)"),
                                ),
                                RadioListTile(
                                  value: checkValue([false, true, false]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 2"),
                                  subtitle: Text(
                                      "(terisi kategori dan lokasi spesifik)"),
                                ),
                                RadioListTile(
                                  value: checkValue([false, false, true]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 3"),
                                  subtitle:
                                      Text("(terisi LB dan tipe bangunan)"),
                                ),
                                RadioListTile(
                                  value: checkValue([true, true, false]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 1 dan 2"),
                                ),
                                RadioListTile(
                                  value: checkValue([true, false, true]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 1 dan 3"),
                                ),
                                RadioListTile(
                                  value: checkValue([false, true, true]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Hanya Check 2 dan 3"),
                                ),
                                RadioListTile(
                                  value: checkValue([true, true, true]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Check 1, 2 dan 3"),
                                ),
                                RadioListTile(
                                  value: checkValue([false, false, false]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Tanpa Check"),
                                ),
                                RadioListTile(
                                  value: checkValue([false, null, null]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Tanpa Check 1"),
                                ),
                                RadioListTile(
                                  value: checkValue([null, false, null]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Tanpa Check 2"),
                                ),
                                RadioListTile(
                                  value: checkValue([null, null, false]),
                                  groupValue: _check,
                                  onChanged: (dynamic _) {
                                    setState(() {
                                      _check = _;
                                    });
                                  },
                                  title: Text("Tanpa Check 3"),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          isAdmin!
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Tag",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                      InkWell(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                        ),
                                        onTap: () async {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                color: Colors.black26,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          Provider.of<TestingProvider>(context,
                                                  listen: false)
                                              .getTag()
                                              .then((value) async {
                                            Navigator.of(context).pop();

                                            Provider.of<SelectMasterProvider>(
                                                    context,
                                                    listen: false)
                                                .setData(
                                              selectAbleModel: value.map((e) {
                                                SelectAbleModel selectModel =
                                                    new SelectAbleModel(
                                                        id: e.id,
                                                        title: e.name,
                                                        trailing:
                                                            e.chat.toString());
                                                return selectModel;
                                              }).toList(),
                                              selectedModel: _tags,
                                              title: "Search tag by name",
                                            );

                                            await Navigator.of(context)
                                                .pushNamed(kRouteFriendAdd);

                                            setState(() {});
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          Wrap(
                            spacing: 10.0,
                            children: _tags
                                .asMap()
                                .map(
                                  (i, t) => MapEntry(
                                    i,
                                    InputChip(
                                      label: Text(t!.title!),
                                      onDeleted: () {
                                        setState(() {
                                          _tags.removeWhere(
                                              (element) => element == t);
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          side: BorderSide(
                                              color: Colors.black, width: 0.3)),
                                    ),
                                  ),
                                )
                                .values
                                .toList(),
                          ),
                          Visibility(
                            child: SizedBox(
                              height: 20.0,
                            ),
                            visible: isAdmin!,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              "Tanggal Chat",
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
                                    "Dari",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _date[0] == null
                                            ? "Select Date"
                                            : _date[0]!,
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
                                          firstDate:
                                              new DateTime.now().subtract(
                                            Duration(days: 3650),
                                          ),
                                          lastDate: new DateTime.now().add(
                                            Duration(days: 3650),
                                          ),
                                          currentDate: _date[0] != null
                                              ? new DateFormat("yyyy-MM-dd")
                                                  .parse(_date[0]!)
                                              : null);

                                      if (date != null) {
                                        setState(() {
                                          _date[0] = date
                                              .toIso8601String()
                                              .split("T")[0];
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
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 100.0,
                                  child: Text(
                                    "Sampai",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _date[1] == null
                                            ? "Select Date"
                                            : _date[1]!,
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
                                          firstDate:
                                              new DateTime.now().subtract(
                                            Duration(days: 3650),
                                          ),
                                          lastDate: new DateTime.now().add(
                                            Duration(days: 3650),
                                          ),
                                          currentDate: _date[1] != null
                                              ? new DateFormat("yyyy-MM-dd")
                                                  .parse(_date[1]!)
                                              : null);

                                      if (date != null) {
                                        setState(() {
                                          _date[1] = date
                                              .toIso8601String()
                                              .split("T")[0];
                                        });
                                      }
                                    },
                                  ),
                                ),
                                InkWell(
                                  child: Icon(Icons.clear),
                                  onTap: () {
                                    setState(() {
                                      _date[1] = null;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Row(
                            children: [
                              /*Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: PopupItemLauncher(
                                    tag: 'simpanfilter',
                                    child: Card(
                                      elevation: 2,
                                      child: Container(
                                        height: 50.0,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Simpan Filter",
                                          style: new TextStyle(
                                            color: Colors.green,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)),
                                    ),
                                    popUp: PopUpItem(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32)),
                                      elevation: 2,
                                      tag: 'simpanfilter',
                                      child: Builder(
                                        builder: (ctx) {
                                          TextEditingController controller =
                                              new TextEditingController();
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: TextField(
                                                    controller: controller,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Nama Filter', //ubah
                                                    ),
                                                  ),
                                                ),
                                                const Divider(
                                                  color: Colors.white,
                                                  thickness: 0.2,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Provider.of<SelectMasterProvider>(
                                                            context,
                                                            listen: false)
                                                        .addMaster(
                                                            url:
                                                                kFilterUrl, //ubah

                                                            param: {
                                                              "title":
                                                                  controller
                                                                      .text,
                                                              "user": widget
                                                                  .user.user.id
                                                                  .toString(),
                                                              "data":
                                                                  widget.param(
                                                                      _data())
                                                            },
                                                            callback: (value) {
                                                              controller
                                                                  .clear();
                                                              FilterModel e =
                                                                  FilterModel
                                                                      .fromJson(
                                                                          value);
                                                              Provider.of<TestingProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .savedFilter
                                                                  .add(e);
                                                              SelectAbleModel
                                                                  selectModel =
                                                                  new SelectAbleModel(
                                                                id: e.id,
                                                                title: e.title,
                                                              );
                                                              return selectModel;
                                                            });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Simpan'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
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
                                  reset = true;
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

  setCategory(TestingProvider value) {
    categoryDisplayFull = [];
    categoryDisplay = [];

    categoryDisplayFull.addAll(value.category);
    categoryDisplay.addAll(value.categoryDisplay);

    if (_filterKategori == 1) {
      categoryDisplayFull.removeWhere((element) =>
          value.buildingTypes
              .map((e) => e.propertyCategory!.id)
              .toList()
              .indexOf(element.id) ==
          -1);
      categoryDisplay = [];
      if (categoryDisplayFull.length >= 5) {
        categoryDisplay.addAll(categoryDisplayFull
            .where((element) => categoryDisplayFull.indexOf(element) < 5));
      } else {
        categoryDisplay.addAll(categoryDisplayFull);
      }
    }

    List<int?> temp = [..._kategori];

    temp.forEach((element) {
      if (!categoryDisplayFull.map((e) => e.id).contains(element)) {
        _kategori.removeWhere((e) => e == element);
      }
    });
  }

  setBuildingType(TestingProvider value) {
    buildingTypeDisplayFull = [];
    buildingTypeDisplay = [];

    int? cat = -1;

    if (_kategori.isNotEmpty) {
      _kategori.forEach((element) {
        value.buildingTypes.forEach((e) {
          if (e.propertyCategory!.id == element) {
            if (cat != element) {
              cat = element;
              buildingTypeDisplayFull.add(BuildingTypesModel(
                id: -1,
              ));
            }

            buildingTypeDisplayFull.add(e);
          }
        });
      });

      if (buildingTypeDisplayFull.length >= 5) {
        List temp = buildingTypeDisplayFull
            .where((element) => element.id != -1)
            .toList();

        buildingTypeDisplay.addAll(
            temp.where((element) => temp.indexOf(element) < 5)
                as Iterable<BuildingTypesModel?>);
      } else {
        buildingTypeDisplay.addAll(
            buildingTypeDisplayFull.where((element) => element.id != -1));
      }
    }

    List<int?> temp = [..._tipeBangunan];

    temp.forEach((element) {
      if (!buildingTypeDisplayFull.map((e) => e.id).contains(element)) {
        _tipeBangunan.removeWhere((e) => e == element);
      }
    });
  }

  setDisplay(String? item, TestingProvider value) {
    if (item == "-") {
      display = null;
      displayFull = null;
    } else if (item == "Area") {
      display = value.areaDisplay;
      displayFull = value.area;
    } else if (item == "Sub Area") {
      display = value.subAreaDisplay;
      displayFull = value.subArea;
    } else if (item == "Lokasi Spesifik") {
      display = value.locationDisplay;
      displayFull = value.location;
    }
  }

  String checkValue(List<bool?> data) {
    Map<String, dynamic> json = {};

    if (data[0] != null) {
      json[kCheckLower] = data[0];
    }

    if (data[1] != null) {
      json[kCheck2Lower] = data[1];
    }

    if (data[2] != null) {
      json[kCheck3Lower] = data[2];
    }

    return jsonEncode(json);
  }

  Map<String, dynamic> _data() {
    if (!_transaksi.elementAt(0)) {
      _hargaJual = [kMinHargaJual, kMaxHargaJual];
      _perMeterJual = [kMinHargaJual, kMaxHargaJual];
      _breakdownJual = [kMinHargaJual, kMaxHargaJual];
    }

    if (!_transaksi.elementAt(1)) {
      _hargaSewa = [kMinHargaSewa, kMaxHargaSewa];
      _perMeterSewa = [kMinHargaSewa, kMaxHargaSewa];
      _globalSewa = [kMinHargaSewa, kMaxHargaSewa];
    }

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
      kTransaksiLower: _transaksi,
      kPropertyCategoryLower: _kategori,
      kLokasiLower: _lokasi,
      kJenisLokasiLower: _itemSelected,
      kLtLower: _lt,
      kTagsLower: _tags,
      kHargaJualLower: _hargaJual,
      kHargaSewaLower: _hargaSewa,
      kPerMeterJualLower: _perMeterJual,
      kPerMeterSewaLower: _perMeterSewa,
      kBreakdownJualLower: _breakdownJual,
      kGlobalSewaLower: _globalSewa,
      kKeywordLower: _list,
      kOnlyNew: _onlyNew,
      kCheckLower: _check,
      kReset: reset,
      kAdminLower: isAdmin,
      kDateLower: _date,
      kCombinationLower: _combination,
      kBuildingTypeLower: _tipeBangunan,
      kFilterKategoriLower: _filterKategori,
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
