import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/selectable_model.dart';

class CityModel {
  int? id;
  String? title;
  String? type;
  String? createdAt;
  String? updatedAt;
  List<AreaModel>? areas;
  SelectAbleModel? selectAbleModel;

  CityModel(
      {this.id,
      this.title,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.areas});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['Title'];
    type = json['Type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    selectAbleModel = new SelectAbleModel(id: id, title: title);

    if (json['areas'] != null) {
      areas = <AreaModel>[];
      json['areas'].forEach((v) {
        areas!.add(new AreaModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    data['Type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.areas != null) {
      data['areas'] = this.areas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
