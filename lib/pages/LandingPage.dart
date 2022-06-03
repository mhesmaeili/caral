import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:pushe_flutter/pushe.dart';

import '../CommonFunction.dart';
import 'Activation.dart';
import 'MyWebView.dart';
import 'Privacy.dart';
import 'Rules.dart';

class LandingPage extends StatefulWidget {
  static const routeName = '/LandingPage';

  LandingPage() {}

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _mobileController = TextEditingController();

  void _submitData(BuildContext context) async {
    if (_mobileController.text.isEmpty) {
      CommonFunction.showSnackBar(
          'لطفا شماره موبایل خود را وارد نمایید', 2, context);
      return;
    } else if (_mobileController.text.length < 11 ||
        (_mobileController.text.length >= 2 &&
            !_mobileController.text.substring(0, 2).contains("09"))) {
      CommonFunction.showSnackBar('شماره وارد شده معتبر نمی باشد', 2, context);
      return;
    }

    final mobileNo = _mobileController.text;

    final uri = Uri.http('caralapp.ir:8085', '/api/auth/SendVerificationCode');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri,
        headers: headers,
        body: json.encode({
          'mobileNo': mobileNo,
        }));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['data'];
      var result = jsonResponse['result'];
      print('Response: $data.');
      if (result) {
        print(mobileNo);
        await Pushe.setUserPhoneNumber(mobileNo).then((value) {
          Navigator.of(context)
              .pushReplacementNamed(Activation.routeName, arguments: mobileNo);
        });
      } else {
        CommonFunction.showSnackBar(data.toString(), 5, context);
      }
    } else {
      CommonFunction.showSnackBar('خطا در برقراری ارتباط با سرور', 5, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*SvgPicture.asset(
                  'assets/images/login.svg',
                  fit: BoxFit.fill,
                ),*/
                SizedBox(height: 20),
                Text(
                  'جهت ورود لطفا شماره موبایل خود را وارد نمایید',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hoverColor: Colors.white,
                    hintText: 'شماره موبایل',
                    hintStyle: Theme.of(context).textTheme.subtitle1,
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  controller: _mobileController,
                  onSubmitted: (_) => _submitData(context),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 11,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 40,
                ),
                SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                        child: Text(
                          'دریافت کد',
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                        onPressed: () {
                          _submitData(context);
                        })),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' را می پذیرم',
                        style: TextStyle(
                          fontFamily: 'IRANSANS',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        child: Text(
                          'حریم خصوصی',
                          style: TextStyle(
                              fontFamily: 'IRANSANS',
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          /*Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => MyWebView(
                                title: 'حریم خصوصی',
                                selectedUrl:
                                'http://caralapp.ir/privacy',
                              )));*/
                          Navigator.of(context).pushNamed(Privacy.routeName);
                        },
                      ),
                      Text(
                        ' و ',
                        style: TextStyle(
                          fontFamily: 'IRANSANS',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        child: Text(
                          'قوانین',
                          style: TextStyle(
                              fontFamily: 'IRANSANS',
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(Rules.routeName);
                        },
                      ),

                      /*InkWell(
                          child: new Text(
                            'شرایط و قوانین',
                            style: TextStyle(
                                fontFamily: 'IRANSANS',
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () =>
                              launch('http://37.152.181.5:8084/rules')),*/
                      Text(
                        'با ثبت نام در کارال',
                        style: TextStyle(
                          fontFamily: 'IRANSANS',
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                /*ElevatedButton(
                    child: Text('developer'),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(TabScreen.routeName, arguments: '09126130975');
                    }),*/
              ],
            ),
          ),
        ),
      ),
    );
  }


}
