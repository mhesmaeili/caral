import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/MessageTemplates.dart';
import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/model/ResponseMessage.dart';
import 'package:caralapp/widgets/ResponseMessageItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/widgets/MainDrawer.dart';
import '../CommonFunction.dart';

class ReplyToMessages extends StatefulWidget {
  static const routeName = '/ReplyToMessages';

  const ReplyToMessages({Key? key}) : super(key: key);

  @override
  _ReplyToMessages createState() => _ReplyToMessages();
}

class _ReplyToMessages extends State<ReplyToMessages> {
  List<MessageTemplates> responseMessageList = [];
  var _loadedInitData = false;
  late String token;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
        loadResponseMessage();
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = ModalRoute.of(context)!.settings.arguments as Messages;
    return Scaffold(
      appBar: AppBar(
        title: Text('کارال'),
        centerTitle: true,
      ),
      body: responseMessageList != null && responseMessageList.isNotEmpty
          ? RefreshIndicator(
              onRefresh: () => loadResponseMessage(),
              child: ListView.builder(
                  itemCount: responseMessageList.length,
                  itemBuilder: (ctx, i) =>
                      ResponseMessageItem(responseMessageList[i],messages)))
          : Center(
              child: SizedBox(
                width: 40,
                child: CircularProgressIndicator(
                  //strokeWidth: 10,
                  color: Theme.of(context).accentColor,
                  semanticsLabel: 'در حال بارگذاری',
                ),
              ),
            ),
      endDrawer: MainDrawer(),
    );
  }

  Future<void> loadResponseMessage() async {
    final uri = Uri.http('caralapp.ir:8085',
        '/api/messageTemplate/getMessageTemplates');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final response = await http.get(uri, headers: headers);
    print('Response: ' + response.statusCode.toString());
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var parsed = jsonResponse['data'];
    Messages messages = ModalRoute.of(context)!.settings.arguments as Messages;
    setState(() {
      responseMessageList = parsed
          .map<MessageTemplates>((json) => MessageTemplates.fromJson(json))
          .toList();
      responseMessageList = responseMessageList.where((element) =>
          element.ParentMessageTemplate_ID == messages.MessageTemplate_ID).toList();
    });
  }
}
