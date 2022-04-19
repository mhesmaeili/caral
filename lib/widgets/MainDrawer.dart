import 'package:caralapp/model/NewUserAssign.dart';
import 'package:caralapp/widgets/Registration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../CommonFunction.dart';
import '../pages/TabScreen.dart';

class MainDrawer extends StatefulWidget {
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _loadedInitData = false;
  late String mobileNo = "";

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('USER_MOBILE').then((value) {
        setState(() {
          mobileNo = value;
        });
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            padding: EdgeInsets.only(top: 20, right: 25, left: 25),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mobileNo,
                  style: TextStyle(
                      fontFamily: 'BYekan',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white
                  ),
                ),
                Text(
                  'کارال',
                  style: TextStyle(
                      fontFamily: 'IRANSANS',
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Theme.of(context).secondaryHeaderColor),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            trailing: Icon(
              Icons.home,
              size: 22,
            ),
            title: Text(
              'خانه',
              style: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(TabScreen.routeName);
            },
          ),
          /*ListTile(
            trailing: Icon(
              Icons.app_registration,
              size: 22,
            ),
            title: Text(
              'ثبت نام',
              style: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            onTap: () {
              NewUserAssign newUserAssign =
                  Provider.of<NewUserAssign>(context, listen: false);
              newUserAssign = NewUserAssign();
              //_scaffoldKey.currentState!.dr();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Registration.routeName);
            },
          ),*/
          ListTile(
            trailing: Icon(
              Icons.exit_to_app,
              size: 22,
            ),
            title: Text(
              'خروج',
              style: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            onTap: () {
              CommonFunction.saveSharedPreferences("TOKEN_CARAL", '')
                  .then((value) {
                //Navigator.of(context).pop();
                //Navigator.of(context).pushNamed(Registration.routeName);
                //Navigator.of(context).pushReplacementNamed('/');
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
              });
            },
          ),
        ],
      ),
    );
  }
}
