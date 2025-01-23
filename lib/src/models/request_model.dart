import 'dart:convert';

import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/user.dart';

class RequestModel {
  int? id;
  String? chat;
  String? createdAt;
  String? updatedAt;
  String? updateAgent;
  String? date;
  String? contact;
  String? transactionTypeID;
  List<SpecificLocationModel>? specificLocations;
  List<AreaModel>? areas;
  List<SubAreaModel>? subAreas;
  List<BuildingTypesModel>? buildingType;
  String? propertyTypeID;
  List<PropertyCategoryModel>? propertyCategory;
  User? editor;
  int? filterCategory;
  int? filterLocation;
  String? luasMin;
  String? luasMax;
  String? budgetMax;
  int? hasil;
  List<String>? keyword;
  String? global;
  void Function()? callback;

  RequestModel({
    this.id,
    this.chat,
    this.createdAt,
    this.updatedAt,
    this.contact,
    this.transactionTypeID,
    this.specificLocations,
    this.buildingType,
    this.propertyTypeID,
    this.propertyCategory,
    this.editor,
  }) {
    this.date = new DateTime.now().toIso8601String();
  }

  modify(RequestModel request) {
    fromJson(request.toJson());
  }

  RequestModel.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  fromJson(Map<String, dynamic> json) {
    editor = json["editor"] != null ? User.fromJson(json["editor"]) : null;
    id = json['id'];
    chat = json['chat'];

    if (chat != null) {
      String temp = "";

      chat!.split("").forEach((element) {
        List<int> encode =
            utf8.encode(element); // Encode the emoji to UTF-8 bytes
        String decode = utf8.decode(encode);
        temp += decode;
      });

      chat = temp;
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updateAgent = json['update_agent'];
    date = json['date'];
    contact = json['contact'];
    transactionTypeID = json['TransactionTypeID'];
    if (json["specific_locations"] != null) {
      specificLocations = List.from(json["specific_locations"])
          .map((e) => SpecificLocationModel.fromJson(e))
          .toList();
    } else {
      specificLocations = [];
    }
    if (json["areas"] != null) {
      areas =
          List.from(json["areas"]).map((e) => AreaModel.fromJson(e)).toList();
    } else {
      areas = [];
    }

    if (json["sub_areas"] != null) {
      subAreas = List.from(json["sub_areas"])
          .map((e) => SubAreaModel.fromJson(e))
          .toList();
    } else {
      subAreas = [];
    }

    propertyTypeID = json['PropertyTypeID'];

    if (json['property_categories'] != null) {
      propertyCategory = List.from(json["property_categories"])
          .map((e) => PropertyCategoryModel.fromJson(e))
          .toList();
    } else {
      propertyCategory = [];
    }

    if (json['building_types'] != null) {
      buildingType = List.from(json['building_types'])
          .map((e) => BuildingTypesModel.fromJson(e))
          .toList();
    } else {
      buildingType = [];
    }

    if (json["filter_category"] != null) {
      filterCategory = json["filter_category"];
    } else {
      filterCategory = 0;
    }

    if (json["filter_location"] != null) {
      filterLocation = json["filter_location"];
    } else {
      filterLocation = 0;
    }

    if (json["luas_min"] != null) {
      luasMin = json["luas_min"].toString();
    }

    if (json["luas_max"] != null) {
      luasMax = json["luas_max"].toString();
    }

    if (json["budget_max"] != null) {
      budgetMax = json["budget_max"];
    }

    if (json["global"] != null) {
      global = json["global"];
    }

    if (json["hasil"] != null) {
      hasil = json["hasil"];
    } else {
      hasil = -1;
    }

    if (json["keyword"] != null) {
      keyword = List.from(json["keyword"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["editor"] = this.editor != null ? this.editor!.toJson() : null;
    data['id'] = this.id;
    data['chat'] = this.chat;

    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['update_agent'] = this.updateAgent;
    data['date'] = this.date;
    data['contact'] = this.contact;
    data['TransactionTypeID'] = this.transactionTypeID;
    if (this.specificLocations != null) {
      data['specific_locations'] =
          this.specificLocations!.map((e) => e.toJson()).toList();
    }
    if (this.areas != null) {
      data['areas'] = this.areas!.map((e) => e.toJson()).toList();
    }
    if (this.subAreas != null) {
      data['sub_areas'] = this.subAreas!.map((e) => e.toJson()).toList();
    }
    data['PropertyTypeID'] = this.propertyTypeID;

    data['property_categories'] =
        this.propertyCategory?.map((e) => e.toJson()).toList();

    data['building_types'] =
        this.buildingType?.map((e) => e.toJson()).toList();

    data["filter_category"] = this.filterCategory;
    data["filter_location"] = this.filterLocation;
    data["luas_min"] = this.luasMin;
    data["luas_max"] = this.luasMax;
    data["budget_max"] = this.budgetMax;
    data["global"] = this.global;
    data["hasil"] = this.hasil;
    data["keyword"] = this.keyword;
    return data;
  }
}
