import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/class/ThemeModel.dart';
import '/widgets/Home.dart';
import '/widgets/MainDrawer.dart';
import '/widgets/Scanner.dart';
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

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Scanner(),
    Home(),
    //Registration(),
  ];

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
          leading: IconButton(
              icon: Icon(
                Icons.forward_to_inbox_rounded,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MessagesInbox.routeName);
              }),
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
}
