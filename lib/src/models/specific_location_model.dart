import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/sub_area_model.dart';

class SpecificLocationModel {
  int? id;
  String? lokasiSpesifikName;
  String? title;
  int? price;
  SubAreaModel? subArea;
  SelectAbleModel? selectAbleModel;
  int? properties;

  SpecificLocationModel({
    this.id,
    this.lokasiSpesifikName,
  });

  SpecificLocationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lokasiSpesifikName = json['LokasiSpesifikName'];
    title = lokasiSpesifikName;

    try {
      subArea = json['sub_area'] != null && !(json["sub_area"] is int)
          ? new SubAreaModel.fromJson(json['sub_area'])
          : null;
    } catch (e) {
      print(json);
    }

    price = json['Price'];
    selectAbleModel = new SelectAbleModel(
        id: id, title: lokasiSpesifikName, subtitle: subtitleLokasi(this));
    if (json["properties"] != null && json['properties'] is int) {
      properties = json["properties"];
    }
  }

  String? subtitleLokasi(SpecificLocationModel e) {
    String subtitle = "";

    if (e.subArea != null) {
      subtitle = e.subArea!.title;

      if (e.subArea!.area != null) {
        subtitle += " - " + e.subArea!.area!.title;

        if (e.subArea!.area!.city != null) {
          subtitle += " - " + e.subArea!.area!.city!.title!;
        }
      }
    }

    return subtitle;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['LokasiSpesifikName'] = this.lokasiSpesifikName;
    if (this.subArea != null) {
      data['sub_area'] = this.subArea!.toJson();
    }
    data['Price'] = this.price;
    data["properties"] = this.properties;
    return data;
  }
}
