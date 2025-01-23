import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/certificate_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/toward_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/setting_provider.dart';
import 'package:versus/src/resources/helper.dart';

class TestingProvider extends MainProvider {
  List<ChatModel?>? _data;
  Map<String, dynamic>? param = {};

  final List<PropertyCategoryModel> _category = [];
  final List<PropertyCategoryModel> _categoryDisplay = [];
  final List<SpecificLocationModel> _location = [];
  final List<SpecificLocationModel?> _locationDisplay = [];
  final List<BuildingTypesModel> _buildingTypes = [];
  final List<BuildingTypesModel> _buildingTypesDisplay = [];
  final List<CertificateModel> _certificate = [];
  final List<CertificateModel> _certificateDisplay = [];
  final List<TowardModel> _toward = [];
  final List<TowardModel> _towardDisplay = [];

  final List<AreaModel> _area = [];
  final List<AreaModel?> _areaDisplay = [];

  final List<SubAreaModel> _subArea = [];
  final List<SubAreaModel?> _subAreaDisplay = [];

  List<FilterModel> savedFilter = [];
  FilterModel? _selectedFilter;
  bool isFilterLoaded = false;

  int? total = -1;
  int? baru = -1;
  int _current = 0;
  final _maxDisplay = 5;

  ChatModel? chat;

  bool loading = false;

  List<ChatModel?>? get data => _data;

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

  List<CertificateModel> get certificate => _certificate;

  List<CertificateModel> get certificateDisplay => _certificateDisplay;

  List<TowardModel> get toward => _toward;

  List<TowardModel> get towardDisplay => _towardDisplay;

  updateData(List<ChatModel> chat) {
    if (_data == null) {
      _data = [];
    }
    _data!.addAll(chat);
    notifyListeners();
  }

  Future<ChatModel?> loadDetail() async {
    if (chat!.chat == null) {
      notifyListeners();
      return chat;
    }

    ChatModel model;

    model = await repository.loadTesting(chatModel: chat!);

    int index = data!.indexOf(chat);
    data!.remove(chat);

    data!.insert(index, model);
    chat = data![index];
    notifyListeners();
    return model;
  }

  Future<List<TagModel>> getTag() async {
    String name = "tag";
    String nameUpdate = name + "update";
    String url = kTagUpdateUrl;
    String? update = await repository.getUpdate(url: url);

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? str = _prefs.getString(nameUpdate);

    List<TagModel> data = [];

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

  loadTotal({required Map<String, dynamic> param, required int time}) {
    this.param = param;
    total = -1;
    baru = -1;
    notifyListeners();
    repository.getTotalTesting(param: param).then((value) {
      if (time == _current) {
        total = value.total;
        baru = value.baru;
        notifyListeners();
      }
    });
  }

  newData({required Map<String, dynamic> param, bool? ignoreTotal}) {
    _data = null;
    this.param = param;

    notifyListeners();
    _current = new DateTime.now().millisecondsSinceEpoch;
    loadData(param: param, time: _current);
    if (ignoreTotal == null) loadTotal(param: param, time: _current);
  }

  scrollData({required Map<String, dynamic>? param}) {
    List<ChatModel?>? temp;

    temp = _data;

    if (temp != null && temp.length >= kMaxData && loading == false) {
      this.param = param;
      loading = true;
      notifyListeners();
      param![kParamStart] = temp.length;
      _current = new DateTime.now().millisecondsSinceEpoch;
      loadData(param: param, time: _current);
    }
  }

  loadData({required Map<String, dynamic>? param, required int time}) {
    this.param = param;

    repository.fetchAllTesting(param: param, ignoreNull: true).then((value) {
      if (time == _current) {
        loading = false;
        updateData(value);
      }
    });
  }

  loadAllData({required BuildContext context}) async {
    UserModel? user = await getMember();

    if (user != null) {
      repository.me(user: user).then((data) async {
        final Future<SharedPreferences> _prefs =
            SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        if (data!.user!.blocked == null || data.user!.blocked == false) {
          prefs
              .setString(
            kMemberLower,
            jsonEncode(
              data.toJson(),
            ),
          )
              .then((value) {
            _current = new DateTime.now().millisecondsSinceEpoch;
            loadTotal(param: {
              /*"update_agent_null": true*/ "created_at_gte":
                  "2025-01-01T09:28:00.000Z"
            }, time: _current);
            repository.fetchAllTesting(ignoreNull: true, param: {
              kParamSort: kSortDateDesc,
              "created_at_gte": "2025-01-01T09:28:00.000Z"
              //"update_agent_null": true
            }).then((value) {
              updateData(value);
              loadFilterData();
            });
          });
        }
      }).catchError((err) {
        Provider.of<SettingProvider>(context, listen: false).doLogout(context);
      });
    }
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
          loadCertificate();
          loadToward();
        } else {
          String? category = _prefs.getString(kPropertyCategoryLower);

          String? location = _prefs.getString(kSpecificLocationLower);
          String? area = _prefs.getString(kAreaLower);
          String? subArea = _prefs.getString(kSubAreaLower);

          String? buildingTypes = _prefs.getString(kBuildingTypeLower);
          String? certificate = _prefs.getString(kCertificateLower);
          String? toward = _prefs.getString(kTowardLower);

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

          if (certificate == null || certificate.isEmpty) {
            loadCertificate();
          } else {
            _certificate.addAll((jsonDecode(certificate) as List)
                .map((e) => CertificateModel.fromJson(e))
                .toList());
            if (_certificate.length >= _maxDisplay) {
              _certificateDisplay.addAll(_certificate.where(
                  (element) => _certificate.indexOf(element) < _maxDisplay));
            } else {
              _certificateDisplay.addAll(_certificate);
            }
            notifyListeners();
          }

          if (toward == null || toward.isEmpty) {
            loadToward();
          } else {
            _toward.addAll((jsonDecode(toward) as List)
                .map((e) => TowardModel.fromJson(e))
                .toList());
            if (_toward.length >= _maxDisplay) {
              _towardDisplay.addAll(_toward
                  .where((element) => _toward.indexOf(element) < _maxDisplay));
            } else {
              _towardDisplay.addAll(_toward);
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

  loadCertificate() async {
    repository.fetchCertificate().then((value) {
      _certificate.addAll(value);
      if (_certificate.length >= _maxDisplay) {
        _certificateDisplay.addAll(_certificate
            .where((element) => _certificate.indexOf(element) < _maxDisplay));
      } else {
        _certificateDisplay.addAll(_certificate);
      }
      notifyListeners();
    });
  }

  loadToward() async {
    repository.fetchToward().then((value) {
      _toward.addAll(value);
      if (_toward.length >= _maxDisplay) {
        _towardDisplay.addAll(
            _toward.where((element) => _toward.indexOf(element) < _maxDisplay));
      } else {
        _towardDisplay.addAll(_toward);
      }
      notifyListeners();
    });
  }

  Future<ChatModel?> editTesting({required Map<String, dynamic> param}) async {
    List<ChatModel?>? temp = _data;

    ChatModel res = await repository.updateTesting(
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

  clear() {
    _data = null;
    _category.clear();
    _categoryDisplay.clear();
    _location.clear();
    _locationDisplay.clear();
    _area.clear();
    _areaDisplay.clear();
    _subArea.clear();
    _subAreaDisplay.clear();
    _buildingTypes.clear();
    _buildingTypesDisplay.clear();
  }

  dispose() {
    clear();
    super.dispose();
  }
}
