import 'package:after_layout/after_layout.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_list.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/resources/popup_card.dart';
import 'package:versus/src/views/select_master_view.dart';

class SelectMasterUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SelectMasterUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin
    implements SelectMasterView {
  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _searchController = new TextEditingController();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  String _keyword = "";
  late SelectMasterProvider selectMasterProvider;

  @override
  void initState() {
    super.initState();
    selectMasterProvider =
        Provider.of<SelectMasterProvider>(context, listen: false);
    selectMasterProvider.view = this;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    selectMasterProvider.key = _scaffoldKey;
    _searchController.addListener(() {
      if (_keyword != _searchController.text) {
        _keyword = _searchController.text;
        if (_searchController.text.length > 0)
          selectMasterProvider.loadingSearch(keyword: _searchController.text);
        else
          selectMasterProvider.clearSearch();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        WillPopScope(
          child: Scaffold(
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            appBar: CustomAppBar(
              title: "Add Friends",
              leading: _leading(),
              action: selectMasterProvider.detail == null
                  ? [
                      Visibility(
                        child: Container(
                          height: 60.0,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onTap: () {
                              setState(() {
                                bool same = selectMasterProvider
                                        .selected.length ==
                                    selectMasterProvider.listSearch
                                        .where((element) => element!.id != -1)
                                        .length;

                                selectMasterProvider.selected.clear();
                                if (!same) {
                                  selectMasterProvider.selected.addAll(
                                      selectMasterProvider.listSearch
                                          .where((element) => element!.id != -1)
                                          .map((e) => e!.id)
                                          .toList());
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                selectMasterProvider.selected.length ==
                                        selectMasterProvider.listSearch.length
                                    ? "Hapus Semua"
                                    : "Pilih Semua",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        visible: !selectMasterProvider.single,
                      ),
                      Container(
                        width: 60.0,
                        height: 60.0,
                        padding: EdgeInsets.all(10.0),
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onTap: () {
                            _searchController.clear();
                            Provider.of<SelectMasterProvider>(context,
                                    listen: false)
                                .doneSelect(isSelected: true);
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.check,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ]
                  : [],
              customTitle: _searchBar(),
            ),
            body: _body(),
            floatingActionButton: selectMasterProvider.add != null
                ? PopupItemLauncher(
                    tag: 'add',
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Material(
                        color: Colors.blue,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(32),
                        child: Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    popUp: selectMasterProvider.add,
                  )
                : null,
          ),
          onWillPop: () {
            selectMasterProvider.doneSelect(isSelected: false);
            return new Future<bool>.value(true);
          },
        ),
        Consumer<SelectMasterProvider>(
          builder: (context, value, child) {
            return Visibility(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              visible: selectMasterProvider.submit,
            );
          },
        )
      ],
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
          selectMasterProvider.doneSelect(isSelected: false);
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
        hintText: selectMasterProvider.title,
      ),
    );
  }

  Widget _body() {
    return _buildList();
  }

  Widget _loading(SelectMasterProvider value) {
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
    return Consumer<SelectMasterProvider>(builder: (context, friend, child) {
      if (friend.listSearch.length > 0) {
        return ListView.builder(
          itemBuilder: (context, index) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: double.infinity,
                  child: _child(friend, index),
                );
              },
            );
          },
          padding: EdgeInsets.symmetric(vertical: 10.0),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: friend.listSearch.length,
        );
      } else {
        return _loading(friend);
      }
    });
  }

  Widget _child(SelectMasterProvider friend, int index) {
    if (friend.detail != null) {
      return PopupItemLauncher(
        tag: friend.listSearch.elementAt(index)!.id.toString(),
        child: _list(friend, index, false),
        popUp: friend.detail(friend.listSearch.elementAt(index)),
      );
    } else {
      return _list(friend, index, true);
    }
  }

  Widget _list(SelectMasterProvider friend, int index, bool callback) {
    Color? color;
    SelectAbleModel? selectAble = friend.listSearch.elementAt(index);
    if (friend.highlight != null && selectAble!.optional != null) {
      String text = friend.highlight!.toLowerCase();
      bool valid = true;

      if (selectAble.optional["Include"] != null) {
        List<String> include = selectAble.optional["Include"].split("\n");

        for (int i = 0; i < include.length; i++) {
          if (valid) {
            List<String> include2 = include[i].split(",");
            bool found = false;
            for (int j = 0; j < include2.length; j++) {
              if (valid) {
                if (RegExp(r'\b' + include2[j] + r'\b').hasMatch(text)) {
                  found = true;
                  break;
                }
              }
            }

            if (!found) {
              valid = false;
              break;
            }
          }
        }
      }

      if (valid && selectAble.optional["Exclude"] != null) {
        List<String> exclude = selectAble.optional["Exclude"].split("\n");

        for (int i = 0; i < exclude.length; i++) {
          if (valid) {
            List<String> exclude2 = exclude[i].split(",");
            bool found = false;
            for (int j = 0; j < exclude2.length; j++) {
              if (valid) {
                if (RegExp(r'\b' + exclude2[j] + r'\b').hasMatch(text)) {
                  found = true;
                  break;
                }
              }
            }

            if (found) {
              valid = false;
              break;
            }
          }
        }
      }

      if (valid) {
        color = Colors.yellow;
      }
    }

    String price = "";

    if (selectAble!.optional != null && selectAble.optional["Price"] != null) {
      price =
          ' (Rp. ${CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0).format(selectAble.optional["Price"])}/m2)';
    }

    return CustomList(
      id: selectAble.id,
      withId: friend.withId,
      color: color,
      title: friend.listSearch.elementAt(index)!.title! + price,
      subtitle: friend.listSearch.elementAt(index)!.subtitle,
      expandKeterangan: selectAble.optional != null &&
              selectAble.optional["Keterangan"] != null
          ? selectAble.optional["Keterangan"]
          : null,
      expandSubtitle:
          selectAble.optional != null && selectAble.optional["Subtitle"] != null
              ? selectAble.optional["Subtitle"]
              : null,
      trailing:
          friend.selected.indexOf(friend.listSearch.elementAt(index)!.id) > -1
              ? Icon(
                  Icons.check,
                  color: Colors.green,
                )
              : (friend.listSearch.elementAt(index)!.trailing != null &&
                      friend.listSearch.elementAt(index)!.trailing!.isNotEmpty
                  ? Text(friend.listSearch.elementAt(index)!.trailing!)
                  : Container(
                      height: 0,
                      width: 0,
                    )),
      callback: callback && selectAble.id != -1
          ? () {
              if (friend.detail == null) {
                setState(() {
                  if (friend.single == true) {
                    if (friend.selected.length > 0) {
                      friend.selected.clear();
                    }
                    friend.selected.add(friend.listSearch.elementAt(index)!.id);
                  } else {
                    friend.selected.indexOf(
                                friend.listSearch.elementAt(index)!.id) >
                            -1
                        ? friend.selected
                            .remove(friend.listSearch.elementAt(index)!.id)
                        : friend.selected
                            .add(friend.listSearch.elementAt(index)!.id);
                  }
                });
              }
            }
          : null,
    );
  }

  void addFriendCallback() {
    showMessage(_scaffoldKey as GlobalKey<ScaffoldState>, "Success add friend");
  }

  @override
  void back() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    selectMasterProvider.view = null;
    super.dispose();
  }
}
