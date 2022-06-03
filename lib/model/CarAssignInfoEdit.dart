class CarAssignInfoEdit {
  String Name = "";
  String Color = "";
  String Brand = "";
  String PlateNo = "";
  int PlateType;
  int UserCarAssign_ID;
  int User_ID;
  int VehicleModel_ID;
  int VehicleBrand_ID;
  int VehicleColor_ID;

  CarAssignInfoEdit(
      this.Name,
      this.Color,
      this.Brand,
      this.PlateNo,
      this.PlateType,
      this.UserCarAssign_ID,
      this.User_ID,
      this.VehicleModel_ID,
      this.VehicleBrand_ID,
      this.VehicleColor_ID,
      );

  factory CarAssignInfoEdit.fromJson(dynamic json) {
    return CarAssignInfoEdit(
      json['Name'] as String,
      json['Color'] as String,
      json['Brand'] as String,
      json['PlateNo'] as String,
      json['PlateType'] as int,
      json['UserCarAssign_ID'] as int,
      json['User_ID'] as int,
      json['VehicleModel_ID'] as int,
      json['VehicleBrand_ID'] as int,
      json['VehicleColor_ID'] as int,
    );
  }

  @override
  String toString() {
    return '${this.UserCarAssign_ID}';
  }
}
