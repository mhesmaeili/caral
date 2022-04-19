import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/pages/MessagesInboxComplete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../CommonFunction.dart';

class MessageItem extends StatefulWidget {
  final Messages messages;
  final int countMessages;
  final List<Messages> messagesList;
  final int userId;

  const MessageItem(
      this.messages, this.countMessages, this.messagesList, this.userId);

  @override
  _MessageItem createState() => _MessageItem();
}

class _MessageItem extends State<MessageItem> {
  late String token;
  var _loadedInitData = false;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: GestureDetector(
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '... ' + widget.messages.Message.substring(0, 27),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15, color: Color(0xFF171923),),
              ),
              widget.messages.FromUser_ID == null
                  ? Text('ناشناس',
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFFC31331)))
                  : Text(
                      widget.messages.VehicleBrand_Name +
                          " " +
                          widget.messages.VehicleModel_Name,
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF171923)),
                    ),
            ],
          ),
          subtitle: Text(
            widget.messages.CreateDatePersian,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 10),
          ),
          trailing: widget.countMessages > 0
              ? CircleAvatar(
                  child: Text(
                    widget.countMessages.toString(),
                    style: TextStyle(fontFamily: 'BYekan'),
                  ),
                )
              : SizedBox(width: 0,),
        ),
        onTap: () {
          widget.messagesList.forEach((element) {
            if (element.ToUser_ID == widget.userId &&
                (element.IsMessageSeen == null ||
                    !element.IsMessageSeen!)) {
              setSeenStatusForReceivedMessage(element);
            }
          });
          Navigator.of(context).pushNamed(MessagesInboxComplete.routeName,
              arguments: widget.messagesList);
        },
      ),
    );
  }

  setSeenStatusForReceivedMessage(Messages messages) async {
    final uri = Uri.http('caralapp.ir:8085',
        '/api/userCarAssignMessage/setSeenStatusForReceivedMessage');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final body = {
      'userCarAssignMessageId': messages.UserCarAssignMessage_ID,
      'seenStatus': true
    };
    final response =
        await http.post(uri, headers: headers, body: convert.json.encode(body));
    print(body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var result = jsonResponse['result'];
      if (result) {
        messages.setSeenmessage(true);
      }
    }
  }

  setFakeStatusForReceivedMessage(Messages messages) async {
    final uri = Uri.http('caralapp.ir:8085',
        '/api/userCarAssignMessage/setFakeStatusForReceivedMessage');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final body = {
      'userCarAssignMessageId': messages.UserCarAssignMessage_ID,
      'fakeStatus': true
    };
    final response =
        await http.post(uri, headers: headers, body: convert.json.encode(body));
    print(body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var result = jsonResponse['result'];
      if (result) {
        messages.setSeenmessage(true);
      }
    }
  }
}
