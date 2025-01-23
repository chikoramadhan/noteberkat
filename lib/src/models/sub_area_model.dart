import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/specific_location_model.dart';

class SubAreaModel {
  int? id;
  late String title;
  AreaModel? area;
  String? createdAt;
  String? updatedAt;
  int? price;
  SelectAbleModel? selectAbleModel;
  List<SpecificLocationModel>? specificLocations;

  SubAreaModel(
      {this.id,
      required this.title,
      this.area,
      this.createdAt,
      this.updatedAt,
      this.price,
      this.specificLocations});

  SubAreaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    title = json['Title'];
    area = json['area'] != null && !(json["area"] is int)
        ? new AreaModel.fromJson(json['area'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    price = json['Price'];
    if (json['specific_locations'] != null) {
      specificLocations = <SpecificLocationModel>[];
      json['specific_locations'].forEach((v) {
        specificLocations!.add(new SpecificLocationModel.fromJson(v));
      });
    }
    selectAbleModel = new SelectAbleModel(
        id: id, title: title, subtitle: subtitleSubArea(this));
  }

  String? subtitleSubArea(SubAreaModel e) {
    String subtitle = "";

    if (e.area != null) {
      subtitle = e.area!.title;

      if (e.area!.city != null) {
        subtitle += " - " + e.area!.city!.title!;
      }
    }

    return subtitle;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    if (this.area != null) {
      data['area'] = this.area!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['Price'] = this.price;
    if (this.specificLocations != null) {
      data['specific_locations'] =
          this.specificLocations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
