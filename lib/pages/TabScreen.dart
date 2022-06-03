import 'dart:convert';
import 'dart:io';

import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/class/ThemeModel.dart';
import '/widgets/Home.dart';
import '/widgets/MainDrawer.dart';
import '/widgets/Scanner.dart';
import '../CommonFunction.dart';
import 'MessagesInbox.dart';

class TabScreen extends StatefulWidget {
  static const routeName = '/TabScreen';

  TabScreen() {}

  @override
  _TabScreen createState() => _TabScreen();
}

class _TabScreen extends State<TabScreen> {
  late List<Map<String, Object>> _pages;
  int _selectedPageIndex = 1;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String token = '';
  String count = '';
  var _loadedInitData = false;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Scanner(),
    Home(),
    //Registration(),
  ];

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
        getCountMessagesForUerNoSeen();
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('کارال'),
          centerTitle: true,
          leading: Stack(children: [
            IconButton(
                icon: Icon(
                  Icons.forward_to_inbox_rounded,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(MessagesInbox.routeName);
                }),
            if (count != '0' && count!='')
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  // color: Theme.of(context).accentColor,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).accentColor,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'BYekan',
                      fontSize: 10,
                    ),
                  ),
                ),
              )
          ]),
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
        body: DoubleBack(
            textStyle: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 12,
                color: Theme.of(context).secondaryHeaderColor),
            background: Theme.of(context).primaryColor,
            message: 'لطفا کلید بازگشت را دوباره فشار دهید',
            child: _widgetOptions.elementAt(_selectedPageIndex)),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white,
          selectedItemColor: Theme.of(context).accentColor,
          currentIndex: _selectedPageIndex,
          iconSize: 35,
          onTap: _selectPage,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.camera_alt,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: '',
            ),
          ],
        ),
        endDrawer: MainDrawer(),
      );
    });
  }

  Future<void> getCountMessagesForUerNoSeen() async {
    final uri = Uri.http('caralapp.ir:8085',
        '/api/userCarAssignMessage/getCountMessagesForUerNoSeen');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final response = await http.post(uri, headers: headers, body: '');
    if(response.statusCode==200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      int count = jsonResponse['data'][0]['count'];
      print('COUNT: $count.');
      setState(() {
        this.count = count.toString();
      });
    }
  }
}
