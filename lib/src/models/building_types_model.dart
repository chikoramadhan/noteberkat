import 'package:flutter/material.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/selectable_model.dart';

class BuildingTypesModel {
  int? id;
  String? title;
  PropertyCategoryModel? propertyCategory;
  String? desc;
  String? price;
  String? include;
  String? exclude;
  int? sort;
  SelectAbleModel? selectAbleModel;
  SelectAbleModel? selectAbleModel2;

  BuildingTypesModel(
      {this.id,
      this.title,
      this.propertyCategory,
      this.desc,
      this.price,
      Map<String, dynamic>? optional}) {
    if (id == -1) {
      selectAbleModel2 = new SelectAbleModel(
          id: id,
          title: "",
          optional: optional ??
              {
                "Subtitle": Text(
                  "Pilihan tipe bangunan harus dipilih",
                  style: TextStyle(color: Colors.red),
                )
              });
    }
  }

  BuildingTypesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['Title'];
    try {
      propertyCategory = json['property_category'] != null
          ? new PropertyCategoryModel.fromJson(json['property_category'])
          : null;
    } catch (e) {
      propertyCategory = json['property_category'] != null
          ? new PropertyCategoryModel(id: json['property_category'])
          : null;
    }

    desc = json['Desc'];
    price = json['Price'];
    sort = json["sort"];
    include = json["Include"];
    exclude = json["Exclude"];
    selectAbleModel = new SelectAbleModel(id: id, title: title, optional: {
      "Include": include,
      "Exclude": exclude,
      "Price": price,
      "Keterangan": Text(desc ?? "")
    });

    selectAbleModel2 = new SelectAbleModel(id: id, title: title);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    if (this.propertyCategory != null) {
      data['property_category'] = this.propertyCategory!.toJson();
    }
    data['Desc'] = this.desc;
    data['Price'] = this.price;
    data["Include"] = this.include;
    data["Exclude"] = this.exclude;
    data["sort"] = this.sort;
    return data;
  }
}
