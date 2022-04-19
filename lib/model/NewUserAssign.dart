import 'package:flutter/foundation.dart';

class NewUserAssign with ChangeNotifier {
  late String firstName;
  late String lastName;
  late String mobileNo;
  late int userType_Id;
  late String password;
  late String userCode;
  late String address;
  late int vehicleModel_Id;
  late int vehicleColor_Id;
  late int qrCode_Id;
  late String plateNo = "";
  late int plateType;
  late String plateNo1 = "";
  late String plateNo2 = "";
  late String plateNo3 = "";
  late String plateNo4 = "";

  NewUserAssign() {
    firstName = "";
    lastName = "";
    mobileNo = "";
    userType_Id = 0;
    password = "";
    userCode = "";
    address = "";
    vehicleModel_Id = 0;
    vehicleColor_Id = 0;
    qrCode_Id = 0;
    plateNo = "";
    plateType = 0;
    plateNo1 = "";
    plateNo2 = "";
    plateNo3 = "";
    plateNo4 = "";
  }

  @override
  String toString() {
    return '${this.mobileNo},${this.firstName},${this.lastName},${this.vehicleModel_Id},${this.plateType},${this.plateNo},${this.plateNo1},${this.plateNo2},${this.plateNo3},${this.plateNo4},${this.qrCode_Id}';
  }

  void fillQrCode(int code) {
    qrCode_Id = code;
    notifyListeners();
  }
}
