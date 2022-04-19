import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> imgList = ['assets/images/10.jpg', 'assets/images/11.jpg'];

final themeMode = ValueNotifier(2);

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  var _loadedInitData = false;
  String number = '';
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      number = '989903838648';
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    final uri = Uri.http(
        'caralapp.ir:8085', '/api/downloadApp/getLatestVersionOfAppByType');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri,
        headers: headers,
        body: json.encode({
          'appType': Platform.isAndroid ? 1 : 2,
        }));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var data = jsonResponse['data'];
      var result = jsonResponse['result'];
      print('Response: $data.');
      if (result) {
        String releaseNo = data[0]['ReleaseNo'];
        _initPackageInfo(releaseNo);
      }
    }
  }

  Future<void> _initPackageInfo(String releaseNo) async {
    final info = await PackageInfo.fromPlatform();
    _packageInfo = info;
    print(_packageInfo.version.compareTo(releaseNo));
    if (_packageInfo.version.compareTo(releaseNo) < 0) {
      _showMyDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
            child: CarouselSlider.builder(
          options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: false,
            viewportFraction: 1,
          ),
          itemCount: (imgList.length / 2).round(),
          itemBuilder: (context, index, realIdx) {
            final int first = index * 2;
            final int second = first + 1;
            return Row(
              children: [first, second].map((idx) {
                return Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.asset(
                        imgList[idx],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        )),
        Visibility(
          //userType: Driver
          visible: true,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'همین حالا برچسبت رو سفارش بده',
              style: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 23,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Visibility(
          visible: true,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () async => await launch(
                  "https://wa.me/${number}?text=سلام، من تمایل دارم برچسب کارال رو برای خودروی خودم تهیه کنم."),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ))),
              child: Text('ثبت سفارش',
                  style: TextStyle(
                    fontFamily: 'IRANSANS',
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            elevation: 5,
            title: const Text(
              'منقضی شدن نرم افزار',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'IRANSANS'),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  const Text(
                    'نسخه نرم افزار منقضی شده است',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontFamily: 'IRANSANS', color: Colors.black),
                  ),
                  const Text(
                    'نسخه جدید را دانلود و نصب نمایید',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontFamily: 'IRANSANS', color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              InkWell(
                  child: new Text(
                    'دانلود نرم افزار',
                    style: TextStyle(
                        fontFamily: 'IRANSANS',
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => launch(Platform.isAndroid
                      ? 'http://caralapp.ir:8085/api/downloadApp/androidCaralApp.apk'
                      : 'http://caralapp.ir:8085/api/downloadApp/iosCaralApp.ipa')),
              TextButton(
                child: const Text(
                  'خروج از نرم افزار',
                  style: TextStyle(fontFamily: 'IRANSANS'),
                ),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
