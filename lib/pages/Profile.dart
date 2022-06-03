import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/HeaderMessage.dart';
import 'package:caralapp/model/MessageTemplates.dart';
import 'package:caralapp/model/NewUserAssign.dart';
import 'package:caralapp/model/UserCarAssignInfo.dart';
import 'package:caralapp/widgets/Registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../CommonFunction.dart';
import '../widgets/MainDrawer.dart';
import 'MessagesInbox.dart';

class Profile extends StatefulWidget {
  static const routeName = '/Profile';

  Profile() {}

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var name = "";
  var color = "";
  var brand = "";
  var plateNo = "";
  var plateType = 0;
  late UserCarAssignInfo userCarAssignInfo;
  var _loadedInitData = false;
  HeaderMessage? header;
  late List<MessageTemplates> messageTemplatesList = [];
  late NewUserAssign newUserAssign;
  late String token;
  late int userId;

  void userCarAssignInfoBasedOnQrCode(String url) async {
    newUserAssign = Provider.of<NewUserAssign>(context, listen: false);
    if (url != null && url.isNotEmpty) {
      var body = {
        'id': url.split("/")[4],
      };
      final jsonString = convert.json.encode(body);
      final uri = Uri.http('caralapp.ir:8085',
          '/api/userCarAssign/getUserCarAssignInfoBasedOnQrCode');
      final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      final response = await http.post(uri, headers: headers, body: jsonString);
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        print('info: $jsonResponse.');
        var result = jsonResponse['result'];
        if (result) {
          userCarAssignInfo =
              UserCarAssignInfo.fromJson(jsonResponse['data'][0]);
          if (mounted) {
            setState(() {
              name = userCarAssignInfo.Name;
              color = userCarAssignInfo.Color;
              brand = userCarAssignInfo.Brand;
              plateNo = userCarAssignInfo.PlateNo;
              plateType = userCarAssignInfo.PlateType;
            });
          }
        } else {
          body = {
            //'qrcode': 'c3dfb460-9773-4354-b804-83745545de6a',
            'qrcode': url.split("/")[4],
          };
          final jsonString = convert.json.encode(body);
          final uri = Uri.http('caralapp.ir:8085', '/api/qrLink/verifyQRCode');
          final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
          final response =
              await http.post(uri, headers: headers, body: jsonString);
          if (response.statusCode == 200) {
            var jsonResponse =
                convert.jsonDecode(response.body) as Map<String, dynamic>;
            if (jsonResponse['result']) {
              var qrCodeID = jsonResponse['data'][0]['QrCodeID'];
              print('Response: $qrCodeID.');
              newUserAssign.fillQrCode(qrCodeID);
              Navigator.of(context)
                  .pushReplacementNamed(Registration.routeName);
            } else {
              print('Response : خطا');
              Navigator.of(context).pushReplacementNamed('/');
            }
          }
        }
      }
    }
  }

  void messageTemplates() async {
    final uri = Uri.http(
        'caralapp.ir:8085', '/api/messageTemplate/getMessageTemplates');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      //var header = HeaderMessage.fromJson(convert.jsonDecode(response.body));
      //var tagObjsJson = convert.jsonDecode(response.body)['data'];
      final parsed = convert
          .jsonDecode(response.body)['data']
          .cast<Map<String, dynamic>>();
      List<MessageTemplates> list = parsed
          .map<MessageTemplates>((json) => MessageTemplates.fromJson(json))
          .toList();
      if (mounted) {
        setState(() {
          messageTemplatesList = list.where((element) {
            return element.ParentMessageTemplate_ID == null;
          }).toList();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
      });
      CommonFunction.getSharedPreferences('USER_ID').then((value) {
        if (value.isNotEmpty) {
          userId = int.parse(value);
        }
      });
      final url = ModalRoute.of(context)!.settings.arguments as String;
      userCarAssignInfoBasedOnQrCode(url);
      messageTemplates();
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text("کارال"),
        centerTitle: true,
      ),
      body: plateType != 0
          ? SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    elevation: 20,
                    //shadowColor: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          brand,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          color,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (plateType != 0)
                            ? plateType == 2
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/images/plate.png',
                                          fit: BoxFit.fill,
                                          width: 290,
                                          height: 60,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 35),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(0, 2)
                                                    : '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 12, left: 5),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(2, 3)
                                                    : "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 5),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(3, 6)
                                                    : '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 40),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(6, 8)
                                                    : '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: SvgPicture.asset(
                                          'assets/images/FreeZonePlate.svg',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 52),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(0, 5)
                                                    : '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, left: 6),
                                            child: Center(
                                              child: Text(
                                                plateNo.isNotEmpty
                                                    ? plateNo.substring(5, 7)
                                                    : "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                            : Text(''),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Text(
                            'جهت ارسال پیغام به راننده بر روی گزینه های زیر کلیک کنید',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: 'IRANSANS',
                                fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        (messageTemplatesList != null &&
                                messageTemplatesList.isNotEmpty)
                            ? ListView.builder(
                                shrinkWrap: true,
                                //scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                itemCount: messageTemplatesList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .shadowColor,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),color:  Theme.of(context)
                                            .shadowColor),
                                        padding: EdgeInsets.all(8),
                                        height: 50,
                                        //color: Theme.of(context).accentColor,
                                        child: Text(
                                          messageTemplatesList[index].Message,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3,
                                        ),
                                      ),
                                    ),
                                    onTap: () => sendMessages(
                                        messageTemplatesList[index]),
                                  );
                                })
                            : SizedBox(
                                width: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    //strokeWidth: 10,
                                    color: Theme.of(context).accentColor,
                                    semanticsLabel: 'در حال بارگذاری',
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )),
            )
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

  sendMessages(MessageTemplates messageTemplate) async {
    final uri =
        Uri.http('caralapp.ir:8085', '/api/userCarAssignMessage/saveMessage');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final body = {
      'userCarAssign_id': userCarAssignInfo.UserCarAssign_ID,
      'fromUser_id': userId,
      'toUser_id': userCarAssignInfo.User_ID,
      'messageTemplate_id': messageTemplate.ID,
      'messageNo': messageTemplate.MessageNo,
      'messageType': 1,
      'parentUserCarAssignMessage_id': null
    };
    final response = await http.post(uri,
        headers: headers,
        body: convert.json.encode(body));
    print(response);
    print(response.statusCode);
    print(body);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['data'];
      var result = jsonResponse['result'];
      if (result) {
        CommonFunction.showSnackBar(messageTemplate.Message + " ارسال شد", 3,context);
        Navigator.of(context).pushReplacementNamed(MessagesInbox.routeName);
      } else {
        CommonFunction.showSnackBar(data.toString(), 3,context);
      }
    } else {
      CommonFunction.showSnackBar('خطا در برقراری ارتباط با سرور', 3,context);
    }
  }
}

/*InkWell(
                      child: new Text(
                        'ارسال پیام به راننده',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      onTap: () => launch(url)),
                  SizedBox(
                    height: 20,
                  ),*/
