import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/resources/helper.dart';

class ChatProvider extends MainProvider {
  List<ChatModel>? _data;
  final List<PropertyCategoryModel> _category = [];
  final List<PropertyCategoryModel?> _categoryDisplay = [];
  final List<SpecificLocationModel> _location = [];
  final List<SpecificLocationModel?> _locationDisplay = [];
  final _maxDisplay = 5;

  ChatModel? chat;

  //0 kategori
  //1 transaksi
  //2 lokasi
  int code = -1;
  String notDetected = "-";

  bool showSnackbar = false;
  bool loading = false;

  List<ChatModel>? get data => _data;

  List<PropertyCategoryModel?> get categoryDisplay => _categoryDisplay;

  List<SpecificLocationModel?> get locationDisplay => _locationDisplay;

  List<PropertyCategoryModel> get category => _category;

  List<SpecificLocationModel> get location => _location;

  String get title {
    if (code == 0) {
      return "Kategori Tidak Terdeteksi";
    } else if (code == 1) {
      return "Transaksi Tidak Terdeteksi";
    } else if (code == 2) {
      return "Lokasi Tidak Terdeteksi";
    }

    return "Chat";
  }

  updateData(List<ChatModel> chat) {
    if (_data == null) {
      _data = [];
    }

    _data!.addAll(chat);
    notifyListeners();
  }

  loadAllData() async {
    repository.fetchAllNote(ignoreNull: true).then((value) {
      updateData(value);
      loadFilterData();
    });
  }

  newData({required Map<String, dynamic> param}) {
    _data = null;
    notDetected = "-";
    notifyListeners();
    loadCount(param: param);
    loadData(param: param);
  }

  scrollData({required Map<String, dynamic> param}) {
    if (_data != null && _data!.length >= kMaxData && loading == false) {
      loading = true;
      notifyListeners();
      param[kParamStart] = _data!.length;
      loadData(param: param);
    }
  }

  loadData({required Map<String, dynamic> param}) {
    repository.fetchAllNote(param: param, ignoreNull: true).then((value) {
      loading = false;
      updateData(value);
    });
  }

  loadCount({required Map<String, dynamic> param}) {
    repository.fetchCount(param: param).then((value) {
      notDetected = value.toString();
      notifyListeners();
    });
  }

  loadFilterData() async {
    loadVersion();
  }

  loadVersion() async {
    List<dynamic> list = [];
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
        } else {
          String? category = _prefs.getString(kPropertyCategoryLower);

          String? location = _prefs.getString("lokasiupdate");
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

  clear() {
    _data!.clear();
    chat = null;
    repository.closeNote();
  }

  dispose() {
    clear();
    super.dispose();
  }
}
