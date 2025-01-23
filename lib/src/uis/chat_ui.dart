import 'package:after_layout/after_layout.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_filter_chip.dart';
import 'package:versus/src/providers/chat_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/resources/helper.dart';

class ChatUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<ChatUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
  final ScrollController _scrollController = new ScrollController();

  Map<String, dynamic> _data = {
    kTransaksiLower: [false, false],
    kPropertyCategoryLower: <int>[],
    kSpecificLocationLower: <int>[],
    kLtLower: [kMinLT, kMaxLT],
    kHargaJualLower: [kMinHargaJual, kMaxHargaJual],
    kHargaSewaLower: [kMinHargaSewa, kMaxHargaSewa],
  };

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<ChatProvider>(context, listen: false).newData(param: _param());
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset > 0) {
        Provider.of<ChatProvider>(context, listen: false)
            .scrollData(param: _param());
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: Provider.of<ChatProvider>(context, listen: false).title,
        action: _action(),
      ),
      body: _body(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<ChatProvider>(
          builder: (context, value, child) {
            return Text("Total tidak terdeteksi : " + value.notDetected);
          },
        ),
      ),

      /*floatingActionButton: Badge(
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              backgroundColor: Colors.transparent,
              builder: (builder) {
                return ModalBottomSheet(
                  data: _data,
                  callback: (_) {
                    setState(() {
                      _data = _;
                      Provider.of<NoteProvider>(context, listen: false)
                          .newData(param: _param());
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
        padding: EdgeInsets.all(8.0),
        showBadge: _countBadge() > 0,
      ),*/
    );
  }

  Map<String, dynamic> _param() {
    Map<String, dynamic> _temp = {};

    int code = Provider.of<ChatProvider>(context, listen: false).code;

    if (code == 0) {
      _temp[kParamPropertyCategory + "_null"] = true;
    } else if (code == 1) {
      _temp[kTransactionTypeID + "_null"] = true;
    } else if (code == 2) {
      _temp[kParamSpecificLocation + "_null"] = true;
    }

    return _temp;
  }

  Widget _body() {
    return _buildList();
  }

  List<Widget> _action() {
    List<Widget> temp = [];
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
    //int _crossAxisCount = (MediaQuery.of(context).size.width / 300).floor() + 1;

    return Consumer<ChatProvider>(builder: (context, note, child) {
      if (note.data == null) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        if (note.data!.length > 0) {
          return new ListView.builder(
            padding: EdgeInsets.all(10.0),
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: note.data!.length,
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
                    onLongPress: () {},
                    onTap: () {
                      Provider.of<NoteProvider>(context, listen: false).chat =
                          note.data!.elementAt(index);
                      Navigator.of(context).pushNamed(kRouteNoteAdd);
                    },
                    child: Padding(
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
                                  Text(
                                    note.data!.elementAt(index).id.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                new DateFormat("dd MMM yyyy").format(
                                  new DateFormat("yyyy-MM-dd").parse(
                                    note.data!.elementAt(index).date!,
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
                                note.data!.elementAt(index).chat!,
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
          );
        } else {
          return Center(
            child: Text("No note found"),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ModalBottomSheet extends StatefulWidget {
  ModalBottomSheet({required this.data, required this.callback});

  final Map<String, dynamic> data;
  final dynamic callback;

  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  List<bool> _transaksi = [];
  List<int?> _kategori = [];
  List<int?> _lokasi = [];
  List<int> _lt = [];
  List<int> _hargaJual = [];
  List<int> _hargaSewa = [];

  List<MoneyMaskedTextController> _ltController = [];
  List<MoneyMaskedTextController> _hargaJualController = [];
  List<MoneyMaskedTextController> _hargaSewaController = [];

  @override
  void initState() {
    super.initState();
    _transaksi.addAll(widget.data[kTransaksiLower]);
    _kategori.addAll(widget.data[kPropertyCategoryLower]);
    _lokasi.addAll(widget.data[kSpecificLocationLower]);
    _lt.addAll(widget.data[kLtLower]);
    _hargaJual.addAll(widget.data[kHargaJualLower]);
    _hargaSewa.addAll(widget.data[kHargaSewaLower]);

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
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.25,
      builder: (context, scrollController) {
        return Consumer<ChatProvider>(
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
                                _transaksi[0] = false;
                                _transaksi[1] = false;
                                _kategori.clear();
                                _lokasi.clear();

                                _lt = [kMinLT, kMaxLT];
                                _hargaSewa = [kMinHargaSewa, kMaxHargaSewa];
                                _hargaJual = [kMinHargaJual, kMaxHargaJual];

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
                                      });
                                    },
                                    title: kJual),
                                CustomFilterChip(
                                    selected: _transaksi[1],
                                    callback: (_) {
                                      setState(() {
                                        _transaksi[1] = _;
                                      });
                                    },
                                    title: kSewa),
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
                                        color: value.categoryDisplay.length == 0
                                            ? Colors.grey
                                            : Colors.green),
                                  ),
                                ),
                                onTap: value.categoryDisplay.length == 0
                                    ? null
                                    : () async {
                                        Provider.of<SelectMasterProvider>(
                                                context,
                                                listen: false)
                                            .setData(
                                                selectAbleModel: value.category
                                                    .map((e) =>
                                                        e.selectAbleModel)
                                                    .toList(),
                                                selected: _kategori,
                                                title: kCariKategori);

                                        await Navigator.of(context)
                                            .pushNamed(kRouteFriendAdd);
                                        setState(() {
                                          _kategori.forEach((element) {
                                            if (value.categoryDisplay
                                                    .firstWhere(
                                                        (ele) =>
                                                            ele!.id == element,
                                                        orElse: () => null) ==
                                                null) {
                                              value.categoryDisplay.add(
                                                  value.category.firstWhereOrNull(
                                                      (ele) =>
                                                          ele.id == element));
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
                            padding: const EdgeInsets.only(right: 20.0),
                            child: value.categoryDisplay.length == 0
                                ? CircularProgressIndicator()
                                : Wrap(
                                    spacing: 10.0,
                                    children: value.categoryDisplay
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
                                              });
                                            },
                                            title: e.title))
                                        .toList(),
                                  ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              kLuasTanah,
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
                          Row(
                            children: [
                              Text(kLokasiSpesifik,
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
                                        color: value.categoryDisplay.length == 0
                                            ? Colors.grey
                                            : Colors.green),
                                  ),
                                ),
                                onTap: value.categoryDisplay.length == 0
                                    ? null
                                    : () async {
                                        Provider.of<SelectMasterProvider>(
                                                context,
                                                listen: false)
                                            .setData(
                                                selectAbleModel: value.location
                                                    .map((e) =>
                                                        e.selectAbleModel)
                                                    .toList(),
                                                selected: _lokasi,
                                                title: kCariLokasi);
                                        await Navigator.of(context)
                                            .pushNamed(kRouteFriendAdd);
                                        setState(() {
                                          _lokasi.forEach((element) {
                                            if (value.locationDisplay
                                                    .firstWhere(
                                                        (ele) =>
                                                            ele!.id == element,
                                                        orElse: () => null) ==
                                                null) {
                                              value.locationDisplay.add(
                                                  value.location.firstWhereOrNull(
                                                      (ele) =>
                                                          ele.id == element));
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
                            padding: const EdgeInsets.only(right: 20.0),
                            child: value.locationDisplay.length == 0
                                ? CircularProgressIndicator()
                                : Wrap(
                                    spacing: 10.0,
                                    children: value.locationDisplay
                                        .map((e) => CustomFilterChip(
                                            selected:
                                                _lokasi.indexOf(e!.id) > -1,
                                            callback: (_) {
                                              setState(() {
                                                if (_) {
                                                  _lokasi.add(e.id);
                                                } else {
                                                  _lokasi.remove(e.id);
                                                }
                                              });
                                            },
                                            title: e.lokasiSpesifikName))
                                        .toList(),
                                  ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
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
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              color: Colors.white,
                            ),
                          ),
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

  _submit() {
    if (!_transaksi.elementAt(0)) {
      _hargaJual = [kMinHargaJual, kMaxHargaJual];
    }

    if (!_transaksi.elementAt(1)) {
      _hargaSewa = [kMinHargaSewa, kMaxHargaSewa];
    }

    widget.callback({
      kTransaksiLower: _transaksi,
      kPropertyCategoryLower: _kategori,
      kSpecificLocationLower: _lokasi,
      kLtLower: _lt,
      kHargaJualLower: _hargaJual,
      kHargaSewaLower: _hargaSewa,
    });
    Navigator.of(context).pop();
  }
}
