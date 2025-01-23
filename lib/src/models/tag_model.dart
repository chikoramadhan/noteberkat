import 'package:versus/src/models/selectable_model.dart';

class TagModel {
  int? id;
  String? name;
  String? color;
  int? chat;
  SelectAbleModel? selectAbleModel;

  TagModel({this.id, this.color, this.name, this.chat, this.selectAbleModel});

  TagModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    if (json['chats'] != null) {
      chat = json["chats"];
    } else {
      chat = 0;
    }
    selectAbleModel = new SelectAbleModel(id: id, title: name);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["color"] = this.color;
    data['id'] = this.id;
    data['chats'] = this.chat;

    return data;
  }
}
