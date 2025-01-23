import 'package:versus/src/models/role.dart';

class User {
  int? id;
  String? username;
  String? email;
  bool? confirmed;
  bool? blocked;
  Role? role;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? phone1;
  String? phone2;
  String? phone3;
  String? phone4;
  String? reff;
  String? step;
  String? alamatrumah;

  User(
      {this.id,
      this.username,
      this.email,
      this.confirmed,
      this.blocked,
      this.role,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.phone1,
      this.phone2,
      this.phone3,
      this.phone4,
      this.reff,
      this.step,
      this.alamatrumah});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    confirmed = json['confirmed'];
    blocked = json['blocked'];
    role = json['role'] != null && !(json["role"] is int)
        ? new Role.fromJson(json['role'])
        : null;

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['Name'];
    phone1 = json['Phone1'];
    phone2 = json['Phone2'];
    phone3 = json['Phone3'];
    phone4 = json['Phone4'];
    reff = json['reff'];
    step = json['step'];
    alamatrumah = json['alamatrumah'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['confirmed'] = this.confirmed;
    data['blocked'] = this.blocked;
    if (this.role != null) {
      data['role'] = this.role!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['Name'] = this.name;
    data['Phone1'] = this.phone1;
    data['Phone2'] = this.phone2;
    data['Phone3'] = this.phone3;
    data['Phone4'] = this.phone4;
    data['reff'] = this.reff;
    data['step'] = this.step;
    data['alamatrumah'] = this.alamatrumah;
    return data;
  }
}
