import 'package:versus/src/models/selectable_model.dart';

class PropertyCategoryModel {
  int? id;
  String? title;
  String? typeID;
  String? typeTitle;
  SelectAbleModel? selectAbleModel;

  PropertyCategoryModel({this.id, this.title, this.typeID, this.typeTitle});

  PropertyCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['Title'];
    typeID = json['TypeID'];
    typeTitle = json['TypeTitle'];
    selectAbleModel = new SelectAbleModel(id: id, title: title);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    data['TypeID'] = this.typeID;
    data['TypeTitle'] = this.typeTitle;
    return data;
  }
}
