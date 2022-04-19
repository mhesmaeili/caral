class Brands {

  int Brand_ID;
  String BrandName = "";

  Brands(this.Brand_ID, this.BrandName);

  factory Brands.fromJson(dynamic json) {
    return Brands(json['Brand_ID'] as int, json['BrandName'] as String);
  }

  @override
  String toString() {
    return '${this.BrandName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Brands &&
          runtimeType == other.runtimeType &&
          Brand_ID == other.Brand_ID;

  @override
  int get hashCode => Brand_ID.hashCode;
}
