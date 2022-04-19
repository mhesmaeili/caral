import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/widgets/MessageItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/class/ThemeModel.dart';
import '/widgets/MainDrawer.dart';
import '../CommonFunction.dart';

class MessagesInbox extends StatefulWidget {
  static const routeName = '/MessagesInbox';

  const MessagesInbox({Key? key}) : super(key: key);

  @override
  _MessagesInbox createState() => _MessagesInbox();
}

class _MessagesInbox extends State<MessagesInbox> {
  List<Messages> messagesList = [];
  List<msg> msgFilterList = [];
  var _loadedInitData = false;
  late String token;
  late bool noData = false;
  late int userId = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? timer;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
        CommonFunction.getSharedPreferences('USER_ID').then((value) {
          if (value.isNotEmpty) {
            userId = int.parse(value);
            loadMessages();
            timer = Timer.periodic(Duration(seconds: 10), (Timer t) => loadMessages());
          }
        });
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  StreamController _streamController = StreamController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('کارال'),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(
                    themeNotifier.isDark
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                    color: Theme.of(context).secondaryHeaderColor),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                }),
            IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                })
          ],
        ),
        body: StreamBuilder(
            //stream: loadMessages(),
            stream: _streamController.stream,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data!.length > 0 && msgFilterList.length>0) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, i) => MessageItem(
                        msgFilterList[i].messages,
                        msgFilterList[i].count,
                        msgFilterList[i].messagesList,
                        userId));
              } else {
                return Center(
                  child: noData
                      ? Text(
                          'هیچ پیامی برای شما ارسال نشده است',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'IRANSANS',
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : SizedBox(
                          width: 40,
                          child: CircularProgressIndicator(
                            //strokeWidth: 10,
                            color: Theme.of(context).accentColor,
                            semanticsLabel: 'در حال بارگذاری',
                          ),
                        ),
                );
              }
            }),
        endDrawer: MainDrawer(),
      );
    });
  }

  Future<void> loadMessages() async {
    //await Future<void>.delayed(Duration(seconds: duration));
    final uri = Uri.http(
        'caralapp.ir:8085', '/api/userCarAssignMessage/getAllMessagesForUser');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    print('call getAllMessagesForUser');
    final response = await http.post(uri, headers: headers, body: '');
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print('Response: $jsonResponse.');
    var parsed = jsonResponse['data'];
    bool result = jsonResponse['result'];
    setState(() {
    if (!result) {
      msgFilterList = [];
      noData = true;
    } else {
      msgFilterList = [];
      messagesList =
          parsed.map<Messages>((json) => Messages.fromJson(json)).toList();
      messagesList.forEach((messages) {
        var fromUser_ID = messages.FromUser_ID;
        var toUser_ID = messages.ToUser_ID;
        bool noSeen =
            (messages.FromUser_ID == null || messages.FromUser_ID != userId) &&
                (messages.IsMessageSeen == null || !messages.IsMessageSeen!);

        if (messages.ParentUserCarAssignMessage_ID == null) {
          if (fromUser_ID == null) {
            msg msgNew = new msg(messages, noSeen ? 1 : 0);
            msgNew.messagesList.add(messages);
            msgFilterList.add(msgNew);
          } else if (fromUser_ID != userId) {
            bool flg = true;
            msgFilterList.forEach((msg) {
              if (flg &&
                  msg.messages.FromUser_ID != null &&
                  msg.messages.FromUser_ID == fromUser_ID) {
                msg.messagesList.add(messages);
                if (noSeen) {
                  msg.count++;
                }
                flg = false;
              }
            });
            if (flg) {
              msg msgNew = new msg(messages, noSeen ? 1 : 0);
              msgNew.messagesList.add(messages);
              msgFilterList.add(msgNew);
            }
          } else {
            if (toUser_ID == userId) {
              bool flg = true;
              msgFilterList.forEach((msg) {
                if (flg &&
                    msg.messages.FromUser_ID != null &&
                    msg.messages.FromUser_ID == userId &&
                    msg.messages.ToUser_ID == userId) {
                  msg.messagesList.add(messages);
                  if (noSeen) {
                    msg.count++;
                  }
                  flg = false;
                }
              });
              if (flg) {
                msg msgNew = new msg(messages, noSeen ? 1 : 0);
                msgNew.messagesList.add(messages);
                msgFilterList.add(msgNew);
              }
            } else {
              bool flg = true;
              msgFilterList.forEach((msg) {
                if (flg &&
                    msg.messages.FromUser_ID != null &&
                    msg.messages.FromUser_ID == userId &&
                    msg.messages.ToUser_ID == messages.ToUser_ID) {
                  msg.messagesList.add(messages);
                  if (noSeen) {
                    msg.count++;
                  }
                  flg = false;
                }
              });
              if (flg) {
                msg msgNew = new msg(messages, noSeen ? 1 : 0);
                msgNew.messagesList.add(messages);
                msgFilterList.add(msgNew);
              }
            }
          }
        }
      });
      List<Messages> list = messagesList.reversed.toList();
      list.forEach((messages) {
        /*var fromUser_ID = messages.FromUser_ID;
          var toUser_ID = messages.ToUser_ID;*/
        if (messages.ParentUserCarAssignMessage_ID != null) {
          bool flg = true;
          msgFilterList.forEach((msg) {
            if (flg) {
              msg.messagesList.forEach((messageTemp) {
                if (flg &&
                    messages.ParentUserCarAssignMessage_ID ==
                        messageTemp.UserCarAssignMessage_ID) {
                  if ((messages.FromUser_ID == null ||
                          messages.FromUser_ID != userId) &&
                      (messages.IsMessageSeen == null ||
                          !messages.IsMessageSeen!)) {
                    msg.count++;
                  }
                  if (messages.CreateDate.isAfter(msg.messages.CreateDate)) {
                    msg.messages = messages;
                  }
                  flg = false;
                }
              });
              if (!flg) {
                msg.messagesList.add(messages);
              }
            }
          });
        }
      });
    }
    });

    //yield msgFilterList;
    _streamController.add(msgFilterList);

  }
}

class msg {
  late Messages messages;
  int count = 0;
  List<Messages> messagesList = [];

  msg(this.messages, this.count);
}
