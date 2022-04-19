class UserCarAssignInfo {

  String EffectiveDate;
  bool IsValid;
  String QrCodeNo;
  String FullName;
  String Email;
  String Name;
  String Color;
  String Brand;
  String PlateNo;
  int PlateType;
  int UserCarAssign_ID;
  int User_ID;

  UserCarAssignInfo(
      this.EffectiveDate,
      this.IsValid,
      this.QrCodeNo,
      this.FullName,
      this.Email,
      this.Name,
      this.Color,
      this.Brand,
      this.PlateNo,
      this.PlateType,
      this.UserCarAssign_ID,
      this.User_ID);

  factory UserCarAssignInfo.fromJson(dynamic json) {
    return UserCarAssignInfo(json['EffectiveDate'] as String,
        json['IsValid'] as bool,
        json['QrCodeNo'] as String,
        json['FullName'] as String,
        json['Email'] as String,
        json['Name'] as String,
        json['Color'] as String,
        json['Brand'] as String,
        json['PlateNo'] as String,
        json['PlateType'] as int,
        json['UserCarAssign_ID'] as int,
        json['User_ID'] as int
    );
  }

  @override
  String toString() {
    return '{ ${this.Name}, ${this.Color}, ${this.FullName}, ${this.Brand}, ${this.PlateNo} }';
  }
}
