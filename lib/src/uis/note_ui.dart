import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:after_layout/after_layout.dart';
import 'package:badges/badges.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:provider/provider.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_filter_chip.dart';
import 'package:versus/src/components/custom_sliver.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/city_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/request_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/resources/popup_card.dart';

class NoteUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NoteUI>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin {
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
    kKeywordLower: [
      {kKeywordLower: <String>[], kSpaceLower: false},
    ],
    kOnlyNew: null,
    kOnlyRequest: null,
    kOnlyMulti: null,
    kCheckLower: null,
    kTagsLower: <SelectAbleModel>[],
    kAdminLower: false,
    kDateLower: [null, null],
    kCombinationLower: [],
    kFilterKategoriLower: 0,
    kIdLower: [0, 0],
    kLelangMinusLower: [0, 1, 2],
  };

  late NoteProvider noteProvider;
  String searchQuery = "";
  bool _deleteMode = false;
  bool _isDeleting = false;
  List<ChatModel?> _listDelete = [];
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
    count += (_data[kIdLower] as List<int?>).elementAt(0) != 0 ? 1 : 0;
    count += (_data[kIdLower] as List<int?>).elementAt(1) != 0 ? 1 : 0;
    count += (_data[kTagsLower] as List<SelectAbleModel?>).length > 0 ? 1 : 0;

    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(0) != null
        ? 1
        : 0;
    count += !(_data[kDateLower] is List<Null>) &&
            (_data[kDateLower] as List<String?>).elementAt(1) != null
        ? 1
        : 0;
    count += _data[kLelangMinusLower].length < 3 ? 1 : 0;
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

    count += _data[kKeywordLower].length > 0 &&
            _data[kKeywordLower][0][kKeywordLower].length > 0
        ? 1
        : 0;

    count += _data[kOnlyNew] != null ? 1 : 0;
    count += _data[kCheckLower] != null ? 1 : 0;

    if (isStaff(user)) {
      count += _data[kOnlyRequest] != null ? 1 : 0;
      count += _data[kOnlyMulti] != null ? 1 : 0;
    } else {
      count += _data[kOnlyRequest] != false ? 1 : 0;
      count += _data[kOnlyMulti] != false ? 1 : 0;
    }

    return count;
  }

  @override
  void initState() {
    super.initState();
    noteProvider = Provider.of<NoteProvider>(context, listen: false);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    MainProvider().getMember().then((value) {
      setState(() {
        user = value;
        _data[kAdminLower] = isAdmin(user);
        if (isMarketing(user)) {
          _data[kKeywordLower] = [
            ["vslst"]
          ];
          _data[kCombinationLower] = [
            [
              {
                "type": "Keyword",
                "value": "vslst",
              }
            ]
          ];
        }
        if (!isStaff(user)) {
          _data[kOnlyRequest] = false;
          _data[kOnlyMulti] = false;
        }

        Provider.of<NoteProvider>(context, listen: false)
            .newData(param: _param(_data));
      });

      _scrollController.addListener(() {
        if (_scrollController.position.atEdge && _scrollController.offset > 0) {
          Provider.of<NoteProvider>(context, listen: false).scrollData(
              param: noteProvider.selectedFilter != null
                  ? noteProvider.selectedFilter!.data
                  : _param(_data));
        }
      });
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Consumer<NoteProvider>(
          builder: (context, value, child) {
            return Scaffold(
              backgroundColor: Colors.white,
              /*appBar: CustomAppBar(
            leading: _deleteMode
                ? BackButton(
                    onPressed: () {
                      setState(() {
                        _listDelete.clear();
                        _deleteMode = false;
                      });
                    },
                  )
                : null,
            customTitle: Text(
              "Chat",
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            ),
            action: _buildActions(),
          ),*/
              body: _body(),
              floatingActionButton: noteProvider.selectedFilter != null
                  ? FloatingActionButton(
                      onPressed: () {
                        noteProvider.selectedFilter = null;
                        noteProvider.data!.clear();
                        noteProvider.newData(param: _param(_data));
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

                                    Provider.of<NoteProvider>(context,
                                            listen: false)
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
                    ),
              drawer: _drawer(),
              drawerEnableOpenDragGesture: false,
            );
          },
        ),
        Visibility(
            visible: _isDeleting,
            child: Container(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ))
      ],
    );
  }

  Widget _drawer() {
    List<Widget> widgets = [
      UserAccountsDrawerHeader(
        accountName: Text(userModel!.user!.name!),
        accountEmail: Text(userModel!.user!.email!),
        currentAccountPicture: CircleAvatar(
          child: Text(
            userModel!.user!.name!.substring(0, 1),
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ),
      ListTile(
        title: Text(
          'List Tag',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          Provider.of<NoteProvider>(context, listen: false)
              .getTag()
              .then((value) async {
            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: value.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                    id: e.id, title: e.name, trailing: e.chat.toString());
                return selectModel;
              }).toList(),
              selected: [],
              title: "Search tag by name",
              add: add(),
              detail: (_) => detail(_),
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'Add Chat',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          NoteProvider note = Provider.of<NoteProvider>(context, listen: false);
          note.chat = new ChatModel();
          Navigator.of(context).pushNamed(kRouteNoteAdd);
        },
      ),
      ListTile(
        title: Text(
          'Add Request',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          RequestProvider provider =
              Provider.of<RequestProvider>(context, listen: false);
          provider.request = new RequestModel();
          Navigator.of(context).pushNamed(kRouteRequestAdd);
        },
      ),
      ListTile(
        title: Text(
          'List Kota',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          Provider.of<NoteProvider>(context, listen: false)
              .getCity()
              .then((value) async {
            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: value.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                    id: e.id,
                    title: e.title,
                    trailing:
                        e.areas != null ? e.areas!.length.toString() : "0");
                return selectModel;
              }).toList(),
              selected: [],
              title: "Search city by name",
              add: addCity(),
              detail: (_) => detailCity(_),
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'List Area',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          Provider.of<NoteProvider>(context, listen: false)
              .getArea()
              .then((value) async {
            List<CityModel> city =
                await Provider.of<NoteProvider>(context, listen: false)
                    .getCity();

            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: value.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                    id: e.id,
                    title: e.title,
                    subtitle: e.city != null ? e.city!.title : "",
                    optional: {"parent": e.city ?? null},
                    trailing: e.subAreas != null
                        ? e.subAreas!.length.toString()
                        : "0");
                return selectModel;
              }).toList(),
              selected: [],
              title: "Search area by name",
              add: addArea(city),
              detail: (_) => detailArea(_, city),
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'List Sub Area',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          Provider.of<NoteProvider>(context, listen: false)
              .getSubarea()
              .then((value) async {
            List<AreaModel> area =
                await Provider.of<NoteProvider>(context, listen: false)
                    .getArea();

            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: value.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                    id: e.id,
                    title: e.title,
                    subtitle: e.area != null ? e.area!.title : "",
                    optional: {"parent": e.area ?? null},
                    trailing: e.specificLocations != null
                        ? e.specificLocations!.length.toString()
                        : "0");
                return selectModel;
              }).toList(),
              selected: [],
              title: "Search sub area by name",
              add: addSubArea(area),
              detail: (_) => detailSubArea(_, area),
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'List Lokasi',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          Provider.of<NoteProvider>(context, listen: false)
              .getLokasiSpesifik()
              .then((value) async {
            List<SubAreaModel> sub =
                await Provider.of<NoteProvider>(context, listen: false)
                    .getSubarea();

            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: value.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                    id: e.id,
                    title: e.lokasiSpesifikName,
                    subtitle: subtitleLokasi(e),
                    optional: {"parent": e.subArea ?? null},
                    trailing: e.properties.toString());
                return selectModel;
              }).toList(),
              selected: [],
              title: "Search location by name",
              add: addLokasi(sub),
              detail: (_) => detailLokasi(_, sub),
              withId: true,
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'List Filter',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          //List<TagModel> _list = [];
          showDialog(
            context: context,
            builder: (context) {
              return Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
          noteProvider.getFilter().then((_) async {
            Navigator.of(context).pop();

            Provider.of<SelectMasterProvider>(context, listen: false).setData(
              selectAbleModel: noteProvider.savedFilter.map((e) {
                SelectAbleModel selectModel = new SelectAbleModel(
                  id: e.id,
                  title: e.title,
                );
                return selectModel;
              }).toList(),
              selected: [],
              detail: (_) => detailFilter(_),
              title: "Search filter by name",
            );

            await Navigator.of(context).pushNamed(kRouteFriendAdd);
          });
        },
      ),
      ListTile(
        title: Text(
          'List Archive',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () async {
          NoteProvider note = Provider.of<NoteProvider>(context, listen: false);
          note.archive = true;
          await Navigator.of(context).pushNamed(kRouteArchive);
        },
      ),
      ListTile(
        title: Text(
          'List Request',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).pushNamed(kRouteRequest);
        },
      ),
      ListTile(
        title: Text(
          'List Testing',
          style: TextStyle(color: Colors.black87),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () async {
          NoteProvider note = Provider.of<NoteProvider>(context, listen: false);
          note.testing = true;
          await Navigator.of(context).pushNamed(kRouteTesting);
        },
      ),
    ];

    if (isAdmin(user)) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: widgets,
        ),
      );
    }

    if (isStaff(user)) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [widgets[0], widgets[8], widgets[10]],
        ),
      );
    }

    if (isMarketing(user)) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [widgets[0], widgets[3], widgets[8], widgets[10]],
        ),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          widgets[0],
          widgets[8],
        ],
      ),
    );
  }

  String? subtitleLokasi(SpecificLocationModel e) {
    String subtitle = "";

    if (e.subArea != null) {
      subtitle = e.subArea!.title!;

      if (e.subArea!.area != null) {
        subtitle += " - " + e.subArea!.area!.title!;

        if (e.subArea!.area!.city != null) {
          subtitle += " - " + e.subArea!.area!.city!.title!;
        }
      }
    }

    return subtitle;
  }

  String? subtitleSubArea(SubAreaModel e) {
    String subtitle = "";

    if (e.area != null) {
      subtitle = e.area!.title!;

      if (e.area!.city != null) {
        subtitle += " - " + e.area!.city!.title!;
      }
    }

    return subtitle;
  }

  PopUpItem add() {
    TextEditingController controller = TextEditingController();
    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: 'add',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Tag name',
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 0.2,
            ),
            TextButton(
              onPressed: () {
                Provider.of<SelectMasterProvider>(context, listen: false)
                    .addMaster(
                        url: kTagUrl,
                        param: {
                          "name": controller.text,
                          "color": (math.Random().nextDouble() * 0xFFFFFF)
                              .toInt()
                              .toRadixString(16)
                        },
                        callback: (value) {
                          controller.clear();
                          TagModel e = TagModel.fromJson(value);
                          SelectAbleModel selectModel = new SelectAbleModel(
                              id: e.id,
                              title: e.name,
                              trailing: e.chat.toString());
                          return selectModel;
                        });
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  PopUpItem addCity() {
    TextEditingController controller = TextEditingController();
    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: 'add',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'City name', //ubah
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 0.2,
            ),
            TextButton(
              onPressed: () {
                Provider.of<SelectMasterProvider>(context, listen: false)
                    .addMaster(
                        url: kCityUrl, //ubah
                        param: {
                          //ubah
                          "Title": controller.text,
                        },
                        callback: (value) {
                          controller.clear();
                          CityModel e = CityModel.fromJson(value); //ubah
                          SelectAbleModel selectModel = new SelectAbleModel(
                              id: e.id, title: e.title, trailing: "0");
                          return selectModel;
                        });
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  PopUpItem addArea(List<CityModel> city) {
    TextEditingController controller = TextEditingController();
    CityModel? selected;
    bool error = false;

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: 'add',
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<CityModel>(
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title!;
                        },
                        optionsBuilder: (textEditing) {
                          List<CityModel> res = city
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'City name', //ubah
                              errorText: error ? 'Pilih kota' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Area name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                TextButton(
                  onPressed: () {
                    if (selected == null) {
                      setState(() {
                        error = true;
                      });
                    } else {
                      Provider.of<SelectMasterProvider>(context, listen: false)
                          .addMaster(
                              url: kAreaUrl, //ubah
                              param: {
                                //ubah
                                "Title": controller.text,
                                "city": selected!.id //ubah
                              },
                              callback: (value) {
                                controller.clear();
                                AreaModel e = AreaModel.fromJson(value); //ubah
                                SelectAbleModel selectModel =
                                    new SelectAbleModel(
                                        id: e.id,
                                        title: e.title,
                                        subtitle: e.city!.title,
                                        optional: {"parent": e.city ?? null},
                                        trailing: "0");
                                return selectModel;
                              });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem addSubArea(List<AreaModel> area) {
    TextEditingController controller = TextEditingController();
    AreaModel? selected; //ubah
    bool error = false;

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: 'add',
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<AreaModel>(
                        //ubah
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title!;
                        },
                        optionsBuilder: (textEditing) {
                          List<AreaModel> res = area //ubah
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                        subtitle: Text(
                                            options.elementAt(index).city !=
                                                    null
                                                ? options
                                                    .elementAt(index)
                                                    .city!
                                                    .title!
                                                : ""),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Area name', //ubah
                              errorText: error ? 'Pilih area' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Sub area name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                TextButton(
                  onPressed: () {
                    if (selected == null) {
                      setState(() {
                        error = true;
                      });
                    } else {
                      Provider.of<SelectMasterProvider>(context, listen: false)
                          .addMaster(
                              url: kSubAreaUrl, //ubah
                              param: {
                                //ubah
                                "Title": controller.text,
                                "area": selected!.id //ubah
                              },
                              callback: (value) {
                                controller.clear();
                                SubAreaModel e =
                                    SubAreaModel.fromJson(value); //ubah
                                SelectAbleModel selectModel =
                                    new SelectAbleModel(
                                        id: e.id,
                                        title: e.title,
                                        subtitle: e.area!.title,
                                        optional: {"parent": e.area ?? null},
                                        trailing: "0");
                                return selectModel;
                              });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem addLokasi(List<SubAreaModel> sub) {
    TextEditingController controller = TextEditingController();
    SubAreaModel? selected; //ubah
    bool error = false;

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: 'add',
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<SubAreaModel>(
                        //ubah
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title! +
                              " - " +
                              subtitleSubArea(option)!;
                        },
                        optionsBuilder: (textEditing) {
                          List<SubAreaModel> res = sub //ubah
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                        subtitle: Text(subtitleSubArea(
                                            options.elementAt(index))!),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Sub Area name', //ubah
                              errorText: error ? 'Pilih sub area' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Location name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                TextButton(
                  onPressed: () {
                    if (selected == null) {
                      setState(() {
                        error = true;
                      });
                    } else {
                      Provider.of<SelectMasterProvider>(context, listen: false)
                          .addMaster(
                              url: kSpecificLocationUrl, //ubah
                              param: {
                                //ubah
                                "LokasiSpesifikName": controller.text,
                                "sub_area": selected!.id //ubah
                              },
                              callback: (value) {
                                controller.clear();

                                SpecificLocationModel e =
                                    SpecificLocationModel.fromJson(
                                        value); //ubah

                                SelectAbleModel selectModel =
                                    new SelectAbleModel(
                                        id: e.id,
                                        title: e.lokasiSpesifikName,
                                        subtitle: selected!.title! +
                                            " - " +
                                            subtitleSubArea(selected!)!,
                                        optional: {"parent": e.subArea ?? null},
                                        trailing: "0");
                                e.selectAbleModel = new SelectAbleModel(
                                  id: e.id,
                                  title: e.lokasiSpesifikName,
                                  subtitle: selected!.title! +
                                      " - " +
                                      subtitleSubArea(selected!)!,
                                );
                                noteProvider.location.add(e);
                                return selectModel;
                              });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem detail(SelectAbleModel model) {
    TextEditingController controller = TextEditingController(text: model.title);
    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Tag name',
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 0.2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<SelectMasterProvider>(context, listen: false)
                        .updateMaster(
                            url: kTagUrl + model.id.toString(),
                            param: {
                              "name": controller.text,
                            },
                            id: model.id,
                            callback: (value) {
                              controller.clear();
                              TagModel e = TagModel.fromJson(value);
                              SelectAbleModel selectModel = new SelectAbleModel(
                                  id: e.id,
                                  title: e.name,
                                  trailing: e.chat.toString());
                              return selectModel;
                            });
                  },
                  child: const Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<SelectMasterProvider>(context, listen: false)
                        .deleteMaster(
                      url: kTagUrl + model.id.toString(),
                      id: model.id,
                    );
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  PopUpItem detailCity(SelectAbleModel model) {
    TextEditingController controller = TextEditingController(text: model.title);
    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'City name', //ubah
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 0.2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<SelectMasterProvider>(context, listen: false)
                        .updateMaster(
                            url: kCityUrl + model.id.toString(), //ubah
                            param: {
                              //ubah
                              "Title": controller.text,
                            },
                            id: model.id,
                            callback: (value) {
                              controller.clear();
                              CityModel e = CityModel.fromJson(value); //ubah
                              SelectAbleModel selectModel = new SelectAbleModel(
                                  id: e.id,
                                  title: e.title,
                                  trailing: model.trailing);
                              return selectModel;
                            });
                  },
                  child: const Text('Update'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<SelectMasterProvider>(context, listen: false)
                        .deleteMaster(
                      url: kCityUrl + model.id.toString(), //ubah
                      id: model.id,
                    );
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  PopUpItem detailArea(SelectAbleModel model, List<CityModel> city) {
    TextEditingController controller = TextEditingController(text: model.title);
    CityModel? selected;
    bool error = false;

    if (model.optional != null && model.optional["parent"] != null) {
      selected = model.optional["parent"];
    }

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<CityModel>(
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title!;
                        },
                        optionsBuilder: (textEditing) {
                          List<CityModel> res = city
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          textEditingController.text = model.subtitle!;
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'City name', //ubah
                              errorText: error ? 'Pilih kota' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Area name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (selected == null) {
                          setState(() {
                            error = true;
                          });
                        } else {
                          Provider.of<SelectMasterProvider>(context,
                                  listen: false)
                              .updateMaster(
                                  url: kAreaUrl + model.id.toString(), //ubah
                                  param: {
                                    //ubah
                                    "Title": controller.text,
                                    "city": selected!.id //ubah
                                  },
                                  id: model.id,
                                  callback: (value) {
                                    controller.clear();
                                    AreaModel e =
                                        AreaModel.fromJson(value); //ubah
                                    SelectAbleModel selectModel =
                                        new SelectAbleModel(
                                            id: e.id,
                                            title: e.title,
                                            subtitle: e.city!.title,
                                            optional: {
                                              "parent": e.city ?? null
                                            },
                                            trailing: model.trailing);
                                    return selectModel;
                                  });
                        }
                      },
                      child: const Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SelectMasterProvider>(context,
                                listen: false)
                            .deleteMaster(
                          url: kAreaUrl + model.id.toString(), //ubah
                          id: model.id,
                        );
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem detailSubArea(SelectAbleModel model, List<AreaModel> area) {
    //ubah
    TextEditingController controller = TextEditingController(text: model.title);
    AreaModel? selected; //ubah
    bool error = false;

    if (model.optional != null && model.optional["parent"] != null) {
      selected = model.optional["parent"];
    }

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<AreaModel>(
                        //ubah
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title!;
                        },
                        optionsBuilder: (textEditing) {
                          List<AreaModel> res = area //ubah
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                        subtitle: Text(
                                            options.elementAt(index).city !=
                                                    null
                                                ? options
                                                    .elementAt(index)
                                                    .city!
                                                    .title!
                                                : ""),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          textEditingController.text = model.subtitle!;
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Area name', //ubah
                              errorText: error ? 'Pilih area' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Sub Area name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (selected == null) {
                          setState(() {
                            error = true;
                          });
                        } else {
                          Provider.of<SelectMasterProvider>(context,
                                  listen: false)
                              .updateMaster(
                                  url: kSubAreaUrl + model.id.toString(), //ubah
                                  param: {
                                    //ubah
                                    "Title": controller.text,
                                    "area": selected!.id //ubah
                                  },
                                  id: model.id,
                                  callback: (value) {
                                    controller.clear();
                                    SubAreaModel e =
                                        SubAreaModel.fromJson(value); //ubah
                                    SelectAbleModel selectModel =
                                        new SelectAbleModel(
                                            id: e.id,
                                            title: e.title,
                                            subtitle: e.area!.title,
                                            optional: {
                                              "parent": e.area ?? null
                                            },
                                            trailing: model.trailing);
                                    return selectModel;
                                  });
                        }
                      },
                      child: const Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SelectMasterProvider>(context,
                                listen: false)
                            .deleteMaster(
                          url: kSubAreaUrl + model.id.toString(), //ubah
                          id: model.id,
                        );
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem detailLokasi(SelectAbleModel model, List<SubAreaModel> sub) {
    //ubah
    TextEditingController controller = TextEditingController(text: model.title);
    SubAreaModel? selected; //ubah
    bool error = false;

    if (model.optional != null && model.optional["parent"] != null) {
      selected = model.optional["parent"];
    }

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<SubAreaModel>(
                        //ubah
                        onSelected: (model) {
                          selected = model;
                        },
                        displayStringForOption: (option) {
                          return option.title! +
                              " - " +
                              subtitleSubArea(option)!;
                        },
                        optionsBuilder: (textEditing) {
                          List<SubAreaModel> res = sub //ubah
                              .where((element) => element.title!
                                  .toLowerCase()
                                  .contains(textEditing.text.toLowerCase()))
                              .toList();
                          return res;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                        child: Container(
                                      width: constraints.maxWidth,
                                      child: ListTile(
                                        onTap: () {
                                          onSelected(options.elementAt(index));
                                        },
                                        title: Text(
                                            options.elementAt(index).title!),
                                        subtitle: Text(subtitleSubArea(
                                            options.elementAt(index))!),
                                      ),
                                    )),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          textEditingController.text = model.subtitle!;
                          return TextField(
                            onChanged: (_) {
                              if (selected != null) {
                                selected = null;
                              }
                            },
                            controller: textEditingController,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Sub area name', //ubah
                              errorText: error ? 'Pilih sub area' : null, //ubah
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Location name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (selected == null) {
                          setState(() {
                            error = true;
                          });
                        } else {
                          Provider.of<SelectMasterProvider>(context,
                                  listen: false)
                              .updateMaster(
                                  url: kSpecificLocationUrl +
                                      model.id.toString(), //ubah
                                  param: {
                                    //ubah
                                    "LokasiSpesifikName": controller.text,
                                    "sub_area": selected!.id //ubah
                                  },
                                  id: model.id,
                                  callback: (value) {
                                    controller.clear();
                                    SpecificLocationModel e =
                                        SpecificLocationModel.fromJson(
                                            value); //ubah
                                    SpecificLocationModel? m =
                                        noteProvider.location.firstWhereOrNull(
                                            (element) => element.id == e.id);

                                    SelectAbleModel selectModel =
                                        new SelectAbleModel(
                                            id: e.id,
                                            title: e.lokasiSpesifikName,
                                            subtitle: selected!.title! +
                                                " - " +
                                                subtitleSubArea(selected!)!,
                                            optional: {
                                              "parent": e.subArea ?? null
                                            },
                                            trailing: model.trailing);
                                    e.selectAbleModel = new SelectAbleModel(
                                      id: e.id,
                                      title: e.lokasiSpesifikName,
                                      subtitle: selected!.title! +
                                          " - " +
                                          subtitleSubArea(selected!)!,
                                    );
                                    if (m != null) {
                                      noteProvider.location.remove(m);
                                      noteProvider.location.add(e);
                                    }
                                    return selectModel;
                                  });
                        }
                      },
                      child: const Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SelectMasterProvider>(context,
                                listen: false)
                            .deleteMaster(
                                url: kSpecificLocationUrl +
                                    model.id.toString(), //ubah
                                id: model.id,
                                callback: () {
                                  SpecificLocationModel? m =
                                      noteProvider.location.firstWhereOrNull(
                                          (element) => element.id == model.id);
                                  if (m != null) {
                                    noteProvider.location.remove(m);
                                  }
                                });
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  PopUpItem detailFilter(SelectAbleModel model) {
    //ubah
    TextEditingController controller = TextEditingController(text: model.title);
    bool error = false;

    return PopUpItem(
      padding: EdgeInsets.all(8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 2,
      tag: model.id.toString(),
      child: Center(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Filter name', //ubah
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 0.2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();

                        FilterModel filter = noteProvider.savedFilter
                            .firstWhere((element) => element.id == model.id);
                        noteProvider.selectedFilter = filter;
                        noteProvider.data!.clear();
                        noteProvider.newData(param: filter.data);
                      },
                      child: Text(
                        'Load Filter',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SelectMasterProvider>(context,
                                listen: false)
                            .updateMaster(
                                url: kFilterUrl + model.id.toString(), //ubah
                                param: {
                                  //ubah
                                  "title": controller.text,
                                },
                                id: model.id,
                                callback: (value) {
                                  controller.clear();
                                  FilterModel e =
                                      FilterModel.fromJson(value); //ubah
                                  FilterModel? m = noteProvider.savedFilter
                                      .firstWhereOrNull(
                                          (element) => element.id == e.id);

                                  SelectAbleModel selectModel =
                                      new SelectAbleModel(
                                    id: e.id,
                                    title: e.title,
                                  );

                                  if (m != null) {
                                    noteProvider.savedFilter.remove(m);
                                    noteProvider.savedFilter.add(e);
                                  }
                                  return selectModel;
                                });
                      },
                      child: const Text('Update'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<SelectMasterProvider>(context,
                                listen: false)
                            .deleteMaster(
                                url: kFilterUrl + model.id.toString(), //ubah
                                id: model.id,
                                callback: () {
                                  FilterModel? m = noteProvider.savedFilter
                                      .firstWhereOrNull(
                                          (element) => element.id == model.id);
                                  if (m != null) {
                                    noteProvider.savedFilter.remove(m);
                                  }
                                });
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _param(Map<String, dynamic> _data) {
    print(_data);

    Map<String, dynamic> _temp = {};

    if (sort == 0) {
      _temp[kParamSort] = kSortDateDesc;
    } else if (sort == 4) {
      _temp[kParamSort] = kSortIdAsc;
    } else if (sort == 5) {
      _temp[kParamSort] = kSortUpdateAgentDesc;
      _temp["update_agent_null"] = false;
    } else {
      if ((_data[kTransaksiLower] as List<bool>)
              .indexWhere((element) => element == true) ==
          1) {
        //sewa
        if (sort == 1) {
          _temp[kParamSort] = kSortPerMeterSewaAsc;
          _temp[kPerMeterSewaLower + "_gt"] = 0;
        } else if (sort == 2) {
          _temp[kParamSort] = kSortGlobalSewaAsc;
          _temp[kHargaSewaLower + "_gt"] = 0;
        } else if (sort == 3) {
          _temp[kParamSort] = kSortHargaSewaAsc;
          _temp[kParamHargaSewa + "_gt"] = 0;
        }
      } else {
        //jual
        if (sort == 1) {
          _temp[kParamSort] = kSortPerMeterJualAsc;
          _temp[kPerMeterJualLower + "_gt"] = 0;
        } else if (sort == 2) {
          _temp[kParamSort] = kSortBreakdownJualAsc;
          _temp[kBreakdownJualLower + "_gt"] = 0;
        } else if (sort == 3) {
          _temp[kParamSort] = kSortHargaJualAsc;
          _temp[kParamHargaJual + "_gt"] = 0;
        }
      }
    }

    List<String>? _keyword = [];

    if (_data[kKeywordLower].length > page) {
      _keyword = _data[kKeywordLower][page][kKeywordLower] as List<String>?;
    }

    if (_keyword!.length > 0) {
      _keyword.asMap().forEach((i, element) {
        //_temp['_where[$i][chat_contains]'] = element;
      });
    }
    int chatIndex = 0;
    if (_data[kCombinationLower].length > 0 &&
        _data[kCombinationLower][page].length > 0) {
      List<int> _tag = [];
      int idIndex = 0;
      int posIndex = -1;

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
            chatIndex++;
          } else {
            if (combination['space'] != null && combination['space'] == true) {
              _temp['_where[_or][0][$chatIndex][chat_contains]'] =
                  combination['value'];

              _temp['_where[_or][1][$chatIndex][chat2_contains]'] =
                  combination['value'];
              chatIndex++;
            } else {
              _temp['_where[$chatIndex][chat_contains]'] = combination['value'];
              chatIndex++;
            }
          }
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

    if (!(_data[kDateLower] is List<Null>)) {
      List<String?> _date = _data[kDateLower] as List<String?>;

      if (_date[0] != null) {
        _temp[kDateLower + "_gte"] = _date[0]! + "T00:00:00.000Z";
      }
      if (_date[1] != null) {
        _temp[kDateLower + "_lte"] = _date[1]! + "T23:59:59.000Z";
      }
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

    List<int?> _id = _data[kIdLower] as List<int?>;
    if (_id.elementAt(0) != 0) {
      _temp[kIdLower + "_gte"] = _id.elementAt(0);
    }

    if (_id.elementAt(1) != 0) {
      _temp[kIdLower + "_lte"] = _id.elementAt(1);
    }

    List<int> _lelangMinus = _data[kLelangMinusLower];

    if (_lelangMinus.length == 0) {
      _temp["disabled"] = true;
    }

    if (_lelangMinus.length == 1) {
      if (_lelangMinus[0] == 0) {
        _temp[kLelangLower] = false;
        _temp[kMinusLower] = false;
      } else if (_lelangMinus[0] == 1) {
        _temp[kLelangLower] = true;
      } else if (_lelangMinus[0] == 2) {
        _temp[kMinusLower] = true;
      }
    }

    if (_lelangMinus.length == 2) {
      if (_lelangMinus.contains(0) && _lelangMinus.contains(1)) {
        _temp['_where[_or][$chatIndex][lelang]'] = true;

        chatIndex++;

        _temp["_where[_or][$chatIndex][0][lelang]"] = false;
        _temp["_where[_or][$chatIndex][1][minus]"] = false;
      } else if (_lelangMinus.contains(0) && _lelangMinus.contains(2)) {
        _temp["_where[_or][$chatIndex][minus]"] = true;
        chatIndex++;
        _temp["_where[_or][$chatIndex][0][lelang]"] = false;
        _temp["_where[_or][$chatIndex][1][minus]"] = false;
      } else if (_lelangMinus.contains(1) && _lelangMinus.contains(2)) {
        _temp["_where[_or][$chatIndex][lelang]"] = true;
        chatIndex++;
        _temp["_where[_or][$chatIndex][minus]"] = true;
      }
      chatIndex++;
    }

    if (_data[kOnlyNew] != null) _temp[kOnlyNew] = _data[kOnlyNew];
    if (_data[kOnlyRequest] != null) {
      _temp["request"] = _data[kOnlyRequest];
    }

    if (_data[kOnlyMulti] != null) {
      _temp["multi"] = _data[kOnlyMulti];
    }
    if (_data[kCheckLower] != null) {
      _temp.addAll(jsonDecode(_data[kCheckLower]));
    }

    // List<SelectAbleModel> _tag = _data[kTagsLower] as List<SelectAbleModel>;
    //if (_tag.length > 0) {
    //  _temp[kTagsLower + "_in"] = _tag.map((e) => e.id).toList();
    //}

    return _temp;
  }

  Widget _body() {
    return Consumer<NoteProvider>(
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
                              SizedBox(
                                height: 8,
                              ),
                              Text("Data Baru : " + value.baru.toString())
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
                                        as List<Map<String, dynamic>>)
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
                              Provider.of<NoteProvider>(context, listen: false)
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
                    leading: _deleteMode
                        ? BackButton(
                            onPressed: () {
                              setState(() {
                                _listDelete.clear();
                                _deleteMode = false;
                              });
                            },
                          )
                        : null,
                    customTitle: Text(
                      "Chat",
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
            Provider.of<NoteProvider>(context, listen: false)
                .newData(param: _param(_data));
            return Future.value(true);
          },
        );
      },
    );
  }

  List<Widget> _buildActions() {
    if (_deleteMode) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            if (_listDelete.length > 0) {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: Text("Delete Confirmation"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                              'Are you sure want to delete ${_listDelete.length} selected chat?'),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("OK"),
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _deleteMode = false;
                                _isDeleting = true;
                                Provider.of<NoteProvider>(context,
                                        listen: false)
                                    .deleteChat(_listDelete)
                                    .then((value) {
                                  setState(() {
                                    _isDeleting = false;
                                    _listDelete.clear();
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(SnackBar(
                                      content: Text("Delete success"),
                                    ));
                                  });
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
            }
          },
        ),
      ];
    } else {
      return <Widget>[
        PopupMenuButton<int>(
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
                      'Tanggal Chat Terbaru',
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
              value: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal Update Terbaru',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Visibility(
                    child: Icon(Icons.check),
                    visible: sort == 5,
                  )
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 4,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID Terkecil',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Visibility(
                    child: Icon(Icons.check),
                    visible: sort == 4,
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
                value: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Harga ${(_data[kTransaksiLower] as List<bool>).indexWhere((element) => element == true) == 1 ? "Sewa" : "Jual"}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Visibility(
                      child: Icon(Icons.check),
                      visible: sort == 3,
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
  }

  SliverList _buildList(NoteProvider note) {
    double _radius = 15;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          if (note.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (note.data!.length > 0) {
              return StatefulBuilder(
                builder: (context, setState) {
                  Color update1 = Color(0xff0396ff);
                  Color update2 = Color(0xffabdcff);

                  if (note.data!.elementAt(index)!.updateAgent == null &&
                      isStaff(user)) {
                    update1 = Colors.white;
                    update2 = Colors.white;
                  }

                  if (note.data!.elementAt(index)!.updateAgent != null &&
                      isStaff(user)) {
                    String data = note.data!.elementAt(index)!.updateAgent!;
                    DateTime date = DateTime.parse(data);
                    DateTime now = DateTime.now();
                    DateTime oneMonthAgo =
                        DateTime(now.year, now.month - 1, now.day);
                    if (date.isBefore(oneMonthAgo)) {
                      update1 = Colors.green;
                      update2 = Colors.green[300]!;
                    }
                  }

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
                          onLongPress: () {
                            if (isAdmin(user)) {
                              this.setState(() {
                                _listDelete.add(note.data![index]);
                                _deleteMode = true;
                              });
                            }
                          },
                          onTap: () {
                            if (!_deleteMode) {
                              note.chat = note.data!.elementAt(index);
                              Navigator.of(context).pushNamed(kRouteNoteAdd);
                            } else {
                              setState(() {
                                if (_listDelete.firstWhere(
                                        (element) =>
                                            element == note.data![index],
                                        orElse: () => null) !=
                                    null) {
                                  _listDelete.remove(note.data![index]);
                                } else {
                                  _listDelete.add(note.data![index]);
                                }
                              });
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            Text(
                                              note.data!
                                                  .elementAt(index)!
                                                  .labelNew!,
                                              style: TextStyle(
                                                color: note.data!
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
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Icon(
                                                  Icons.looks_one,
                                                  color: note.data!
                                                                  .elementAt(
                                                                      index)!
                                                                  .updateAgent ==
                                                              null &&
                                                          isStaff(user)
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              visible: note.data!
                                                  .elementAt(index)!
                                                  .check!,
                                            ),
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Icon(
                                                  Icons.looks_two,
                                                  color: note.data!
                                                                  .elementAt(
                                                                      index)!
                                                                  .updateAgent ==
                                                              null &&
                                                          isStaff(user)
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              visible: note.data!
                                                  .elementAt(index)!
                                                  .check2!,
                                            ),
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Icon(
                                                  Icons.looks_3,
                                                  color: note.data!
                                                                  .elementAt(
                                                                      index)!
                                                                  .updateAgent ==
                                                              null &&
                                                          isStaff(user)
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              visible: note.data!
                                                  .elementAt(index)!
                                                  .check3!,
                                            ),
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Icon(
                                                  Icons.warning,
                                                  color: Colors.yellow,
                                                ),
                                              ),
                                              visible: note.data!
                                                      .elementAt(index)!
                                                      .ai ==
                                                  true,
                                            ),
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: note.data!
                                                                    .elementAt(
                                                                        index)!
                                                                    .updateAgent ==
                                                                null &&
                                                            isStaff(user)
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "R",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: note.data!
                                                                        .elementAt(
                                                                            index)!
                                                                        .updateAgent ==
                                                                    null &&
                                                                isStaff(user)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              visible: note.data!
                                                      .elementAt(index)!
                                                      .request ==
                                                  true,
                                            ),
                                            Visibility(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: note.data!
                                                                    .elementAt(
                                                                        index)!
                                                                    .updateAgent ==
                                                                null &&
                                                            isStaff(user)
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "MS",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: note.data!
                                                                        .elementAt(
                                                                            index)!
                                                                        .updateAgent ==
                                                                    null &&
                                                                isStaff(user)
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              visible: note.data!
                                                      .elementAt(index)!
                                                      .multi ==
                                                  true,
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
                                              note.data!
                                                  .elementAt(index)!
                                                  .date!,
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
                                          height: 8.0,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Editor : " +
                                                  (note.data!
                                                          .elementAt(index)!
                                                          .editor
                                                          ?.name ??
                                                      " - "),
                                              style: TextStyle(
                                                color: note.data!
                                                                .elementAt(
                                                                    index)!
                                                                .updateAgent ==
                                                            null &&
                                                        isStaff(user)
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Checker : " +
                                                  (note.data!
                                                          .elementAt(index)!
                                                          .checker
                                                          ?.name ??
                                                      " - "),
                                              style: TextStyle(
                                                color: note.data!
                                                                .elementAt(
                                                                    index)!
                                                                .updateAgent ==
                                                            null &&
                                                        isStaff(user)
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                      borderRadius:
                                          BorderRadius.circular(_radius),
                                      color: Colors.black38,
                                    ),
                                    child: Center(
                                      child: Visibility(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40.0,
                                        ),
                                        visible: _listDelete.firstWhere(
                                                (element) =>
                                                    element ==
                                                    note.data![index],
                                                orElse: () => null) !=
                                            null,
                                      ),
                                    ),
                                  ),
                                ),
                                visible: _deleteMode,
                              )
                            ],
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [update1, update2],
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
                    color: note.data!.elementAt(index)!.updateAgent == null &&
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
        childCount:
            note.data == null || note.data!.length == 0 ? 1 : note.data!.length,
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

class ModalBottomSheet extends StatefulWidget {
  ModalBottomSheet({
    required this.data,
    required this.callback,
    required this.param,
    required this.user,
  });

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
  List<int> _id = [];
  List<int> _hargaJual = [];
  List<int> _hargaSewa = [];
  List<int> _perMeterJual = [];
  List<int> _perMeterSewa = [];
  List<int> _breakdownJual = [];
  List<int> _globalSewa = [];
  List<String?> _date = [];
  List<SelectAbleModel?> _tags = [];
  List<KeywordList> _keyword = [];
  List<List<Map<String, dynamic>>> _combination = [];
  bool? _onlyNew;
  bool? _onlyRequest;
  bool? _onlyMulti;
  String? _check;
  List<int> _lelangMinus = [];
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

  List<TextEditingController> _idController = [];
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
    NoteProvider noteProvider =
        Provider.of<NoteProvider>(context, listen: false);

    _date.addAll(widget.data[kDateLower]);
    _transaksi.addAll(widget.data[kTransaksiLower]);
    _kategori.addAll(widget.data[kPropertyCategoryLower]);
    _lokasi.addAll(widget.data[kLokasiLower]);
    _tipeBangunan.addAll(widget.data[kBuildingTypeLower]);
    _lt.addAll(widget.data[kLtLower]);
    _id.addAll(widget.data[kIdLower]);
    _hargaJual.addAll(widget.data[kHargaJualLower]);
    _hargaSewa.addAll(widget.data[kHargaSewaLower]);
    _perMeterJual.addAll(widget.data[kPerMeterJualLower]);
    _perMeterSewa.addAll(widget.data[kPerMeterSewaLower]);
    _breakdownJual.addAll(widget.data[kBreakdownJualLower]);
    _globalSewa.addAll(widget.data[kGlobalSewaLower]);
    _tags.addAll(widget.data[kTagsLower]);
    (widget.data[kKeywordLower] as List<Map<String, dynamic>>)
        .forEach((element) {
      if (element[kKeywordLower] != null) {
        _keyword.add(new KeywordList(
            list: element[kKeywordLower], includeSpace: element[kSpaceLower]));
      }
    });

    if (isMarketing(widget.user)) {
      if (_keyword.isEmpty) {
        _keyword.add(new KeywordList(list: []));
      }

      _keyword.forEach((element) {
        if (element.list == null) {
          element.list = [];
        }

        if (element.list!.isEmpty || element.list![0] != "vslst") {
          element.list!.insert(0, "vslst");
        }
      });
    }

    _filterKategori = widget.data[kFilterKategoriLower];

    isAdmin = widget.data[kAdminLower];
    _itemSelected = widget.data[kJenisLokasiLower];
    setCategory(noteProvider);
    setDisplay(_itemSelected, noteProvider);
    setBuildingType(noteProvider);

    if (_keyword.length == 0) {
      _keyword.add(new KeywordList(list: [], includeSpace: false));
    }

    _onlyNew = widget.data[kOnlyNew];
    _onlyRequest = widget.data[kOnlyRequest];
    _onlyMulti = widget.data[kOnlyMulti];
    _check = widget.data[kCheckLower];
    _lelangMinus = widget.data[kLelangMinusLower];

    _ltController.add(new MoneyMaskedTextController(
        initialValue: _lt.elementAt(0).toDouble(),
        precision: 0,
        decimalSeparator: ""));
    _ltController.add(new MoneyMaskedTextController(
        initialValue: _lt.elementAt(1).toDouble(),
        precision: 0,
        decimalSeparator: ""));

    _idController.add(
      new TextEditingController(
        text: _id.elementAt(0).toString(),
      ),
    );
    _idController.add(
      new TextEditingController(
        text: _id.elementAt(1).toString(),
      ),
    );

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
        return Consumer<NoteProvider>(
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
                                reset = true;
                                _date = [null, null];
                                _transaksi[0] = false;
                                _transaksi[1] = false;
                                _onlyNew = null;
                                if (isStaff(widget.user)) {
                                  _onlyRequest = null;
                                  _onlyMulti = null;
                                } else {
                                  _onlyRequest = false;
                                  _onlyMulti = false;
                                }

                                _check = null;
                                _lelangMinus = [0, 1, 2];
                                _kategori.clear();
                                _tipeBangunan.clear();
                                _lokasi.clear();

                                _itemSelected = "-";

                                _keyword.clear();
                                if (isMarketing(widget.user)) {
                                  _keyword.add(KeywordList(list: ["vslst"]));
                                } else {}

                                _filterKategori = 0;

                                _lt = [kMinLT, kMaxLT];
                                _id = [0, 0];
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

                                    if (isMarketing(widget.user)) {
                                      _keyword.add(
                                          new KeywordList(list: ["vslst"]));
                                    } else {
                                      _keyword.add(new KeywordList(list: []));
                                    }
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
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Text("Filter Kategori",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
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
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                "ID",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 5 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: _idController.elementAt(0),
                                      onChanged: (_) {
                                        int data = 0;
                                        if (_.length > 0) {
                                          data = int.parse(_);
                                        }
                                        _id[0] = data;
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
                                      controller: _idController.elementAt(1),
                                      onChanged: (_) {
                                        int data = 0;
                                        if (_.length > 0) {
                                          data = int.parse(_);
                                        }
                                        _id[1] = data;
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
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Tampilan New",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
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
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Tampilan Check",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
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
                                    subtitle: Text(
                                        "(terisi transaksi, LT dan harga)"),
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
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Tampilan Request",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Column(
                                children: [
                                  RadioListTile(
                                    value: null,
                                    groupValue: _onlyRequest,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyRequest = _;
                                      });
                                    },
                                    title: Text("Semua"),
                                  ),
                                  RadioListTile(
                                    value: true,
                                    groupValue: _onlyRequest,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyRequest = _;
                                      });
                                    },
                                    title: Text("Hanya Request"),
                                  ),
                                  RadioListTile(
                                    value: false,
                                    groupValue: _onlyRequest,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyRequest = _;
                                      });
                                    },
                                    title: Text("Tanpa Request"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 20 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Tampilan Multi Spec",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Column(
                                children: [
                                  RadioListTile(
                                    value: null,
                                    groupValue: _onlyMulti,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyMulti = _;
                                      });
                                    },
                                    title: Text("Semua"),
                                  ),
                                  RadioListTile(
                                    value: true,
                                    groupValue: _onlyMulti,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyMulti = _;
                                      });
                                    },
                                    title: Text("Hanya Multi Spec"),
                                  ),
                                  RadioListTile(
                                    value: false,
                                    groupValue: _onlyMulti,
                                    onChanged: (dynamic _) {
                                      setState(() {
                                        _onlyMulti = _;
                                      });
                                    },
                                    title: Text("Tanpa Multi Spec"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: isStaff(widget.user) ? 20.0 : 0,
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Lelang Atau Ada Minus",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isStaff(widget.user),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: _lelangMinus.contains(0),
                                    onChanged: (value) {
                                      setState(() {
                                        if (_lelangMinus.contains(0)) {
                                          _lelangMinus.remove(0);
                                        } else {
                                          _lelangMinus.add(0);
                                        }
                                      });
                                    },
                                    title: Text("Normal"),
                                  ),
                                  CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: _lelangMinus.contains(1),
                                    onChanged: (value) {
                                      setState(() {
                                        if (_lelangMinus.contains(1)) {
                                          _lelangMinus.remove(1);
                                        } else {
                                          _lelangMinus.add(1);
                                        }
                                      });
                                    },
                                    title: Text("Lelang / Cassie"),
                                  ),
                                  CheckboxListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: _lelangMinus.contains(2),
                                    onChanged: (value) {
                                      setState(() {
                                        if (_lelangMinus.contains(2)) {
                                          _lelangMinus.remove(2);
                                        } else {
                                          _lelangMinus.add(2);
                                        }
                                      });
                                    },
                                    title: Text("Ada Minus"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
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
                                          Provider.of<NoteProvider>(context,
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
                            height: 20.0,
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
                                                              Provider.of<NoteProvider>(
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
          int index = _keyword.indexOf(e);
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
                  CheckboxListTile(
                    title: Text("Pencarian termasuk ada spasi didalam keyword"),
                    value: e.includeSpace,
                    onChanged: (_) {
                      setState(() {
                        e.setSpace(_!);
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
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
                                        onDeleted:
                                            i == 0 && isMarketing(widget.user)
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

  setCategory(NoteProvider value) {
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

  setBuildingType(NoteProvider value) {
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

  setDisplay(String? item, NoteProvider value) {
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

    List<Map<String, dynamic>> _list = [];

    _keyword.forEach((element) {
      if (element.list!.isNotEmpty) {
        _list.add(
            {kKeywordLower: element.list, kSpaceLower: element.includeSpace});
        if (_tags.length > 0) {
          _tags.forEach((tag) {
            List<Map<String, dynamic>> data = [];
            data.add({
              "type": "Tag",
              "value": tag!.title,
              "id": tag.id.toString(),
              "space": element.includeSpace,
            });
            element.list!.forEach((e) {
              data.add({
                "type": "Keyword",
                "value": e,
                "space": element.includeSpace,
              });
            });
            _combination.add(data);
          });
        } else {
          List<Map<String, dynamic>> data = [];

          element.list!.forEach((e) {
            data.add({
              "type": "Keyword",
              "value": e,
              "space": element.includeSpace,
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
      kIdLower: _id,
      kTagsLower: _tags,
      kHargaJualLower: _hargaJual,
      kHargaSewaLower: _hargaSewa,
      kPerMeterJualLower: _perMeterJual,
      kPerMeterSewaLower: _perMeterSewa,
      kBreakdownJualLower: _breakdownJual,
      kGlobalSewaLower: _globalSewa,
      kKeywordLower: _list,
      kOnlyNew: _onlyNew,
      kOnlyRequest: _onlyRequest,
      kOnlyMulti: _onlyMulti,
      kCheckLower: _check,
      kLelangMinusLower: _lelangMinus,
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
  bool includeSpace = false;

  KeywordList({required List<String> list, bool? includeSpace}) {
    this.controller = new TextEditingController();
    this.list = list;

    if (includeSpace != null) {
      this.includeSpace = includeSpace;
    }
  }

  setSpace(bool includeSpace) {
    this.includeSpace = includeSpace;
  }
}
