class Furnish {
  int? id;
  String? iD;
  String? title;
  String? createdAt;
  String? updatedAt;

  Furnish({this.id, this.iD, this.title, this.createdAt, this.updatedAt});

  Furnish.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iD = json['ID_'];
    title = json['Title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ID_'] = this.iD;
    data['Title'] = this.title;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
