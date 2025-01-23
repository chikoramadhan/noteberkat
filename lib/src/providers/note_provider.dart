import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/city_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/photo_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/setting_provider.dart';
import 'package:versus/src/resources/helper.dart';

class NoteProvider extends MainProvider {
  List<ChatModel?>? _data;
  List<ChatModel?>? _dataMerge;
  List<ChatModel>? _kembar;
  bool merge = false;
  Map<String, dynamic>? param = {};
  bool archive = false;
  bool testing = false;

  final List<PropertyCategoryModel> _category = [];
  final List<PropertyCategoryModel> _categoryDisplay = [];
  final List<SpecificLocationModel> _location = [];
  final List<SpecificLocationModel?> _locationDisplay = [];
  final List<BuildingTypesModel> _buildingTypes = [];
  final List<BuildingTypesModel> _buildingTypesDisplay = [];

  final List<AreaModel> _area = [];
  final List<AreaModel?> _areaDisplay = [];

  final List<SubAreaModel> _subArea = [];
  final List<SubAreaModel?> _subAreaDisplay = [];

  List<FilterModel> savedFilter = [];
  FilterModel? _selectedFilter;
  bool isFilterLoaded = false;
  final _maxDisplay = 5;

  int? total = -1;
  int? baru = -1;
  int _current = 0;

  ChatModel? chat;

  bool showSnackbar = false;
  bool loading = false;

  List<ChatModel?>? get data => _data;
  List<ChatModel?>? get dataMerge => _dataMerge;
  List<ChatModel>? get kembar => _kembar;

  set selectedFilter(FilterModel? value) {
    _selectedFilter = value;
    notifyListeners();
  }

  FilterModel? get selectedFilter => _selectedFilter;

  List<PropertyCategoryModel> get categoryDisplay => _categoryDisplay;

  List<SpecificLocationModel?> get locationDisplay => _locationDisplay;

  List<SubAreaModel> get subArea => _subArea;
  List<AreaModel?> get areaDisplay => _areaDisplay;

  List<SubAreaModel?> get subAreaDisplay => _subAreaDisplay;
  List<AreaModel> get area => _area;

  List<PropertyCategoryModel> get category => _category;

  List<SpecificLocationModel> get location => _location;

  List<BuildingTypesModel> get buildingTypes => _buildingTypes;

  List<BuildingTypesModel> get buildingTypesDisplay => _buildingTypesDisplay;

  updateData(List<ChatModel> chat) {
    if (!merge) {
      if (_data == null) {
        _data = [];
      }
      _data!.addAll(chat);
    } else {
      if (_dataMerge == null) {
        _dataMerge = [];
      }
      _dataMerge!.addAll(chat);
    }
    notifyListeners();
  }

  Future loadAllData({required BuildContext context}) async {
    UserModel? user = await getMember();

    if (user != null) {
      await repository.me(user: user).then((data) async {
        final Future<SharedPreferences> _prefs =
            SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        if (data!.user!.blocked == null || data.user!.blocked == false) {
          await prefs
              .setString(
            kMemberLower,
            jsonEncode(
              data.toJson(),
            ),
          )
              .then((value) {
            loadFilterData();
            _current = new DateTime.now().millisecondsSinceEpoch;
            Map<String, dynamic> param = {kParamSort: kSortDateDesc};
            if (isMarketing(user)) {
              param["chat_contains"] = "vslst";
            }
            /*loadTotal(param: param, time: _current);

            repository
                .fetchAllNote(ignoreNull: true, param: param)
                .then((value) {
              updateData(value);
              loadFilterData();
            });*/
          });
        }
      }).catchError((err) {
        Provider.of<SettingProvider>(context, listen: false).doLogout(context);
      });
    }
  }

  waitNewData() {
    if (!merge) {
      _data = null;
    } else {
      _dataMerge = null;
    }

    notifyListeners();
  }

  loadTotal({required Map<String, dynamic>? param, required int time}) {
    if (!merge) {
      this.param = param;
    }
    total = -1;
    baru = -1;
    notifyListeners();

    repository.getTotal(param: param).then((value) {
      if (time == _current) {
        total = value.total;
        baru = value.baru;
        notifyListeners();
      }
    });
  }

  Future<ChatModel?> loadDetail() async {
    if (chat!.chat == null) {
      notifyListeners();
      return chat;
    }

    ChatModel model;

    model = await repository.loadChat(chatModel: chat!);

    int index = data!.indexOf(chat);
    if (index > -1) {
      data!.remove(chat);

      data!.insert(index, model);
    }

    chat = model;

    notifyListeners();
    return model;
  }

  Future<List<TagModel>> getTag({bool cache = false}) async {
    String name = "tag";
    String nameUpdate = name + "update";
    String url = kTagUpdateUrl;
    List<TagModel> data = [];
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);

    if (str != null && str.isNotEmpty && cache) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => TagModel.fromJson(e))
          .toList();
      return data;
    }

    String? update = await repository.getUpdate(url: url);

    if (str != null && str.isNotEmpty && str == update) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => TagModel.fromJson(e))
          .toList();
    } else {
      data = await repository.getTag();
      await _prefs.setString(name, jsonEncode(data));
      await _prefs.setString(nameUpdate, update!);
    }

    return data;
  }

  Future<List<CityModel>> getCity() async {
    String name = "city"; //ubah
    String nameUpdate = name + "update";
    String url = kKotaUpdateUrl; //ubah
    String? update = await repository.getUpdate(url: url);

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);

    List<CityModel> data = []; //ubah

    if (str != null && str.isNotEmpty && str == update) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => CityModel.fromJson(e)) //ubah
          .toList();
    } else {
      data = await repository.getCity(); //ubah
      await _prefs.setString(name, jsonEncode(data));
      await _prefs.setString(nameUpdate, update!);
    }

    return data;
  }

  Future<List<AreaModel>> getArea() async {
    String name = "area"; //ubah
    String nameUpdate = name + "update";
    String url = kAreaUpdateUrl; //ubah
    String? update = await repository.getUpdate(url: url);

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);

    List<AreaModel> data = []; //ubah

    if (str != null && str.isNotEmpty && str == update) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => AreaModel.fromJson(e)) //ubah
          .toList();
    } else {
      data = await repository.getArea(); //ubah
      await _prefs.setString(name, jsonEncode(data));
      await _prefs.setString(nameUpdate, update!);
    }

    _area.clear();
    _area.addAll(data);

    return data;
  }

  Future<List<SubAreaModel>> getSubarea() async {
    String name = "subarea"; //ubah
    String nameUpdate = name + "update";
    String url = kSubareaUpdateUrl; //ubah
    String? update = await repository.getUpdate(url: url);

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);

    List<SubAreaModel> data = []; //ubah

    if (str != null && str.isNotEmpty && str == update) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => SubAreaModel.fromJson(e)) //ubah
          .toList();
    } else {
      data = await repository.getSubArea(); //ubah
      await _prefs.setString(name, jsonEncode(data));
      await _prefs.setString(nameUpdate, update!);
    }

    _subArea.clear();
    _subArea.addAll(data);

    return data;
  }

  Future<List<SpecificLocationModel>> getLokasiSpesifik() async {
    String name = "lokasi"; //ubah
    String nameUpdate = name + "update";
    String url = kLokasiUpdateUrl; //ubah
    String? update = await repository.getUpdate(url: url);

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);
    print(str);

    List<SpecificLocationModel> data = []; //ubah

    if (str != null && str.isNotEmpty && str == update) {
      data = (jsonDecode(_prefs.getString(name)!) as List)
          .map((e) => SpecificLocationModel.fromJson(e)) //ubah
          .toList();
    } else {
      data = await repository.fetchLocation(); //ubah
      await _prefs.setString(name, jsonEncode(data));
      await _prefs.setString(nameUpdate, update!);
    }

    _location.clear();
    _location.addAll(data);
    return data;
  }

  Future getFilter() async {
    if (isFilterLoaded == false) {
      isFilterLoaded = true;
      List<FilterModel> data = await repository.fetchFilter();
      savedFilter.addAll(data);
    }
  }

  newData({required Map<String, dynamic>? param, bool? ignoreTotal}) {
    if (!merge) {
      _data = null;
      this.param = param;
    } else {
      _dataMerge = null;
    }

    notifyListeners();
    _current = new DateTime.now().millisecondsSinceEpoch;
    loadData(param: param, time: _current);
    if (ignoreTotal == null) loadTotal(param: param, time: _current);
  }

  Future<PhotoModel> uploadPhoto({required String path}) {
    return repository.uploadPhoto(
        path: path /*, ref: "chat", field: "photo", id: chat.id*/);
  }

  scrollData({required Map<String, dynamic>? param}) {
    List<ChatModel?>? temp;

    if (!merge) {
      temp = _data;
    } else {
      temp = _dataMerge;
    }

    if (temp != null && temp.length >= kMaxData && loading == false) {
      if (!merge) {
        this.param = param;
      }
      loading = true;
      notifyListeners();
      param![kParamStart] = temp.length;
      _current = new DateTime.now().millisecondsSinceEpoch;
      loadData(param: param, time: _current);
    }
  }

  loadData({required Map<String, dynamic>? param, required int time}) {
    if (!merge) {
      this.param = param;
    }

    repository.fetchAllNote(param: param, ignoreNull: true).then((value) {
      if (time == _current) {
        loading = false;
        updateData(value);
      }
    });
  }

  loadFilterData() async {
    loadVersion();
  }

  loadVersion() async {
    repository.fetchVersion().then((value) async {
      int? number = 0;
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String? str = _prefs.getString(kVersionLower);
      if (str != null && str.isNotEmpty) {
        number = jsonDecode(str)[kNumberLower];
      }

      _prefs
          .setString(
        kVersionLower,
        jsonEncode(
          value,
        ),
      )
          .then((_) {
        if (number != value[kNumberLower]) {
          loadCategory();
          loadLocation();
          loadArea();
          loadSubArea();
          loadBuildingTypes();
        } else {
          String? category = _prefs.getString(kPropertyCategoryLower);

          String? location = _prefs.getString(kSpecificLocationLower);
          String? area = _prefs.getString(kAreaLower);
          String? subArea = _prefs.getString(kSubAreaLower);

          String? buildingTypes = _prefs.getString(kBuildingTypeLower);

          if (category == null || category.isEmpty) {
            loadCategory();
          } else {
            _category.addAll((jsonDecode(category) as List)
                .map((e) => PropertyCategoryModel.fromJson(e))
                .toList());

            if (_category.length >= _maxDisplay) {
              _categoryDisplay.addAll(_category.where(
                  (element) => _category.indexOf(element) < _maxDisplay));
            } else {
              _categoryDisplay.addAll(_category);
            }
            notifyListeners();
          }

          if (location == null || location.isEmpty) {
            loadLocation();
          } else {
            _location.addAll((jsonDecode(location) as List)
                .map((e) => SpecificLocationModel.fromJson(e))
                .toList());
            if (_location.length >= _maxDisplay) {
              _locationDisplay.addAll(_location.where(
                  (element) => _location.indexOf(element) < _maxDisplay));
            } else {
              _locationDisplay.addAll(_location);
            }
            notifyListeners();
          }

          if (area == null || area.isEmpty) {
            loadArea();
          } else {
            _area.addAll((jsonDecode(area) as List)
                .map((e) => AreaModel.fromJson(e))
                .toList());
            if (_area.length >= _maxDisplay) {
              _areaDisplay.addAll(_area
                  .where((element) => _area.indexOf(element) < _maxDisplay));
            } else {
              _areaDisplay.addAll(_area);
            }
            notifyListeners();
          }

          if (subArea == null || subArea.isEmpty) {
            loadSubArea();
          } else {
            _subArea.addAll((jsonDecode(subArea) as List)
                .map((e) => SubAreaModel.fromJson(e))
                .toList());
            if (_subArea.length >= _maxDisplay) {
              _subAreaDisplay.addAll(_subArea
                  .where((element) => _subArea.indexOf(element) < _maxDisplay));
            } else {
              _subAreaDisplay.addAll(_subArea);
            }
            notifyListeners();
          }

          if (buildingTypes == null || buildingTypes.isEmpty) {
            loadBuildingTypes();
          } else {
            _buildingTypes.addAll((jsonDecode(buildingTypes) as List)
                .map((e) => BuildingTypesModel.fromJson(e))
                .toList());
            if (_buildingTypes.length >= _maxDisplay) {
              _buildingTypesDisplay.addAll(_buildingTypes.where(
                  (element) => _buildingTypes.indexOf(element) < _maxDisplay));
            } else {
              _buildingTypesDisplay.addAll(_buildingTypes);
            }
            notifyListeners();
          }
        }
      });
    });
  }

  loadCategory() async {
    repository.fetchCategory().then((value) {
      _category.addAll(value);
      if (_category.length >= _maxDisplay) {
        _categoryDisplay.addAll(_category
            .where((element) => _category.indexOf(element) < _maxDisplay));
      } else {
        _categoryDisplay.addAll(_category);
      }
      notifyListeners();
    });
  }

  loadLocation() async {
    repository.fetchLocation().then((value) {
      _location.addAll(value);
      if (_location.length >= _maxDisplay) {
        _locationDisplay.addAll(_location
            .where((element) => _location.indexOf(element) < _maxDisplay));
      } else {
        _locationDisplay.addAll(_location);
      }
      notifyListeners();
    });
  }

  loadArea() async {
    repository.getArea().then((value) {
      _area.addAll(value);
      if (_area.length >= _maxDisplay) {
        _areaDisplay.addAll(
            _area.where((element) => _area.indexOf(element) < _maxDisplay));
      } else {
        _areaDisplay.addAll(_area);
      }
      notifyListeners();
    });
  }

  loadSubArea() async {
    repository.getSubArea().then((value) {
      _subArea.addAll(value);
      if (_subArea.length >= _maxDisplay) {
        _subAreaDisplay.addAll(_subArea
            .where((element) => _subArea.indexOf(element) < _maxDisplay));
      } else {
        _subAreaDisplay.addAll(_subArea);
      }
      notifyListeners();
    });
  }

  loadBuildingTypes() async {
    repository.fetchBuildingTypes().then((value) {
      _buildingTypes.addAll(value);
      if (_buildingTypes.length >= _maxDisplay) {
        _buildingTypesDisplay.addAll(_buildingTypes
            .where((element) => _buildingTypes.indexOf(element) < _maxDisplay));
      } else {
        _buildingTypesDisplay.addAll(_buildingTypes);
      }
      notifyListeners();
    });
  }

  Future<ChatModel?> editChat({required Map<String, dynamic> param}) async {
    List<ChatModel?>? temp;

    if (!merge) {
      temp = _data;
    } else {
      temp = _dataMerge;
    }
    ChatModel res = await repository.updateChat(
        param: param, id: chat!.id != null ? chat!.id.toString() : "-1");

    if (chat!.id == null) {
      temp!.insert(0, res);
      chat = temp[0];
    } else {
      int index = temp!.indexOf(chat);
      temp.removeAt(index);
      temp.insert(index, res);
      chat = temp[index];
    }

    notifyListeners();
    return chat;
  }

  Future deleteChat(List<ChatModel?> chat) async {
    List<ChatModel?>? temp;

    if (!merge) {
      temp = _data;
    } else {
      temp = _dataMerge;
    }

    await repository.deleteChat(
        ids: chat.map((e) => e!.id.toString()).toList());

    chat.forEach((element) {
      temp!.remove(element);
    });
    notifyListeners();
    return true;
  }

  Future<ChatModel?> mergeChat(List<int?> id) async {
    try {
      ChatModel chatModel = await repository.mergeChat(id: id);
      id.forEach((e) {
        data!.removeWhere((element) => element!.id == e);
      });
      data!.insert(0, chatModel);
      chat = data![0];
      notifyListeners();
      return chatModel;
    } catch (e) {
      return null;
    }
  }

  Future<ChatModel> addChat(String chat) async {
    List<ChatModel?>? temp;

    if (!merge) {
      temp = _data;
    } else {
      temp = _dataMerge;
    }

    ChatModel chatModel = new ChatModel();
    chatModel.chat = chat;
    chatModel.notes = this.chat!.notes;
    chatModel.notes2 = this.chat!.notes2;
    chatModel.contact = this.chat!.contact;
    chatModel.date = this.chat!.date;
    chatModel.ai = true;
    chatModel.check = false;
    chatModel.check2 = false;
    chatModel.check3 = false;

    ChatModel res = await repository.addChat(chatModel: chatModel);
    temp!.insert(temp.indexOf(this.chat), res);
    notifyListeners();
    return res;
  }

  clear() {
    List<ChatModel?>? temp;

    if (!merge) {
      temp = _data;
    } else {
      temp = _dataMerge;
    }
    if (temp != null) temp.clear();
    chat = null;
    repository.closeNote();
  }

  dispose() {
    clear();
    super.dispose();
  }
}
