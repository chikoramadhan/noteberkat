import 'package:versus/src/models/city_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/sub_area_model.dart';

class AreaModel {
  int? id;
  late String title;
  String? createdAt;
  String? updatedAt;
  CityModel? city;
  List<SubAreaModel>? subAreas;
  SelectAbleModel? selectAbleModel;

  AreaModel(
      {this.id,
      required this.title,
      this.createdAt,
      this.updatedAt,
      this.city,
      this.subAreas});

  AreaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['Title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    city = json['city'] != null && !(json['city'] is int)
        ? new CityModel.fromJson(json['city'])
        : null;
    if (json['sub_areas'] != null) {
      subAreas = <SubAreaModel>[];
      json['sub_areas'].forEach((v) {
        subAreas!.add(new SubAreaModel.fromJson(v));
      });
    }
    selectAbleModel =
        new SelectAbleModel(id: id, title: title, subtitle: subtitleArea(this));
  }

  String? subtitleArea(AreaModel e) {
    String? subtitle = "";

    if (e.city != null) {
      subtitle = e.city!.title;
    }

    return subtitle;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    if (this.subAreas != null) {
      data['sub_areas'] = this.subAreas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
