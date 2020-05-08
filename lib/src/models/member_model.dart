import 'package:firebase_database/firebase_database.dart';

class MemberModel {
  String id;
  String name;
  String email;

  MemberModel({this.id, this.name, this.email});

  update(DataSnapshot snapshot) {
    if (snapshot.key == "name")
      name = snapshot.value;
    else if (snapshot.key == "email") email = snapshot.value;
  }

  MemberModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    /*name = json['name'].toString().length == 0
        ? (email.length == 0
            ? "No Name"
            : (email.contains("@")
                ? email.substring(0, email.indexOf("@"))
                : email))
        : json['name'];*/
    name = json['name'];
  }

  MemberModel.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        email = snapshot.value['email'] != null ? snapshot.value['email'] : "",
        name = snapshot.value['name'] != null ? snapshot.value['name'] : "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
