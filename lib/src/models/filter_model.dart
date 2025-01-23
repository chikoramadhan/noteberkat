import 'package:versus/src/models/selectable_model.dart';

class FilterModel {
  int? id;
  String? title;
  dynamic data;
  SelectAbleModel? selectAbleModel;

  FilterModel({this.id, this.title, this.data});

  FilterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    data = json['data'];

    selectAbleModel = new SelectAbleModel(id: id, title: title);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data["data"] = this.data;

    return data;
  }
}
