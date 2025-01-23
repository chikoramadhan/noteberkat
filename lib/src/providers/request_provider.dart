import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/setting_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/views/request_view.dart';

class RequestProvider extends MainProvider {
  List<RequestModel?>? _data;
  late RequestView view;
  Map<String, dynamic>? param = {};

  final List<PropertyCategoryModel> _category = [];
  final List<PropertyCategoryModel> _categoryDisplay = [];
  final List<SpecificLocationModel> _location = [];
  final List<SpecificLocationModel> _locationDisplay = [];
  final List<BuildingTypesModel> _buildingTypes = [];
  final List<BuildingTypesModel> _buildingTypesDisplay = [];

  final List<AreaModel> _area = [];
  final List<AreaModel> _areaDisplay = [];

  final List<SubAreaModel> _subArea = [];
  final List<SubAreaModel> _subAreaDisplay = [];

  List<FilterModel> savedFilter = [];
  FilterModel? _selectedFilter;
  bool isFilterLoaded = false;

  int total = -1;
  int baru = -1;
  int _current = 0;
  final _maxDisplay = 5;
  bool canLoad = true;

  RequestModel? request;

  bool loading = false;

  List<RequestModel?>? get data => _data;

  set selectedFilter(FilterModel? value) {
    _selectedFilter = value;
    notifyListeners();
  }

  FilterModel? get selectedFilter => _selectedFilter;

  List<PropertyCategoryModel> get categoryDisplay => _categoryDisplay;

  List<SpecificLocationModel> get locationDisplay => _locationDisplay;

  List<SubAreaModel> get subArea => _subArea;
  List<AreaModel> get areaDisplay => _areaDisplay;

  List<SubAreaModel> get subAreaDisplay => _subAreaDisplay;
  List<AreaModel> get area => _area;

  List<PropertyCategoryModel> get category => _category;

  List<SpecificLocationModel> get location => _location;

  List<BuildingTypesModel> get buildingTypes => _buildingTypes;

  updateData(List<RequestModel> request) {
    if (_data == null) {
      _data = [];
    }

    if (request.length < kMaxData) {
      canLoad = false;
    }

    _data!.addAll(request);
    notifyListeners();
    view.reload();
  }

  Future<RequestModel?> loadDetail() async {
    if (request!.chat == null || request!.id == null) {
      notifyListeners();
      return request;
    }

    RequestModel model;

    model = await repository.loadRequest(requestModel: request!);

    int index = data!.indexOf(request);
    data!.remove(request);

    data!.insert(index, model);
    request = data![index];
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

  Future uploadFile({required List<File> files}) async {
    for (var file in files) {
      await repository.uploadFile(file: file).then((value) {
        print(value);
      });
    }

    await repository.processRequest();
  }

  loadTotal({required Map<String, dynamic> param, required int time}) {
    this.param = param;
    total = -1;
    baru = -1;
    notifyListeners();
    repository.getTotalRequest(param: param).then((value) {
      if (time == _current) {
        total = value.total;
        baru = value.baru;
        notifyListeners();
      }
    });
  }

  newData({required Map<String, dynamic> param, bool? ignoreTotal}) {
    canLoad = true;
    _data = null;
    this.param = param;
    notifyListeners();
    view.reload();
    _current = new DateTime.now().millisecondsSinceEpoch;
    loadData(param: param, time: _current);
    if (ignoreTotal == null) loadTotal(param: param, time: _current);
  }

  scrollData({required Map<String, dynamic>? param}) {
    List<RequestModel?>? temp;

    temp = _data;

    if (temp != null && canLoad && loading == false) {
      this.param = param;
      loading = true;
      notifyListeners();
      view.reload();
      param![kParamStart] = temp.length;
      _current = new DateTime.now().millisecondsSinceEpoch;
      loadData(param: param, time: _current);
    }
  }

  loadData({required Map<String, dynamic>? param, required int time}) {
    this.param = param;

    repository.fetchAllRequest(param: param, ignoreNull: true).then((value) {
      if (time == _current) {
        loading = false;
        updateData(value);
      }
    });
  }

  Future<RequestModel?> editRequest(
      {required Map<String, dynamic> param,
      required RequestModel? request}) async {
    List<RequestModel?>? temp = _data;

    RequestModel res = await repository.updateRequest(
      param: param,
      id: request?.id?.toString() ?? "-1",
    );

    if (temp != null) {
      int index = temp.indexOf(request);
      bool canInsert = true;

      if (this.param!["request"] != null &&
          param["request"] != null &&
          param["request"] != this.param!["request"]) {
        //canInsert = false;
      }

      if (this.param!["hasil"] != null &&
          param["hasil"] != this.param!["hasil"]) {
        //canInsert = false;
      }

      if (index == -1) {
        temp.insert(0, res);
        this.request = res;
      } else if (canInsert) {
        temp[index]!.modify(res);
        this.request = temp[index];
        if (temp[index]!.callback != null) temp[index]!.callback!();
      } else {
        if (index >= 0) {
          total -= 1;
          temp.removeAt(index);
        }

        this.request = res;
        view.reload();
      }
    } else {
      this.request = res;
    }

    notifyListeners();

    return res;
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
            loadTotal(param: {}, time: _current);
            repository.fetchAllRequest(
                ignoreNull: true,
                param: {kParamSort: kSortDateAsc}).then((value) {
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

  Future deleteRequest(List<RequestModel?> request) async {
    List<RequestModel?>? temp = _data;

    await repository.deleteRequest(
        ids: request.map((e) => e!.id.toString()).toList());

    request.forEach((element) {
      temp!.remove(element);
    });
    notifyListeners();
    return true;
  }

  Future<RequestModel> addRequest(String chat) async {
    List<RequestModel?> temp = _data!;

    RequestModel requestModel = new RequestModel();
    requestModel.chat = chat;
    requestModel.date = this.request!.date;
    requestModel.contact = this.request!.contact;
    requestModel.editor = this.request!.editor;

    RequestModel res = await repository.addRequest(requestModel: requestModel);
    temp.insert(temp.indexOf(this.request), res);
    notifyListeners();
    return res;
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
