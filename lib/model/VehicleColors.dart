class VehicleColors {
  int Color_ID;
  String ColorName="";

  VehicleColors(this.Color_ID, this.ColorName);

  factory VehicleColors.fromJson(dynamic json) {
    return VehicleColors(json['Color_ID'] as int, json['ColorName'] as String);
  }

  @override
  String toString() {
    return '${this.ColorName}';
  }
}
