class ResponseMessage {
  int MessageTemplate_ID;
  String MessageNo;
  String Message;
  int SubscriptionType_ID;
  String SubscriptionType_Name;
  int ResponseTemplate_ID;
  String ResponseNo;
  String Response;

  ResponseMessage(
      this.MessageTemplate_ID,
      this.MessageNo,
      this.Message,
      this.SubscriptionType_ID,
      this.SubscriptionType_Name,
      this.ResponseTemplate_ID,
      this.ResponseNo,
      this.Response); //DateTime? CreateDate;



  factory ResponseMessage.fromJson(dynamic json) {
    return ResponseMessage(
        json['MessageTemplate_ID'] as int,
        json['MessageNo'] as String,
        json['Message'] as String,
        json['SubscriptionType_ID'] as int,
        json['SubscriptionType_Name'] as String,
        json['ResponseTemplate_ID'] as int,
        json['ResponseNo'] as String,
        json['Response'] as String,
    );
  }

  @override
  String toString() {
    return '${this.Response}';
  }
}
