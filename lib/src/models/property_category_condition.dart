class PropertyCategoryCondition {
  int? id;
  String? iD;
  String? categoryID;
  String? categoryTitle;
  String? conditionID;
  String? conditionTitle;
  String? createdAt;
  String? updatedAt;

  PropertyCategoryCondition(
      {this.id,
      this.iD,
      this.categoryID,
      this.categoryTitle,
      this.conditionID,
      this.conditionTitle,
      this.createdAt,
      this.updatedAt});

  PropertyCategoryCondition.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iD = json['ID_'];
    categoryID = json['CategoryID'];
    categoryTitle = json['CategoryTitle'];
    conditionID = json['ConditionID'];
    conditionTitle = json['ConditionTitle'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ID_'] = this.iD;
    data['CategoryID'] = this.categoryID;
    data['CategoryTitle'] = this.categoryTitle;
    data['ConditionID'] = this.conditionID;
    data['ConditionTitle'] = this.conditionTitle;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
