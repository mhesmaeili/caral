class Vehicles {
  int Brand_ID;
  String BrandName = "";
  int Model_ID;
  String ModelName = "";

  Vehicles(this.Brand_ID, this.BrandName, this.Model_ID, this.ModelName);

  factory Vehicles.fromJson(dynamic json) {
    return Vehicles(json['Brand_ID'] as int, json['BrandName'] as String,json['Model_ID'] as int, json['ModelName'] as String);
  }

  @override
  String toString() {
    return '${this.Brand_ID}, ${this.BrandName},${this.Model_ID}, ${this.ModelName}';
  }
}
