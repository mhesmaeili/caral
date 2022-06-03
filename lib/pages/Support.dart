import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../ConstVariable.dart';
import 'package:url_launcher/url_launcher.dart';


class Support extends StatelessWidget {
  static const routeName = '/Support';
  String number = ConstVariable.MOBILE_NUMBER;
  Privacy() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('پشتیبانی'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 30,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async => await launch(
                      "https://wa.me/${number}?text="),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                  child: Text('ارتباط پیامی',
                      style: TextStyle(
                        fontFamily: 'IRANSANS',
                      )),
                ),
                ElevatedButton(
                  onPressed: () async => await launch('tel:+${number}'),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                  child: Text('ارتباط صوتی',
                      style: TextStyle(
                        fontFamily: 'IRANSANS',
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
