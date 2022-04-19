
import 'MessageTemplates.dart';

class HeaderMessage {
  bool result;
  List<MessageTemplates>? data;

  HeaderMessage(this.result, [this.data]);

  factory HeaderMessage.fromJson(dynamic json) {
    if (json['data'] != null) {
      var tagObjsJson = json['data'] as List;
      List<MessageTemplates> _tags = tagObjsJson.map((tagJson) =>
          MessageTemplates.fromJson(tagJson)).toList();

      return HeaderMessage(
          json['result'] as bool,
          _tags
      );
    } else {
      return HeaderMessage(
          json['result'] as bool
      );
    }
  }

  @override
  String toString() {
    return '{ ${this.result}, ${this.data} }';
  }
}