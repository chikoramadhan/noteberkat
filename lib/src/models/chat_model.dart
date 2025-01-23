import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:versus/src/models/agent_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/certificate_model.dart';
import 'package:versus/src/models/furnish.dart';
import 'package:versus/src/models/photo_model.dart';
import 'package:versus/src/models/property_category_condition.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/toward_model.dart';
import 'package:versus/src/models/user.dart';
import 'package:versus/src/resources/helper.dart';

class ChatModel {
  int? id;
  String? chat;
  String? chat2;
  String? createdAt;
  String? updatedAt;
  String? updateAgent;
  String? date;
  String? contact;
  String? transactionTypeID;
  SpecificLocationModel? specificLocation;
  BuildingTypesModel? buildingType;
  String? propertyTypeID;
  Furnish? furnish;
  PropertyCategoryModel? propertyCategory;
  String? lT;
  String? lB;
  String? panjang;
  String? lebar;
  String? posisiLantai;
  String? jumlahLantai;
  String? kT;
  PropertyCategoryCondition? propertyCategoryCondition;
  String? hargaJual;
  String? hargaSewa;
  String? perMeterJual;
  String? perMeterSewa;
  String? labelNew;
  bool? check;
  bool? check2;
  bool? check3;
  late bool splitLevel;
  late bool lelang;
  late bool hook;
  late bool minus;
  bool? ai;
  User? editor;
  User? checker;
  late bool request;
  late bool multi;

  String? notes;
  String? notes2;
  String? history;
  String? linkPhoto;
  List<PhotoModel>? photo;
  List<TagModel>? tag;
  String? nilaiBangunan;
  String? nilaiTanah;
  String? breakdownJual;
  String? globalSewa;
  CertificateModel? certificate;
  TowardModel? toward;
  late List<AgentModel> agents;
  Map<String, dynamic>? agentJson;

  String getTransaksi() {
    if (transactionTypeID == null) {
      return "-";
    } else {
      if (transactionTypeID == "1") {
        return kJual;
      } else if (transactionTypeID == "2") {
        return kSewa;
      } else if (transactionTypeID == "3") {
        return kJualSewa;
      }
    }
    return "";
  }

  String? getKategori() {
    if (propertyCategory == null) {
      return "-";
    } else {
      return propertyCategory!.title;
    }
  }

  String? getLokasi() {
    if (specificLocation == null) {
      return "-";
    } else {
      return specificLocation!.lokasiSpesifikName;
    }
  }

  String? getLuasTanah() {
    if (lT == null) {
      return "-";
    } else {
      return lT;
    }
  }

  String? getKt() {
    if (kT == null) {
      return "-";
    } else {
      return kT;
    }
  }

  String? getLuasBangunan() {
    if (lB == null) {
      return "-";
    } else {
      return lB;
    }
  }

  String? getLebarDepan() {
    if (lebar == null) {
      return "-";
    } else {
      return lebar;
    }
  }

  String? getPanjang() {
    if (panjang == null) {
      return "-";
    } else {
      return panjang;
    }
  }

  String? getJumlahLantai() {
    if (jumlahLantai == null) {
      return "-";
    } else {
      return jumlahLantai;
    }
  }

  String? getPosisiLantai() {
    if (posisiLantai == null) {
      return "-";
    } else {
      return posisiLantai;
    }
  }

  String getHargaJual() {
    if (hargaJual == null) {
      return "-";
    } else {
      return new NumberFormat.currency(
              locale: "id_ID", symbol: "", decimalDigits: 0)
          .format(int.parse(hargaJual!));
    }
  }

  String getHargaSewa() {
    if (hargaSewa == null) {
      return "-";
    } else {
      return new NumberFormat.currency(
              locale: "id_ID", symbol: "", decimalDigits: 0)
          .format(int.parse(hargaSewa!));
    }
  }

  String getPerMeterJual() {
    if (perMeterJual == null) {
      return "-";
    } else {
      return new NumberFormat.currency(
              locale: "id_ID", symbol: "", decimalDigits: 0)
          .format(int.parse(perMeterJual!));
    }
  }

  String getPerMeterSewa() {
    if (perMeterSewa == null) {
      return "-";
    } else {
      return new NumberFormat.currency(
              locale: "id_ID", symbol: "", decimalDigits: 0)
          .format(int.parse(perMeterSewa!));
    }
  }

  ChatModel({
    this.id,
    this.chat,
    this.chat2,
    this.createdAt,
    this.updatedAt,
    this.contact,
    this.transactionTypeID,
    this.specificLocation,
    this.buildingType,
    this.propertyTypeID,
    this.furnish,
    this.propertyCategory,
    this.lT,
    this.lB,
    this.kT,
    this.splitLevel = false,
    this.panjang,
    this.lebar,
    this.posisiLantai,
    this.jumlahLantai,
    this.propertyCategoryCondition,
    this.hargaJual,
    this.hargaSewa,
    this.perMeterJual,
    this.perMeterSewa,
    this.labelNew,
    this.check,
    this.check2,
    this.check3,
    this.ai,
    this.editor,
    this.checker,
    this.history,
    this.linkPhoto,
    this.photo,
    this.tag,
    this.lelang = false,
    this.minus = false,
    this.hook = false,
  }) {
    this.date = new DateTime.now().toIso8601String();
  }

  ChatModel.fromJson(Map<String, dynamic> json) {
    check = json["check"];
    if (json["check2"] != null) {
      check2 = json["check2"];
    } else {
      check2 = false;
    }

    if (json["check3"] != null) {
      check3 = json["check3"];
    } else {
      check3 = false;
    }

    if (json["lelang"] != null) {
      lelang = json["lelang"];
    } else {
      lelang = false;
    }

    if (json["hook"] != null) {
      hook = json["hook"];
    } else {
      hook = false;
    }

    if (json["minus"] != null) {
      minus = json["minus"];
    } else {
      minus = false;
    }

    ai = json["ai"];
    editor = json["editor"] != null ? User.fromJson(json["editor"]) : null;

    if (json["checker"] is int) {
      checker = new User();
    } else {
      checker = json["checker"] != null ? User.fromJson(json["checker"]) : null;
    }

    id = json['id'];

    chat = json['chat'];
    chat2 = json['chat2'];

    if (chat != null && false) {
      String temp = "";

      chat!.split("").forEach((element) {
        List<int> encode =
            utf8.encode(element); // Encode the emoji to UTF-8 bytes
        String decode = utf8.decode(encode);
        temp += decode;
      });

      chat = temp;
    }

    notes = json['notes'];
    notes2 = json["notes2"];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    updateAgent = json['update_agent'];
    date = json['date'];
    contact = json['contact'];
    transactionTypeID = json['TransactionTypeID'];
    specificLocation = json['specific_location'] != null
        ? new SpecificLocationModel.fromJson(json['specific_location'])
        : null;

    buildingType = json["building_type"] != null
        ? new BuildingTypesModel.fromJson(json["building_type"])
        : null;
    propertyTypeID = json['PropertyTypeID'];
    furnish =
        json['furnish'] != null ? new Furnish.fromJson(json['furnish']) : null;
    propertyCategory = json['property_category'] != null
        ? new PropertyCategoryModel.fromJson(json['property_category'])
        : null;
    lT = json['LT'] != null ? json['LT'].toString() : null;
    lB = json['LB'] != null ? json['LB'].toString() : null;
    kT = json['KT'] != null ? json['KT'].toString() : null;

    splitLevel = json['split_level'] ?? false;
    panjang = json['panjang'] != null ? json['panjang'].toString() : null;
    lebar = json['lebar'] != null ? json['lebar'].toString() : null;
    posisiLantai =
        json['posisi_lantai'] != null ? json['posisi_lantai'].toString() : null;
    jumlahLantai =
        json['jumlah_lantai'] != null ? json['jumlah_lantai'].toString() : null;
    propertyCategoryCondition = json['property_category_condition'] != null
        ? new PropertyCategoryCondition.fromJson(
            json['property_category_condition'])
        : null;
    if (json['photo'] != null) {
      photo = <PhotoModel>[];
      json['photo'].forEach((v) {
        photo!.add(new PhotoModel.fromJson(v));
      });
    }

    tag = [];

    if (json['tags'] != null) {
      tag = <TagModel>[];
      json['tags'].forEach((v) {
        tag!.add(new TagModel.fromJson(v));
      });
    }
    hargaJual = json['HargaJual'];
    hargaSewa = json['HargaSewa'];
    perMeterJual = json['perMeterJual'];
    perMeterSewa = json['perMeterSewa'];
    labelNew = json['isNew'] == true ? "New" : "";
    history = json['history'];
    linkPhoto = json['link_photo'];
    nilaiBangunan = json["nilaiBangunan"];
    nilaiTanah = json["nilaiTanah"];
    breakdownJual = json["breakdownJual"];
    globalSewa = json["globalSewa"];
    if (json["sertifikat"] != null) {
      certificate = CertificateModel.fromJson(json["sertifikat"]);
    }
    if (json["hadap"] != null) {
      toward = TowardModel.fromJson(json["hadap"]);
    }

    if (json["request"] != null) {
      request = json["request"];
    } else {
      request = false;
    }

    if (json["multi"] != null) {
      multi = json["multi"];
    } else {
      multi = false;
    }

    if (json["agents"] != null) {
      agents = <AgentModel>[];
      json['agents'].forEach((v) {
        agents.add(new AgentModel.fromJson(v));
      });
    } else {
      agents = [];
    }

    if (json["agent_json"] != null) {
      agentJson = json["agent_json"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["check"] = this.check;
    data["ai"] = this.ai;
    data["editor"] = this.editor != null ? this.editor!.toJson() : null;
    data["checker"] = this.checker != null ? this.checker!.toJson() : null;
    data['id'] = this.id;
    data['chat'] = this.chat;
    data['chat2'] = this.chat2;
    data['notes'] = this.notes;
    data["notes2"] = this.notes2;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['update_agent'] = this.updateAgent;
    data['date'] = this.date;
    data['contact'] = this.contact;
    data['TransactionTypeID'] = this.transactionTypeID;
    if (this.specificLocation != null) {
      data['specific_location'] = this.specificLocation!.toJson();
    }
    if (this.buildingType != null) {
      data["building_type"] = this.buildingType!.toJson();
    }
    data['PropertyTypeID'] = this.propertyTypeID;
    if (this.furnish != null) {
      data['furnish'] = this.furnish!.toJson();
    }

    if (this.propertyCategory != null) {
      data['property_category'] = this.propertyCategory!.toJson();
    }
    data['LT'] = this.lT;
    data['LB'] = this.lB;
    data['KT'] = this.kT;
    data['split_level'] = this.splitLevel;
    data['panjang'] = this.panjang;
    data['lebar'] = this.lebar;
    data['posisi_lantai'] = this.posisiLantai;
    data['jumlah_lantai'] = this.jumlahLantai;
    if (this.propertyCategoryCondition != null) {
      data['property_category_condition'] =
          this.propertyCategoryCondition!.toJson();
    }
    data['HargaJual'] = this.hargaJual;
    data['HargaSewa'] = this.hargaSewa;
    data['perMeterJual'] = this.perMeterJual;
    data['perMeterSewa'] = this.perMeterSewa;
    data['history'] = this.history;
    data['link_photo'] = this.linkPhoto;
    if (this.photo != null) {
      data['photo'] = this.photo!.map((v) => v.toJson()).toList();
    }
    if (this.tag != null) {
      data['tags'] = this.tag!.map((v) => v.toJson()).toList();
    }

    data["nilaiBangunan"] = this.nilaiBangunan;
    data["nilaiTanah"] = this.nilaiTanah;
    data["breakdownJual"] = this.breakdownJual;
    data["globalSewa"] = this.globalSewa;
    data["lelang"] = this.lelang;
    data["hook"] = this.hook;
    data["minus"] = this.minus;
    data["hadap"] = this.toward?.toJson();
    data["sertifikat"] = this.certificate?.toJson();
    data["agents"] = this.agents.map((e) => e.toJson()).toList();
    data["agent_json"] = this.agentJson;

    return data;
  }

  String hargaClipboard(bool full) {
    if (!full) {
      return "";
    }

    CurrencyTextInputFormatter formatter =
        CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0);
    String text = "\n";
    if (perMeterJual != null) {
      text += "(Rp. " + formatter.format(perMeterJual!) + " /m²)";
    } else {
      text += "-";
    }

    text += "\n";

    String? sewa = globalSewa;

    List<int> catTanah = [1, 4, 15];

    if (propertyCategory != null &&
        propertyCategory!.id != null &&
        catTanah.contains(propertyCategory!.id)) {
      sewa = perMeterSewa;
    }

    if (sewa != null) {
      text += "(Rp. " + formatter.format(sewa!) + " /m²/th)";
    } else {
      text += "-";
    }
    text += "\n";
    return text;
  }
}
