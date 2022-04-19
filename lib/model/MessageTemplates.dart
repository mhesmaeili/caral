class MessageTemplates {
  int ID;
  String MessageNo="";
  String Message = "";
  int SubscriptionType_ID;
  String SubscriptionType_Name = "";
  int? ParentMessageTemplate_ID;

  MessageTemplates(this.ID, this.MessageNo, this.Message,
      this.SubscriptionType_ID, this.SubscriptionType_Name,this.ParentMessageTemplate_ID);

  factory MessageTemplates.fromJson(dynamic json) {
    return MessageTemplates(
        json['ID'] as int,
        json['MessageNo'] as String,
        json['Message'] as String,
        json['SubscriptionType_ID'] as int,
        json['SubscriptionType_Name'] as String,
        json['ParentMessageTemplate_ID'] as int?);
  }

  @override
  String toString() {
    return '{ ${this.ID}, ${this.Message} }';
  }
}
