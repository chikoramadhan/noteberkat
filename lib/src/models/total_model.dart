class TotalModel {
  late int total;
  late int baru;
  TotalModel({required this.total, required this.baru});

  TotalModel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    baru = json['baru'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['baru'] = this.baru;
    return data;
  }
}
