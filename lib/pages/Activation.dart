import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
//import 'package:telephony/telephony.dart';

import '../CommonFunction.dart';
import 'TabScreen.dart';


class Activation extends StatefulWidget {
  static const routeName = '/Activation';

  Activation() {}

  @override
  State<Activation> createState() => _ActivationState();
}

class _ActivationState extends State<Activation> {
  String _message = "";
  //final telephony = Telephony.instance;
  late String token;
  final _verifyCodeController = TextEditingController();

  /*onMessage(SmsMessage message) async {
    setState(() {
      if (message.address!.trim().contains('20000110220') ||
          message.address!.trim().contains('1000551451')) {
        _message = message.body ?? "";
        if (_message.toLowerCase().contains('caral') ||
            _message.toLowerCase().contains('کارال')) {
          _message = _message.split('شما')[1].trim();
        } *//*else {
          _message = "";
        }*//*
      }
    });
  }*/

  /*Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      *//*telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);*//*

      telephony.listenIncomingSms(
          onNewMessage: onMessage, listenInBackground: false);
    }

    if (!mounted) return;
  }*/

  void _submitData(BuildContext context) async {
    final mobile = ModalRoute.of(context)!.settings.arguments as String;
    if (_verifyCodeController.text.isEmpty || mobile.isEmpty) {
      CommonFunction.showSnackBar('لطفا کد تایید ارسال شده را وارد نمایید', 5, context);
      return;
    }
    final verifyCode = _verifyCodeController.text;

    final body = {
      'mobileNo': mobile,
      'code': verifyCode,
    };
    final jsonString = convert.json.encode(body);
    final uri = Uri.http('caralapp.ir:8085', '/api/auth/VerifyCode');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri, headers: headers, body: jsonString);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['data'];
      var result = jsonResponse['result'];
      print('Response: $jsonResponse.');
      if (result) {
        token = data[0]['token'].toString();
        CommonFunction.saveSharedPreferences('TOKEN_CARAL', token);
        String decode = CommonFunction.decrypt(token);
        Map<String, dynamic> payload = Jwt.parseJwt(decode);
        CommonFunction.saveSharedPreferences(
            'USER_ID', payload['id'].toString());
        CommonFunction.saveSharedPreferences(
            'USER_MOBILE', payload['mobileNo'].toString());
        CommonFunction.saveSharedPreferences(
            'USER_TYPE', payload['userType'].toString());
        Navigator.of(context)
            .pushReplacementNamed(TabScreen.routeName, arguments: mobile);
      } else {
        CommonFunction.showSnackBar(data.toString(), 5, context);
      }
    } else {
      CommonFunction.showSnackBar('خطا در برقراری ارتباط با سرور', 5, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('کارال'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                elevation: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'کد ارسالی از طریق پیامک را وارد نمایید',
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30, right: 20, left: 20),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'کد',
                          hintStyle: Theme.of(context).textTheme.subtitle1,
                          prefixIcon: Icon(Icons.app_registration),
                          border: OutlineInputBorder(),
                        ),
                        controller: _verifyCodeController..text = _message,
                        onSubmitted: (_) => _submitData(context),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1,
                        //maxLength: 5,
                        // onChanged: (val) => amountInput = val,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                  child: Text(
                                    'ورود',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ))),
                                  onPressed: () {
                                    _submitData(context);
                                  })),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: const Text('تغییر شماره موبایل'),
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                '/',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }
}
