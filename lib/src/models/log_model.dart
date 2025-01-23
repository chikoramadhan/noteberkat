import 'package:versus/src/models/user.dart';

class LogModel {
  int? id;
  User? user;
  int? edit;
  int? edit2;
  int? edit3;
  int? check1;
  int? check2;
  int? check3;
  String? createdAt;
  String? updatedAt;
  String? start;
  String? end;

  LogModel(
      {this.id,
      this.user,
      this.edit,
      this.edit2,
      this.edit3,
      this.check1,
      this.check2,
      this.check3,
      this.createdAt,
      this.updatedAt,
      this.start,
      this.end});

  LogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    check1 = json['check1'];
    check2 = json["check2"];
    check3 = json["check3"];
    edit = json['edit'];
    edit2 = json['edit2'];

    if (edit2 == null) {
      edit2 = 0;
    }

    edit3 = json['edit3'];

    if (edit3 == null) {
      edit3 = 0;
    }

    if (check1 == null) {
      check1 = 0;
    }

    if (check2 == null) {
      check2 = 0;
    }

    if (check3 == null) {
      check3 = 0;
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['edit'] = this.edit;
    data['edit2'] = this.edit2;
    data['edit3'] = this.edit3;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}
