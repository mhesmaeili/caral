import 'dart:async';

import 'package:caralapp/pages/ReplyToMessages.dart';
import 'package:connectivity/connectivity.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:pushe_flutter/pushe.dart';

import 'CommonFunction.dart';
import 'class/ThemeModel.dart';
import 'model/Messages.dart';
import 'model/NewUserAssign.dart';
import 'pages/Activation.dart';
import 'pages/LandingPage.dart';
import 'pages/MessagesInbox.dart';
import 'pages/MessagesInboxComplete.dart';
import 'pages/Privacy.dart';
import 'pages/Profile.dart';
import 'pages/Rules.dart';
import 'pages/Support.dart';
import 'pages/TabScreen.dart';
import 'widgets/Registration.dart';
import 'widgets/Scanner.dart';
import 'pages/UserInformation.dart';

bool _initialUriIsHandled = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeModel(),
        ),
        ChangeNotifierProvider.value(value: NewUserAssign()),
        //ChangeNotifierProvider.value(value: Messages()),
      ],
      child: ChangeNotifierProvider(
        create: (_) => ThemeModel(),
        child: Consumer(builder: (context, ThemeModel themeNotifier, child) {
          return MaterialApp(
            title: 'کارال',
            theme: themeNotifier.isDark ? _darkTheme() : _lightTheme(),
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (ctx) => MyHomePage(),
              TabScreen.routeName: (ctx) => TabScreen(),
              Activation.routeName: (ctx) => Activation(),
              LandingPage.routeName: (ctx) => LandingPage(),
              Registration.routeName: (ctx) => Registration(),
              Profile.routeName: (ctx) => Profile(),
              Scanner.routeName: (ctx) => Scanner(),
              MessagesInbox.routeName: (ctx) => MessagesInbox(),
              ReplyToMessages.routeName: (ctx) => ReplyToMessages(),
              MessagesInboxComplete.routeName: (ctx) => MessagesInboxComplete(),
              UserInformation.routeName: (ctx) => UserInformation(),
              Rules.routeName: (ctx) => Rules(),
              Privacy.routeName: (ctx) => Privacy(),
              Support.routeName: (ctx) => Support(),
            },
          );
        }),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;
  var con;

  StreamSubscription? _sub;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool? tokenExpire;

  @override
  void initState() {
    super.initState();

    getToken('TOKEN_CARAL').then((value) {
      if (value.isNotEmpty) {
        String decode = CommonFunction.decrypt(value);
        if (!Jwt.isExpired(decode)) {
          _handleIncomingLinks();
          _handleInitialUri().then((value) {
            if(_initialUri!=null)
              Navigator.of(context).pushReplacementNamed(Profile.routeName, arguments: _initialUri.toString());
            else
              Navigator.of(context).pushReplacementNamed(TabScreen.routeName);
          });
        } else {
          setState(() {
            tokenExpire = true;
          });
        }
      } else {
        setState(() {
          tokenExpire = true;
        });
      }
    });

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    Pushe.setNotificationListener(
        onReceived: (notificationData) { /* Your code for foreground */ },
        onClicked: (notificationData) { /* Your code for foreground */ },
        onDismissed: (notificationData) { /* Your code for foreground */ },
        onButtonClicked: (notificationData) { /* Your code for foreground */ },
        onCustomContentReceived: (customContent) { /* Your code for foreground */ },
        // For background
        onBackgroundNotificationReceived: _onBackgroundMessageReceived // TOP LEVEL function
    );
  }

  Future<String> getToken(String key) async {
    var pref = await SharedPreferences.getInstance();
    var token = pref.getString(key) ?? '';
    return token;
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = 'none');
        break;
      default:
        setState(() => _connectionStatus = 'none');
        break;
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  void didChangeDependencies() {
    //checkConnection();
    super.didChangeDependencies();
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile) {
        con = 'ok';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        con = 'ok';
      } else {
        con = 'notOk';
      }
      print(con);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _sub?.cancel();
    super.dispose();
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          //Navigator.of(context).pushReplacementNamed(Profile.routeName, arguments: uri.toString());
          print('got initial uri: $uri');
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('کارال'),
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(
                  themeNotifier.isDark
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
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
            child: _connectionStatus != 'none'
                ? tokenExpire != null && tokenExpire == true
                    ? LandingPage()
                    : Center(
                        child: SizedBox(
                          width: 40,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                            semanticsLabel: 'در حال بارگذاری',
                          ),
                        ),
                      )
                : Center(
                    child: Text(
                    'برای استفاده از کارال به اینترنت متصل شوید',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ))),
      );
    });
  }
}

//FE9BB3,C0A4FF,41DEB7,9AB2FF
//AFF4F9,E3C7FF,BAF5C0,FFD83C
//FFC9BD,EE8750,B6B34B,99ACCD
ThemeData _lightTheme() {
  return ThemeData(
    primarySwatch: MaterialColor(
      //0xFFC0A4FF,
      0xFF007AFF,
      <int, Color>{
        50: Color(0xFF5AC8FA),
        100: Color(0xFF007AFF),
        200: Color(0xFF5856D6),
        300: Color(0xFF007AFF),
        400: Color(0xFF007AFF),
        500: Color(0xFF007AFF),
        600: Color(0xFF007AFF),
        700: Color(0xFF007AFF),
        800: Color(0xFF007AFF),
        900: Color(0xFF007AFF),
      },
    ),
    accentColor: Color(0xFF41DEB7),
    shadowColor: Color(0xFF5856D6),
    secondaryHeaderColor: Colors.white,
    primaryColor: Color(0xFF007AFF),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF5AC8FA), // Button color
        onPrimary: Colors.white, // Text color
      ),
    ),

    iconTheme: IconThemeData(color: Color(0xFF41DEB7)),

    fontFamily: 'IRANSANS',
    textTheme: ThemeData.light().textTheme.copyWith(
          subtitle1: TextStyle(fontFamily: 'IRANSANS', color: Colors.black26),
          subtitle2: TextStyle(
            fontFamily: 'IRANSANS',
          ),
          caption: TextStyle(
            fontFamily: 'BYekan',
            //color: Color(0xFF171923),
            //fontSize: 22,
            /*fontWeight: FontWeight.bold,
              fontSize: 18,*/
          ),
          headline6: TextStyle(
            fontFamily: 'IRANSANS',
            //color: Colors.blueGrey,
            /*fontWeight: FontWeight.bold,
              fontSize: 18,*/
          ),
          headline5: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 40,
            //color: Color(0xFF41DEB7),
          ),
          headline4: TextStyle(
            fontFamily: 'IRANSANS',
            //color: Colors.blueGrey[300],
          ),
          headline3: TextStyle(
            fontFamily: 'IRANSANS',
            fontSize: 15,
            color: Colors.white,
            //color: Colors.blueGrey[300],
          ),
          bodyText1: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 22,
          ),
          bodyText2: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 30,
            //color: Color(0xFF41DEB7),
          ),
          button: TextStyle(color: Colors.white),
        ),
    /*appBarTheme: AppBarTheme(
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      )*/
  );
}

//0xFFC31331,0xFFCBB2AB,0xFFF79E1B,0xFF171923
ThemeData _darkTheme() {
  return ThemeData(
    primarySwatch: MaterialColor(
      0xFFC31331,
      <int, Color>{
        50: Color(0xFFC31331),
        100: Color(0xFFC31331),
        200: Color(0xFFC31331),
        300: Color(0xFFC31331),
        400: Color(0xFFC31331),
        500: Color(0xFFC31331),
        600: Color(0xFFC31331),
        700: Color(0xFFC31331),
        800: Color(0xFFC31331),
        900: Color(0xFFC31331),
      },
    ),
    accentColor: Color(0xFFF79E1B),
    secondaryHeaderColor: Colors.white,
    primaryColor: Color(0xFFC31331),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF86061B), // Button color
        onPrimary: Colors.white, // Text color
      ),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Color(0xFF171923),
    cardColor: Color(0xFFCECECE),
    shadowColor: Color(0xFF86061B),
    scaffoldBackgroundColor: Color(0xFF171923),
    dialogBackgroundColor: Color(0xFFCECECE),
    fontFamily: 'IRANSANS',
    textTheme: ThemeData.light().textTheme.copyWith(
          subtitle1: TextStyle(
            fontFamily: 'IRANSANS',
            color: Colors.white60,
          ),
          subtitle2: TextStyle(
            fontFamily: 'IRANSANS',
            color: Color(0xFF171923),
          ),
          caption: TextStyle(
            fontFamily: 'BYekan',
            color: Color(0xFF171923),
          ),
          headline6: TextStyle(
            fontFamily: 'IRANSANS',
            //color: Colors.white,
          ),
          headline5: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 40,
            //color: Color(0xFFC31331),
          ),
          headline4: TextStyle(
            fontFamily: 'IRANSANS',
            color: Colors.white,
          ),
          headline3: TextStyle(
            fontFamily: 'IRANSANS',
            fontSize: 15,
            color: Colors.white,
          ),
          bodyText1: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 22,
            color: Color(0xFF171923),
          ),
          bodyText2: TextStyle(
            fontFamily: 'BYekan',
            fontSize: 30,
            //color: Color(0xFFC31331),
          ),
          button: TextStyle(color: Colors.white),
        ), /*appBarTheme: AppBarTheme(
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'IRANSANS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
      )*/
  );
}

_onBackgroundMessageReceived(String eventType, dynamic message) {
  switch(eventType) {
    case Pushe.notificationReceived: // اعلان دریافت شده
      var notification = NotificationData.fromDynamic(message);
    // Notification received

      break;

    case Pushe.notificationDismissed: // اعلان رد شده

    // Notification dismissed

      break;
    case Pushe.notificationButtonClicked: // دکمه‌ای از اعلان کلیک شده

    // Notification button clicked

      break;
    case Pushe.customContentReceived: // جیسون دلخواه دریافت شده

    // Notification custom content (json) received

      break;
  }
}
