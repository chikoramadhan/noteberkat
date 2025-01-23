import 'package:flutter/material.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/providers/base_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/resources/popup_card.dart';
import 'package:versus/src/views/select_master_view.dart';

class SelectMasterProvider extends BaseProvider {
  final List<SelectAbleModel> _data = [];
  final List<SelectAbleModel?> _listSearch = [];
  final List<SelectAbleModel?> _allData = [];
  final List<SelectAbleModel> _listAdd = [];
  final List<SelectAbleModel> _shareWith = [];
  List<int?>? _selected = [];
  List<int?> _selectTemp = [];
  List<SelectAbleModel?>? _selectedModel = [];
  List<SelectAbleModel?> _selectedModelTemp = [];

  SelectMasterView? view;

  GlobalKey? key;
  bool loading = false;
  bool submit = false;
  bool done = false;
  String _title = "";
  PopUpItem? add;
  dynamic detail;
  bool single = false;
  String? highlight;
  bool withId = false;

  List<SelectAbleModel> get data => _data;

  List<SelectAbleModel?> get listSearch => _listSearch;

  List<SelectAbleModel> get listAdd => _listAdd;

  List<SelectAbleModel> get shareWith => _shareWith;

  List<int?> get selected => _selectTemp;

  List<SelectAbleModel?> get selectedModel => _selectedModelTemp;

  String get title => _title;

  setData(
      {required List<SelectAbleModel?> selectAbleModel,
      List<int?>? selected,
      List<SelectAbleModel?>? selectedModel,
      required String title,
      PopUpItem? add,
      dynamic detail,
      bool? single,
      String? highlight,
      bool? withId}) {
    _listSearch.clear();
    _listSearch.addAll(selectAbleModel);
    _allData.clear();
    _allData.addAll(selectAbleModel);
    _title = title;

    this.highlight = highlight;

    if (selected == null) {
      if (selectedModel != null) {
        _selected = selectedModel.map((e) => e!.id).toList();
      }
    } else {
      _selected = selected;
    }

    _selectedModel = selectedModel;
    if (_selected != null) _selectTemp.addAll(_selected!);
    if (_selectedModel != null) _selectedModelTemp.addAll(_selectedModel!);

    this.add = add;
    this.detail = detail;
    this.single = false;
    if (single != null) {
      this.single = single;
    }

    this.withId = false;
    if (withId != null) {
      this.withId = withId;
    }
  }

  doneSelect({required bool isSelected}) {
    if (isSelected) {
      _selected!.clear();
      _selected!.addAll(_selectTemp);

      if (_selectedModel != null) {
        _selectedModel!.clear();
        _selectedModel!.addAll(_selected!
            .map((e) => _listSearch.firstWhere((element) => element!.id == e,
                orElse: () => null))
            .toList());
        _selectedModel!.removeWhere((element) => element == null);
        _selectedModel!.forEach((element) {});
      }
    }

    add = null;
    detail = null;
    submit = false;
    _selectTemp.clear();
    _selectedModelTemp.clear();
    _selected = null;
    _selectedModel = null;
    notifyListeners();
  }

  addFriend(SelectAbleModel memberModel, VoidCallback callback) {
    _listAdd.add(memberModel);
    notifyListeners();
  }

  successAddFriend(int id) {
    _listAdd.removeWhere((element) => element.id == id);
    _listSearch.removeWhere((element) => element!.id == id);
    notifyListeners();
  }

  clear() {
    _data.clear();
    _listSearch.clear();
    _shareWith.clear();
    _listAdd.clear();
    _selected!.clear();
    _selectTemp.clear();
    _selectedModel!.clear();
    _selectedModelTemp.clear();
    detail = null;
    add = null;
    submit = false;
  }

  loadingSearch({required String keyword}) {
    _listSearch.clear();
    notifyListeners();
    _listSearch.addAll(_allData.where((element) =>
        element!.title!.toLowerCase().contains(keyword.toLowerCase())));
  }

  clearSearch() {
    _listSearch.clear();
    _listSearch.addAll(_allData);
    notifyListeners();
  }

  Future<dynamic> addMaster({
    required String url,
    required Map<String, dynamic> param,
    dynamic callback,
  }) async {
    if (view != null) {
      view!.back();
    }
    submit = true;
    notifyListeners();
    dynamic res = await repository.addMaster(url: url, param: param);
    submit = false;
    if (callback != null) {
      SelectAbleModel? selectAbleModel = callback(res);
      _listSearch.insert(0, selectAbleModel);
      _allData.insert(0, selectAbleModel);
    }
    notifyListeners();
    if (key != null) {
      showMessage(key as GlobalKey<ScaffoldState>, "Tag Added");
    }
    return res;
  }

  Future<dynamic> updateMaster(
      {required String url,
      required Map<String, dynamic> param,
      required int? id,
      required dynamic callback}) async {
    view!.back();
    submit = true;
    notifyListeners();
    dynamic res = await repository.updateMaster(url: url, param: param);
    submit = false;
    int index = _listSearch.indexWhere((element) => element!.id == id);
    int index2 = _allData.indexWhere((element) => element!.id == id);
    _listSearch.removeAt(index);
    _allData.removeAt(index2);
    SelectAbleModel? selectAbleModel = callback(res);
    _listSearch.insert(index, selectAbleModel);
    _allData.insert(index2, selectAbleModel);
    notifyListeners();
    showMessage(key as GlobalKey<ScaffoldState>, "Data Updated");
    return res;
  }

  Future<dynamic> deleteMaster(
      {required String url, required int? id, dynamic callback}) async {
    view!.back();
    submit = true;
    notifyListeners();
    dynamic res = await repository.deleteMaster(url: url);
    submit = false;
    int index = _listSearch.indexWhere((element) => element!.id == id);
    int index2 = _allData.indexWhere((element) => element!.id == id);
    _listSearch.removeAt(index);
    _allData.removeAt(index2);
    if (callback != null) {
      callback();
    }
    notifyListeners();
    showMessage(key as GlobalKey<ScaffoldState>, "Data Deleted");
    return res;
  }

  dispose() {
    clear();
    super.dispose();
  }
}
