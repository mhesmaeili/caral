class Models {
  int Brand_ID;
  int Model_ID;
  String ModelName = "";

  Models(this.Brand_ID, this.Model_ID, this.ModelName);

  factory Models.fromJson(dynamic json) {
    return Models(json['Brand_ID'] as int, json['Model_ID'] as int,
        json['ModelName'] as String);
  }

  @override
  String toString() {
    return '${this.ModelName}';
  }
}
