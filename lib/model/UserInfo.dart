class UserInfo {
  int ID;
  String FirstName = "";
  String LastName = "";
  String MobileNo = "";
  String UserCode = "";
  String Email = "";
  String Address = "";
  int MessageType;
  bool AllowReceiveMessageFromNotLoginUser;

  UserInfo(this.ID, this.FirstName, this.LastName, this.MobileNo, this.UserCode,this.Email,this.Address,
      this.MessageType,this.AllowReceiveMessageFromNotLoginUser);

  factory UserInfo.fromJson(dynamic json) {
    return UserInfo(
        json['ID'] as int,
        json['FirstName'] as String,
        json['LastName'] as String,
        json['MobileNo'] as String,
        json['UserCode'] as String,
        json['Email'] as String,
        json['Address'] as String,
        json['MessageType'] as int,
        json['AllowReceiveMessageFromNotLoginUser'] as bool
    );
  }

  @override
  String toString() {
    return '${this.UserCode}';
  }
}
