class GeneralInfo {
  int GeneralID;
  int GeneralCode;
  String GeneralName = "";
  int GeneralType;
  String GeneralDescription = "";
  //DateTime? CreateDate;

  GeneralInfo(
      this.GeneralID,
      this.GeneralCode,
      this.GeneralName,
      this.GeneralType,
      this.GeneralDescription,
      //this.CreateDate
      );

  factory GeneralInfo.fromJson(dynamic json) {
    return GeneralInfo(
        json['GeneralID'] as int,
        json['GeneralCode'] as int,
        json['GeneralName'] as String,
        json['GeneralType'] as int,
        json['GeneralDescription'] as String,
        //json['CreateDate'] as DateTime,
    );
  }

  @override
  String toString() {
    return '${this.GeneralName}';
  }
}
