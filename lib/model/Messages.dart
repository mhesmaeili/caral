import 'package:flutter/foundation.dart';

class Messages with ChangeNotifier {
  int UserCarAssignMessage_ID;
  int UserCarAssign_ID;
  String CreateDatePersian;
  DateTime CreateDate;
  DateTime? EffectiveDate;
  String? EffectiveDatePersian;
  int? FromUser_ID;
  int ToUser_ID;
  int MessageTemplate_ID;
  String Message;
  String MessageNo;
  int SubscriptionType_ID;
  String SubscriptionType_Name;
  String PlateNo;
  int PlateType;
  int VehicleModel_ID;
  String VehicleModel_Name;
  int VehicleBrand_ID;
  String VehicleBrand_Name;
  int VehicleColor_ID;
  String VehicleColor_Name;
  int? MessageType;
  bool? IsFakeMessage;
  bool? IsMessageSeen;
  int? ParentUserCarAssignMessage_ID;

  Messages(
      this.UserCarAssignMessage_ID,
      this.UserCarAssign_ID,
      this.CreateDatePersian,
      this.CreateDate,
      this.EffectiveDate,
      this.EffectiveDatePersian,
      this.FromUser_ID,
      this.ToUser_ID,
      this.MessageTemplate_ID,
      this.Message,
      this.MessageNo,
      this.SubscriptionType_ID,
      this.SubscriptionType_Name,
      this.PlateNo,
      this.PlateType,
      this.VehicleModel_ID,
      this.VehicleModel_Name,
      this.VehicleBrand_ID,
      this.VehicleBrand_Name,
      this.VehicleColor_ID,
      this.VehicleColor_Name,
      this.MessageType,
      this.IsFakeMessage,
      this.IsMessageSeen,
      this.ParentUserCarAssignMessage_ID);

  factory Messages.fromJson(dynamic json) {
    return Messages(
      json['UserCarAssignMessage_ID'] as int,
      json['UserCarAssign_ID'] as int,
      json['CreateDatePersian'] as String,
      DateTime.parse(json['CreateDate']) as DateTime,
      DateTime.tryParse(
              json['EffectiveDate'] != null ? json['EffectiveDate'] : '')
          as DateTime?,
      json['EffectiveDatePersian'] as String?,
      json['FromUser_ID'] as int?,
      json['ToUser_ID'] as int,
      json['MessageTemplate_ID'] as int,
      json['Message'] as String,
      json['MessageNo'] as String,
      json['SubscriptionType_ID'] as int,
      json['SubscriptionType_Name'] as String,
      json['PlateNo'] as String,
      json['PlateType'] as int,
      json['VehicleModel_ID'] as int,
      json['VehicleModel_Name'] as String,
      json['VehicleBrand_ID'] as int,
      json['VehicleBrand_Name'] as String,
      json['VehicleColor_ID'] as int,
      json['VehicleColor_Name'] as String,
      json['MessageType'] as int?,
      json['IsFakeMessage'] as bool?,
      json['IsMessageSeen'] as bool?,
      json['ParentUserCarAssignMessage_ID'] as int?,
    );
  }

  setSeenmessage(bool s) {
    this.IsMessageSeen = s;
    notifyListeners();
  }

  @override
  String toString() {
    return '{${this.Message}}';
  }
}
