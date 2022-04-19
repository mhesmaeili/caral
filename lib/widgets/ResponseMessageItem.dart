import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/MessageTemplates.dart';
import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/pages/MessagesInbox.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../CommonFunction.dart';

class ResponseMessageItem extends StatefulWidget {
  final MessageTemplates responseMessage;
  final Messages message;

  const ResponseMessageItem(this.responseMessage, this.message);

  @override
  _ResponseMessageItem createState() => _ResponseMessageItem();
}

class _ResponseMessageItem extends State<ResponseMessageItem> {
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
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.responseMessage.Message,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 15,color: Color(0xFF171923)),
                ),
                ElevatedButton(
                    child: Text('ارسال'),
                    onPressed: () {
                      sendReply(widget.message, widget.responseMessage);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendReply(Messages messages, MessageTemplates responseMessage) async {
    final uri = Uri.http(
        'caralapp.ir:8085', '/api/userCarAssignMessage/sendResponseMessage');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final body = {
      'userCarAssign_id': messages.UserCarAssign_ID,
      'messageTemplate_id': responseMessage.ID,
      'toUser_id': messages.FromUser_ID,
      'fromUser_id': messages.ToUser_ID,
      'parentUserCarAssignMessage_id': messages.UserCarAssignMessage_ID,
      'messageType': 1
    };
    print(body);
    final response =
        await http.post(uri, headers: headers, body: convert.json.encode(body));
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['data'];
      var result = jsonResponse['result'];
      if (result) {
        showSnackBar(responseMessage.Message + " ارسال شد", 2);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        /*Navigator.of(context).pushNamedAndRemoveUntil(MessagesInbox.routeName,
            ModalRoute.withName(MessagesInbox.routeName));*/
      } else {
        showSnackBar(data.toString(), 3);
      }
    } else {
      showSnackBar('خطا در برقراری ارتباط با سرور', 3);
    }
  }

  void showSnackBar(String msg, int duration) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        duration: Duration(seconds: duration),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
