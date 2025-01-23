import 'package:after_layout/after_layout.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_text_selection_file.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/filter_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/request_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/uis/filter_ui.dart';

class RequestAddUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<RequestAddUI>
    with
        AutomaticKeepAliveClientMixin,
        AfterLayoutMixin,
        SingleTickerProviderStateMixin {
  final GlobalKey _scaffoldKey = new GlobalKey<ScaffoldState>();

  UserModel? user;
  RequestModel? request;

  late Animation<double> _animation;
  late AnimationController _animationController;
  List<KeywordList> _keyword = [];

  bool _loading = false;
  bool _isSpliting = false;
  bool _isPhoneDetect = false;
  bool _isFiltering = false;
  bool _isNew = false;

  int? transaction = 0;
  int? filterCategory = 0;
  int? filterLocation = 0;

  FilterUI? _filterUI;

  String? luasMin = "", luasMax = "", budgetMax = "", global = "";
  String? updateAgent;

  TextEditingController _chatController = new TextEditingController();

  String? header, footer;
  List<String> content = [];

  List<SelectAbleModel?> _category = [];
  List<SelectAbleModel?> _location = [];
  List<SelectAbleModel?> _buildingType = [];

  late FilterProvider filterProvider;
  late RequestProvider requestProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    requestProvider = Provider.of<RequestProvider>(context, listen: false);

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    ToastContext().init(context);
    MainProvider().getMember().then((value) {
      RequestProvider requestProvider =
          Provider.of<RequestProvider>(context, listen: false);
      if (requestProvider.request != null &&
          requestProvider.request!.id == null) {
        _isNew = true;
        requestProvider.loadFilterData();
      }
      loadRequest(requestProvider.request, value!);

      Future.delayed(
          Duration(milliseconds: 100),
          () => requestProvider.loadDetail().then((request) {
                loadRequest(request, value!);
              }));
    });
  }

  loadRequest(RequestModel? request, UserModel value) {
    setState(() {
      _loading = false;

      _keyword.clear();
      if (request!.keyword == null) {
        _keyword.add(new KeywordList(list: ["vslst"]));
      } else {
        _keyword.add(new KeywordList(list: request.keyword));
      }

      if (request.callback == null && this.request != null) {
        request.callback = this.request!.callback;
      }
      this.request = request;

      filterCategory = 0;
      filterCategory = request.filterCategory ?? 0;

      filterLocation = 0;
      filterLocation = request.filterLocation ?? 0;

      _category.clear();
      if (request.propertyCategory != null) {
        _category.addAll(
            request.propertyCategory!.map((e) => e.selectAbleModel).toList());
      }

      _location.clear();
      if (filterLocation == 1) {
        _location.addAll(request.areas!.map((e) => e.selectAbleModel).toList());
      } else if (filterLocation == 2) {
        _location
            .addAll(request.subAreas!.map((e) => e.selectAbleModel).toList());
      } else if (filterLocation == 3) {
        _location.addAll(
            request.specificLocations!.map((e) => e.selectAbleModel).toList());
      }

      _buildingType.clear();
      if (request.buildingType != null) {
        _buildingType.addAll(
            request.buildingType!.map((e) => e.selectAbleModel2).toList());
      }

      updateAgent = request.updateAgent;
      user = value;

      transaction = 0;
      luasMin = "";
      luasMax = "";
      budgetMax = "";
      global = "";

      if (request.transactionTypeID != null) {
        transaction = int.parse(request.transactionTypeID!);
      }

      if (request.luasMin != null) {
        luasMin = request.luasMin;
      }

      if (request.luasMax != null) {
        luasMax = request.luasMax;
      }

      if (request.budgetMax != null) {
        budgetMax = request.budgetMax;
      }

      if (request.global != null) {
        global = request.global;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (user == null) {
      return Container();
    }

    RequestProvider requestProvider =
        Provider.of<RequestProvider>(context, listen: false);

    RequestModel request = requestProvider.request!;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: request.id == null ? "Add Request" : request.id.toString(),
            leading: _leading(),
            action: _trailing(),
          ),
          body: _isFiltering ? _filter() : _body(),
          floatingActionButton: request.id != null ? _fab() : null,
        ),
        Visibility(
          visible: _loading,
          child: Container(
            color: Colors.black38,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _luasMin() {
    return Expanded(
      child: TextField(
        enabled: isAdmin(user) || isMarketing(user),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: luasMin),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
        ],
        onChanged: (_) {
          luasMin = _;
        },
      ),
    );
  }

  Widget _luasMax() {
    return Expanded(
      child: TextField(
        enabled: isAdmin(user) || isMarketing(user),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: luasMax),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
        ],
        onChanged: (_) {
          luasMax = _;
        },
      ),
    );
  }

  Widget _budgetMax() {
    return Expanded(
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enabled: isAdmin(user) || isMarketing(user),
        controller: MoneyMaskedTextController(
          decimalSeparator: "",
          thousandSeparator: ".",
          precision: 0,
          initialValue: budgetMax!.isEmpty ? 0 : double.parse(budgetMax!),
        ),
        onChanged: (_) {
          budgetMax = _.replaceAll(".", "");
        },
      ),
    );
  }

  Widget _globalMax() {
    return Expanded(
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enabled: isAdmin(user) || isMarketing(user),
        controller: MoneyMaskedTextController(
          decimalSeparator: "",
          thousandSeparator: ".",
          precision: 0,
          initialValue: global!.isEmpty ? 0 : double.parse(global!),
        ),
        onChanged: (_) {
          global = _.replaceAll(".", "");
        },
      ),
    );
  }

  String checkPrice(String txt) {
    String temp = txt.replaceAll(".", "");
    List<String> spt = temp.split("").reversed.toList();
    String res = "";
    int index = 0;
    spt.forEach((element) {
      index += 1;
      res = element + res;
      if (index % 3 == 0 && index != spt.length) {
        res = "." + res;
      }
    });
    return res;
  }

  Widget _filter() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _body(),
        ),
        Expanded(
          flex: 2,
          child: _filterUI!,
        ),
      ],
    );
  }

  Widget _body() {
    Consumer consumer =
        Consumer<RequestProvider>(builder: (context, value, child) {
      return _innerChild(value);
    });

    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: consumer,
          ),
        );
      },
    );
  }

  Widget widgetTransaction() {
    if (isAdmin(user) || isMarketing(user)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (transaction != 0) {
                setState(() {
                  transaction = 0;
                });
              }
            },
            child: Row(
              children: [
                Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: 0,
                  groupValue: transaction,
                  onChanged: (dynamic _) {
                    setState(() {
                      transaction = _;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text("-"),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              if (transaction != 1) {
                setState(() {
                  transaction = 1;
                });
              }
            },
            child: Row(
              children: [
                Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: 1,
                  groupValue: transaction,
                  onChanged: (dynamic _) {
                    setState(() {
                      transaction = _;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text("Jual"),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              if (transaction != 2) {
                setState(() {
                  transaction = 2;
                });
              }
            },
            child: Row(
              children: [
                Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: 2,
                  groupValue: transaction,
                  onChanged: (dynamic _) {
                    setState(() {
                      transaction = _;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text("Sewa"),
              ],
            ),
          ),
        ],
      );
    }

    String text = "-";

    if (transaction == 1) {
      text = "Jual";
    }
    if (transaction == 2) {
      text = "Sewa";
    }

    return Text(text);
  }

  Widget widgetFilterCategories() {
    if (isAdmin(user) || isMarketing(user)) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (filterCategory != 0) {
                  setState(() {
                    filterCategory = 0;
                    setCategory();
                    setBuilding();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 0,
                    groupValue: filterCategory,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterCategory = _;
                        setCategory();
                        setBuilding();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Dari Kategori Saja"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                if (filterCategory != 1) {
                  setState(() {
                    filterCategory = 1;
                    setCategory();
                    setBuilding();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 1,
                    groupValue: filterCategory,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterCategory = _;
                        setCategory();
                        setBuilding();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Dari Tipe Bangunan"),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (filterCategory == 0) {
      return Text("Dari Kategori Saja");
    } else {
      return Text("Dari Tipe Bangunan");
    }
  }

  Widget widgetCategories(RequestProvider value) {
    if (isAdmin(user) || isMarketing(user)) {
      return Expanded(
        child: Wrap(
          spacing: 10.0,
          children: [
            ActionChip(
              label: Text("Add +"),
              onPressed: () async {
                if (value.category.length > 0) {
                  List<SelectAbleModel?> data = [
                    ...(value.category).map((e) => e.selectAbleModel).toList()
                  ];

                  if (filterCategory == 1) {
                    List<SelectAbleModel?> temp = [];
                    for (int i = 0; i < data.length; i++) {
                      BuildingTypesModel? building = value.buildingTypes
                          .firstWhereOrNull((element) =>
                              element.propertyCategory!.id == data[i]!.id);
                      if (building != null) {
                        temp.add(data[i]);
                      }
                    }
                    data = temp;
                  }

                  Provider.of<SelectMasterProvider>(context, listen: false)
                      .setData(
                          selectAbleModel: data,
                          selectedModel: _category,
                          title: kCariKategori);

                  await Navigator.of(context).pushNamed(kRouteFriendAdd);
                  setCategory();
                  setBuilding();
                  setState(() {});
                }
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.black, width: 0.3),
              ),
            ),
            ..._category
                .asMap()
                .map(
                  (i, t) => MapEntry(
                      i,
                      InputChip(
                        label: Text(t!.title ?? "no"),
                        onDeleted: () {
                          setState(() {
                            _category.removeAt(i);
                            _buildingType.clear();
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3)),
                      )),
                )
                .values
                .toList()
          ],
        ),
      );
    }

    return Expanded(
      child: Wrap(
        spacing: 10.0,
        children: [
          ..._category
              .asMap()
              .map(
                (i, t) => MapEntry(
                  i,
                  ActionChip(
                    onPressed: () {},
                    label: Text(t!.title ?? "no"),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: Colors.black, width: 0.3)),
                  ),
                ),
              )
              .values
              .toList()
        ],
      ),
    );
  }

  Widget widgetFilterlocation() {
    if (isAdmin(user) || isMarketing(user)) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (filterLocation != 0) {
                  setState(() {
                    filterLocation = 0;
                    _location.clear();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 0,
                    groupValue: filterLocation,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterLocation = _;
                        _location.clear();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("-"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                if (filterLocation != 1) {
                  setState(() {
                    filterLocation = 1;
                    _location.clear();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 1,
                    groupValue: filterLocation,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterLocation = _;
                        _location.clear();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Area"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                if (filterLocation != 2) {
                  setState(() {
                    filterLocation = 2;
                    _location.clear();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 2,
                    groupValue: filterLocation,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterLocation = _;
                        _location.clear();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Sub Area"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                if (filterLocation != 3) {
                  setState(() {
                    filterLocation = 3;
                    _location.clear();
                  });
                }
              },
              child: Row(
                children: [
                  Radio(
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: 3,
                    groupValue: filterLocation,
                    onChanged: (dynamic _) {
                      setState(() {
                        filterLocation = _;
                        _location.clear();
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Lokasi Spesifik"),
                ],
              ),
            ),
          ],
        ),
      );
    }

    String text = "-";

    if (filterLocation == 1) {
      text = "Area";
    } else if (filterLocation == 2) {
      text = "Sub Area";
    } else if (filterLocation == 3) {
      text = "Lokasi Spesifik";
    }

    return Text(text);
  }

  Widget widgetLocation(RequestProvider value) {
    if (isAdmin(user) || isMarketing(user)) {
      return Expanded(
        child: Wrap(
          spacing: 10.0,
          children: [
            ActionChip(
              label: Text("Add +"),
              onPressed: () async {
                List<dynamic> data;

                if (filterLocation == 1) {
                  data = value.area;
                } else if (filterLocation == 2) {
                  data = value.subArea;
                } else {
                  data = value.location;
                }

                if (data.length > 0) {
                  Provider.of<SelectMasterProvider>(context, listen: false)
                      .setData(
                          selectAbleModel: data
                              .map((e) => e.selectAbleModel as SelectAbleModel?)
                              .toList(),
                          selectedModel: _location,
                          title: kCariLokasi);

                  await Navigator.of(context).pushNamed(kRouteFriendAdd);
                  setState(() {});
                }
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.black, width: 0.3),
              ),
            ),
            ..._location
                .asMap()
                .map(
                  (i, t) => MapEntry(
                      i,
                      InputChip(
                        label: Text(t!.title!),
                        onDeleted: () {
                          setState(() {
                            _location.removeAt(i);
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3)),
                      )),
                )
                .values
                .toList()
          ],
        ),
      );
    }

    return Expanded(
      child: Wrap(
        spacing: 10.0,
        children: [
          ..._location
              .asMap()
              .map(
                (i, t) => MapEntry(
                  i,
                  ActionChip(
                    onPressed: () {},
                    label: Text(t!.title!),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: Colors.black, width: 0.3)),
                  ),
                ),
              )
              .values
              .toList()
        ],
      ),
    );
  }

  Widget widgetTipeBangunan(RequestProvider value) {
    if (isAdmin(user) || isMarketing(user)) {
      return Expanded(
        child: Wrap(
          spacing: 10.0,
          children: [
            ActionChip(
              label: Text("Add +"),
              onPressed: () async {
                if (value.buildingTypes.length > 0) {
                  List<SelectAbleModel?> data = [];

                  int? cat = -1;
                  _category.forEach((element) {
                    value.buildingTypes.forEach((e) {
                      if (e.propertyCategory!.id == element!.id) {
                        if (cat != element.id) {
                          cat = element.id;
                          data.add(
                            BuildingTypesModel(
                              id: -1,
                              optional: {},
                            ).selectAbleModel2,
                          );
                        }

                        data.add(e.selectAbleModel2);
                      }
                    });
                  });

                  Provider.of<SelectMasterProvider>(context, listen: false)
                      .setData(
                    selectAbleModel: data,
                    selectedModel: _buildingType,
                    title: kCariTipeBangunan,
                  );

                  await Navigator.of(context).pushNamed(kRouteFriendAdd);
                  setState(() {});
                }
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.black, width: 0.3),
              ),
            ),
            ..._buildingType
                .asMap()
                .map(
                  (i, t) => MapEntry(
                      i,
                      InputChip(
                        label: Text(t!.title ?? "no"),
                        onDeleted: () {
                          setState(() {
                            _buildingType.removeAt(i);
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3)),
                      )),
                )
                .values
                .toList()
          ],
        ),
      );
    }

    return Expanded(
      child: Wrap(
        spacing: 10.0,
        children: [
          ..._buildingType
              .asMap()
              .map(
                (i, t) => MapEntry(
                  i,
                  ActionChip(
                    onPressed: () {},
                    label: Text(t!.title ?? "no"),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: Colors.black, width: 0.3)),
                  ),
                ),
              )
              .values
              .toList()
        ],
      ),
    );
  }

  _innerChild(RequestProvider value) {
    if (value.request != null && value.request!.chat != null) {
      _chatController.text = value.request!.chat!;
    }

    String status = "-";
    int? hasil = value.request!.hasil;
    MaterialColor color = Colors.red;
    if (hasil == 0) {
      status = "Bukan request";
    } else if (hasil == 1) {
      status = "Ada listing Versus yang sesuai";
      color = Colors.green;
    } else if (hasil == 2) {
      status = "Hanya lokasi yang sesuai";
      color = Colors.blue;
    } else if (hasil == 3) {
      status = "Tidak ada listing Versus yang sesuai";
    } else if (hasil == 4) {
      status = "Request kembar dengan sebelumnya";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 110.0, child: Text("Status")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Text(
              status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 110.0, child: Text(kTransaksi)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Expanded(
              child: widgetTransaction(),
            )
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 110.0, child: Text("Filter Kategori")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            widgetFilterCategories(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(width: 110.0, child: Text("Kategori")),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15,
              ),
              child: Text(":"),
            ),
            widgetCategories(value),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        filterCategory == 1
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child:
                        Container(width: 110.0, child: Text("Tipe Bangunan")),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 15),
                    child: Text(":"),
                  ),
                  widgetTipeBangunan(value),
                ],
              )
            : Container(),
        SizedBox(
          height: 10.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 110.0, child: Text("Filter Lokasi")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            widgetFilterlocation(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Visibility(
          visible: filterLocation! > 0,
          child: Builder(
            builder: (context) {
              String text;
              if (filterLocation == 1) {
                text = "Area";
              } else if (filterLocation == 2) {
                text = "Sub Area";
              } else {
                text = "Lokasi Spesifik";
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(width: 110.0, child: Text(text)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 15,
                    ),
                    child: Text(":"),
                  ),
                  widgetLocation(value),
                ],
              );
            },
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Luas Min")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _luasMin(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Luas Max")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _luasMax(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Budget Max")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _budgetMax(),
          ],
        ),
        SizedBox(
          height: 30.0,
        ),
        globalMax(),
        Container(width: 110.0, child: Text("Keyword")),
        SizedBox(
          height: 20.0,
        ),
        _listKeyword(),
        SizedBox(
          height: 30.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kTanggalChat)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Text(
              new DateFormat("dd MMM yyyy - hh:mm").format(
                new DateFormat("yyyy-MM-dd").parse(
                  value.request!.date!,
                ),
              ),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Pengirim")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Text(
              value.request!.contact == null
                  ? user != null
                      ? user!.user!.name! + " - Versus"
                      : ""
                  : value.request!.contact!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Divider(
          color: Colors.black87,
        ),
        SizedBox(
          height: 10.0,
        ),
        _text(value),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buttonDetect(),
        ),
        ...splitMode(),
      ],
    );
  }

  Widget globalMax() {
    if (transaction == 0) {
      return Container();
    }

    String title = "";

    if (transaction == 1) {
      title = "Global/m jual max";
    } else if (transaction == 2) {
      title = "Global/m LT sewa max";
    }

    return Column(
      children: [
        Row(
          children: [
            Container(width: 110.0, child: Text(title)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _globalMax(),
          ],
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }

  Column _listKeyword() {
    if (isAdmin(user) || isMarketing(user)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._keyword.map((e) {
            return Container(
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
                                        onDeleted: i == 0
                                            ? null
                                            : () {
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
            );
          }).toList()
        ],
      );
    }

    return Column(
      children: _keyword.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Wrap(
            spacing: 10.0,
            children: e.list!
                .asMap()
                .map(
                  (i, t) => MapEntry(
                      i,
                      ActionChip(
                        onPressed: () {},
                        label: Text(t),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3)),
                      )),
                )
                .values
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buttonDetect() {
    List<Widget> _list = [];

    if (!_isSpliting &&
        !_isPhoneDetect &&
        request != null &&
        request!.id != null) {
      _list.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isPhoneDetect = true;
                });
              },
              child: Text("Detect Phone"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      ));
    }

    if (_isPhoneDetect) {
      _list.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isPhoneDetect = false;
                });
              },
              child: Text("Cancel"),
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      ));
    }

    return _list;
  }

  Widget _text(RequestProvider value) {
    if (_isPhoneDetect) {
      String test = value.request!.chat!;
      RegExp r = new RegExp(
          r'(?:0|62)[\s]?(?:[\d]{9,13}|[\d]{3,4}.?[\d]{3,4}.?[\d]{3,5}|[\d]{2}\.[\d]{3}\.?[\d]{3}\.?[\d]{2,4}|[\d]{2,4}\.[\d]{2,4}\.?[\d]{2,4}|[\d]{2,4}[\s]?[\d]{2,4}[\s]?[\d]{2,4})');
      final match = r.allMatches(test);
      int index = 0;
      int loop = 0;

      List<TextSpan> _list = [];
      TextStyle linkStyle = TextStyle(color: Colors.blue);

      if (match.length == 0) {
        _list.add(TextSpan(text: "No phone detected"));
      }

      match.forEach((element) {
        if (index == element.start) {
          _list.add(TextSpan(
              text: element.group(0),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _clickWa(element.group(0)!);
                }));
        } else {
          _list.add(TextSpan(
              text: value.request!.chat!.substring(index, element.start)));
          _list.add(TextSpan(
              text: element.group(0),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _clickWa(element.group(0)!);
                }));
        }

        index = element.end;
        loop += 1;

        if (loop == match.length && index != value.request!.chat!.length) {
          _list.add(TextSpan(text: value.request!.chat!.substring(index)));
        }
      });

      return RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15.0, height: 1.5, color: Colors.black),
          children: _list,
        ),
      );
    }

    if (!(isStaff(user) || isMarketing(user))) {
      return Text(value.request!.chat ?? "");
    }

    if (_isSpliting) {
      return new SelectableText(
        value.request!.chat!,
        style: TextStyle(fontSize: 15.0, height: 1.5),
        enableInteractiveSelection: _isSpliting,
        toolbarOptions: ToolbarOptions(
            copy: false, selectAll: false, cut: false, paste: false),
        selectionControls: CustomTextSelectionControls(
          header: (start, end) {
            setState(() {
              header = value.request!.chat!.substring(start, end);
            });
          },
          footer: (start, end) {
            setState(() {
              footer = value.request!.chat!.substring(start, end);
            });
          },
          content: (start, end) {
            setState(() {
              content.add(value.request!.chat!.substring(start, end));
            });
          },
        ),
      );
    }

    if (isStaff(user) && value.request!.chat != null) {
      List<String> text = [];
      if (_category.isNotEmpty) {
        List<BuildingTypesModel> types = value.buildingTypes
            .where(
                (element) => element.propertyCategory!.id == _category[0]!.id)
            .toList();

        types.forEach((element) {
          if (element.include != null) {
            List<String> ele1 = element.include!.split("\n");
            ele1.forEach((element2) {
              List<String> ele2 = element2.split(",");
              ele2.forEach((ele) {
                if (!text.contains(ele)) {
                  text.add(ele);
                }
              });
            });
          }
        });
      }

      String test = value.request!.chat!.toLowerCase();
      String pattern = text.join('|');

      RegExp r = RegExp(pattern);
      final match = r.allMatches(test);

      int index = 0;
      int loop = 0;

      List<TextSpan> _list = [];
      TextStyle linkStyle = TextStyle(
        backgroundColor: Colors.yellow,
      );

      if (match.isNotEmpty && _category.isNotEmpty) {
        match.forEach((element) {
          if (index == element.start) {
            _list.add(
              TextSpan(
                text: element.group(0),
                style: linkStyle,
              ),
            );
          } else {
            _list.add(TextSpan(
                text: value.request!.chat!.substring(index, element.start)));
            _list.add(
              TextSpan(
                text: element.group(0),
                style: linkStyle,
              ),
            );
          }

          index = element.end;
          loop += 1;

          if (loop == match.length && index != value.request!.chat!.length) {
            _list.add(TextSpan(text: value.request!.chat!.substring(index)));
          }
        });

        return RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15.0, height: 1.5, color: Colors.black),
            children: _list,
          ),
        );
      } else {
        return Text(
          value.request!.chat!,
          style: TextStyle(fontSize: 15.0, height: 1.5),
        );
        // _list.add(TextSpan(text: value.request.request));
      }
    }

    return TextField(
      controller: _chatController,
      style: TextStyle(fontSize: 15.0, height: 1.5),
      maxLines: null,
      decoration: InputDecoration(contentPadding: EdgeInsets.only(bottom: 10)),
    );
  }

  _clickWa(String text) async {
    String temp = text.replaceAll(RegExp(r'[^\d ]+'), "");
    temp = temp.replaceAll(" ", "");
    if (temp.substring(0, 1) == "0") {
      temp = "62" + temp.substring(1);
    }
    await launch("https://wa.me/" + temp);
  }

  List<Widget> splitMode() {
    if (!_isSpliting) {
      return [];
    }
    return [
      SizedBox(
        height: 10.0,
      ),
      Divider(
        color: Colors.black87,
        thickness: 5.0,
      ),
      SizedBox(
        height: 10.0,
      ),
      Visibility(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Header',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      header = null;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(header == null ? "" : header!),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
        visible: header != null,
      ),
      ...content.map((e) {
        // ignore: sdk_version_ui_as_code
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Content ${content.indexOf(e) + 1}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      content.remove(e);
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(e),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        );
      }).toList(),
      Visibility(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Footer",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      footer = null;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(footer == null ? "" : footer!),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
        visible: footer != null,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isSpliting = false;
                  header = null;
                  footer = null;
                  content.clear();
                });
              },
              child: Text("Cancel"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          Material(
            child: MaterialButton(
              onPressed: () {
                if (content.length > 0) {
                  showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                            title: Text("Split Confirmation"),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new Text(
                                  'Are you sure want to split this request?'),
                            ),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("OK"),
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _loading = true;
                                  });

                                  RequestProvider provider =
                                      Provider.of<RequestProvider>(context,
                                          listen: false);
                                  for (var request in content) {
                                    String temp = "";
                                    if (header != null) {
                                      temp += header! + "\n\n";
                                    }
                                    temp += request;
                                    if (footer != null) {
                                      temp += "\n\n" + footer!;
                                    }
                                    await provider.addRequest(temp);
                                  }

                                  await provider
                                      .deleteRequest([provider.request]);
                                  Navigator.of(this.context).pop();

                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Split success"),
                                  ));
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
                  showMessage(_scaffoldKey as GlobalKey<ScaffoldState>,
                      "Content masih kosong");
                }
              },
              child: Text("Save"),
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    ];
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

  List<Widget> _trailing() {
    RequestProvider provider = Provider.of(context, listen: false);

    return [
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              if (provider.request!.chat?.isNotEmpty ?? false) {
                Clipboard.setData(
                  ClipboardData(
                    text: provider.request!.chat!,
                  ),
                );

                Toast.show("Text copied to clipboard");
              }
            },
            child: Icon(
              Icons.copy,
              color: Colors.black,
            ),
          ),
        ),
        visible: provider.request != null && provider.request!.id != null,
      ),
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              _save(_param());
            },
            child: Icon(
              Icons.check,
              color: Colors.black,
            ),
          ),
        ),
        visible: (isAdmin(user) || isMarketing(user)) && !_isSpliting,
      )
    ];
  }

  Widget _fab() {
    if (!_isSpliting && !_isFiltering) {
      List<Bubble> bubble = [
        Bubble(
          title: "Filter All",
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          icon: Icons.filter_list_outlined,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            setState(() {
              if (_filterUI == null) {
                _filterUI = FilterUI(
                  requestModel: request,
                );
              }
              _isFiltering = true;
            });
          },
        ),
        Bubble(
          title: "Filter Transaksi & Lokasi",
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          icon: Icons.filter_list_outlined,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            setState(() {
              if (_filterUI == null) {
                _filterUI = FilterUI(
                  requestModel: request,
                  onlyTransactionsLocations: true,
                );
              }
              _isFiltering = true;
            });
          },
        ),
      ];

      if (isAdmin(user) || isMarketing(user)) {
        bubble.insert(
          0,
          Bubble(
            title: "Split",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.call_split,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              setState(() {
                _isSpliting = true;
                _isPhoneDetect = false;
              });
              _animationController.reverse();
            },
          ),
        );

        List<Bubble> report = [
          Bubble(
            title: "Belum dikerjakan",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text('Ubah status jadi belum dikerjakan?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _animationController.reverse();
                              _save({"request": true, "hasil": null});
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
            },
          ),
          Bubble(
            title: "Bukan request",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
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
                              _animationController.reverse();
                              _save({"request": false, "hasil": 0});
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
            },
          ),
          Bubble(
            title: "Ada listing Versus yang sesuai",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text('Ada listing Versus yang sesuai?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _animationController.reverse();
                              _save({"request": false, "hasil": 1});
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
            },
          ),
          Bubble(
            title: "Hanya lokasi yang sesuai tapi isi request tidak sesuai",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                              'Hanya lokasi yang sesuai tapi isi request tidak sesuai?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _animationController.reverse();
                              _save({"request": false, "hasil": 2});
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
            },
          ),
          Bubble(
            title: "Tidak ada listing Versus yang sesuai",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              new Text('Tidak ada listing Versus yang sesuai?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _animationController.reverse();
                              _save({"request": false, "hasil": 3});
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
            },
          ),
          Bubble(
            title: "Request kembar dengan sebelumnya",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.cancel_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text('Request kembar dengan sebelumnya?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _animationController.reverse();
                              _save({"request": false, "hasil": 4});
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
            },
          )
        ];

        if (request!.hasil! >= 0) {
          report.removeAt(request!.hasil! + 1);
        } else {
          report.removeAt(0);
        }

        bubble.insertAll(0, report);
      }

      return FloatingActionBubble(
        // Menu items
        items: bubble,

        // animation controller
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),

        // Floating Action button Icon color
        iconColor: Colors.blue,

        // Flaoting Action button Icon
        iconData: Icons.settings,
        backGroundColor: Colors.white,
      );
    } else if (_isFiltering) {
      return FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFiltering = false;
          });
        },
        child: Icon(
          Icons.cancel,
          size: 28,
        ),
        backgroundColor: Colors.red,
      );
    } else {
      return Container();
    }
  }

  void save() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void saveCallback() {
    showMessage(_scaffoldKey as GlobalKey<ScaffoldState>, "Note updated");
  }

  void _save(Map<String, dynamic> param) async {
    setState(() {
      _loading = true;
    });

    RequestProvider provider =
        Provider.of<RequestProvider>(context, listen: false);

    provider.editRequest(param: param, request: request).then((value) {
      setState(() {
        _loading = false;
        bool pop = false;

        if (param.containsKey("request") && param.containsKey("hasil")) {
          pop = true;
          Navigator.of(context).pop();
        }

        this.request = value;
        if (_filterUI != null) {
          _filterUI!.refreshCallback(request);
        }

        if (!pop) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Update success"),
          ));
          setState(() {});
        }
      });
    });
  }

  Map<String, dynamic> _param() {
    Map<String, dynamic> res = {};

    List<Param> _par = [];
    _par.add(new Param("chat", _chatController.text));
    _par.add(new Param("keyword", _keyword.first.list));

    if (_category.length == 0) {
      _par.add(new Param("property_categories", null));
    } else {
      _par.add(new Param(
          "property_categories", _category.map((e) => e!.id).toList()));
    }

    if (filterLocation != null && filterLocation != 0) {
      if (_location.length == 0) {
        _par.add(new Param("specific_locations", null));
        _par.add(new Param("areas", null));
        _par.add(new Param("sub_areas", null));
      } else {
        if (filterLocation == 1) {
          _par.add(new Param("areas", _location.map((e) => e!.id).toList()));
          _par.add(new Param("specific_locations", null));

          _par.add(new Param("sub_areas", null));
        } else if (filterLocation == 2) {
          _par.add(
              new Param("sub_areas", _location.map((e) => e!.id).toList()));
          _par.add(new Param("specific_locations", null));
          _par.add(new Param("areas", null));
        } else if (filterLocation == 3) {
          _par.add(new Param(
              "specific_locations", _location.map((e) => e!.id).toList()));

          _par.add(new Param("areas", null));
          _par.add(new Param("sub_areas", null));
        }
      }
    }

    if (_buildingType.length == 0) {
      _par.add(new Param("building_types", null));
    } else {
      _par.add(new Param(
          "building_types", _buildingType.map((e) => e!.id).toList()));
    }

    _par.add(
      new Param("TransactionTypeID", transaction.toString()),
    );

    _par.add(
      new Param("filter_category", filterCategory),
    );
    _par.add(
      new Param("filter_location", filterLocation),
    );

    _par.add(
      new Param(
          "luas_min", luasMin!.isNotEmpty ? double.parse(luasMin!) : null),
    );

    _par.add(
      new Param(
          "luas_max", luasMax!.isNotEmpty ? double.parse(luasMax!) : null),
    );

    _par.add(
      new Param("budget_max", budgetMax),
    );

    _par.add(new Param("global", global));

    if (Provider.of<RequestProvider>(context, listen: false).request!.id ==
        null) {
      _par.add(new Param("date", new DateTime.now().toIso8601String()));
      _par.add(new Param("contact", user!.user!.name! + " - Versus"));
    }

    _par.forEach((element) {
      if (element.value == null ||
          ((element is String) && element.value.isEmpty)) {
        res[element.key] = null;
      } else {
        res[element.key] = element.value;
      }
    });

    print(res);

    return res;
  }

  setCategory() {
    if (filterCategory == 1) {
      RequestProvider requestProvider =
          Provider.of<RequestProvider>(context, listen: false);
      List<SelectAbleModel?> temp = [];
      for (int i = 0; i < _category.length; i++) {
        BuildingTypesModel? building = requestProvider.buildingTypes
            .firstWhereOrNull(
                (element) => element.propertyCategory!.id == _category[i]!.id);
        if (building != null) {
          temp.add(_category[i]);
        }
      }
      _category.clear();
      _category.addAll(temp);
    }
  }

  setBuilding() {
    if (filterCategory == 0) {
      _buildingType.clear();
    } else if (filterCategory == 1) {
      RequestProvider requestProvider =
          Provider.of<RequestProvider>(context, listen: false);
      List<SelectAbleModel?> temp = [];
      for (int i = 0; i < _buildingType.length; i++) {
        BuildingTypesModel? building = requestProvider.buildingTypes
            .firstWhereOrNull((element) => element.id == _buildingType[i]!.id);
        if (building != null) {
          bool found = _category.firstWhere(
                  (element) => element!.id == building.propertyCategory!.id) !=
              null;
          if (found) {
            temp.add(_category[i]);
          }
        }
      }
      _buildingType.clear();
      _buildingType.addAll(temp);
    }
  }

  @override
  void dispose() {
    if (_isNew) {
      requestProvider.clear();
    }
    filterProvider.doneInit = false;
    requestProvider.request = null;
    super.dispose();
  }
}

class Param {
  String key;
  dynamic value;

  Param(this.key, this.value);
}
