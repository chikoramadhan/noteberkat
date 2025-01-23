import 'package:versus/src/models/selectable_model.dart';

class TowardModel {
  int? id;
  String? title;
  SelectAbleModel? selectAbleModel;
  SelectAbleModel? selectAbleModel2;

  TowardModel({
    this.id,
    this.title,
  }) {
    if (id == -1) {
      selectAbleModel2 = new SelectAbleModel(
        id: id,
        title: "",
      );
    }
  }

  TowardModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['Title'];
    selectAbleModel = new SelectAbleModel(id: id, title: title);
    selectAbleModel2 = new SelectAbleModel(id: id, title: title);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Title'] = this.title;
    return data;
  }
}
