import 'package:flutter/material.dart';

class TempAgentModel {
  late String nama;
  late TextEditingController namaController;
  late List<String> hp;
  List<TextEditingController> hpController = [];

  TempAgentModel({required this.nama, required this.hp});

  TempAgentModel.fromJson(Map<String, dynamic> json) {
    if (json["nama"] == null) {
      nama = "";
    } else {
      nama = json['nama'];
      namaController = new TextEditingController(text: nama);
    }

    hp = [];

    List.from(json['hp']).forEach((element) {
      hp.add(element);
      hpController.add(TextEditingController(text: element));
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['nama'] = this.nama;
    data['hp'] = this.hp;
    return data;
  }
}
