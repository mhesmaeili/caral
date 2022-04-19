import 'dart:developer';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:caralapp/model/NewUserAssign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '/pages/Profile.dart';
import 'Registration.dart';
//import 'package:url_launcher/url_launcher.dart';

class Scanner extends StatefulWidget {
  static const routeName = '/Scanner';

  const Scanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Scanner();
}

class _Scanner extends State<Scanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late NewUserAssign newUserAssign;
  String page = "home";

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    newUserAssign = Provider.of<NewUserAssign>(context, listen: false);
    if (ModalRoute.of(context)!.settings.arguments != null) {
      if (ModalRoute.of(context)!.settings.arguments as String == "register") {
        page = "register";
      }
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /*if (result != null)
                    //if (page == "home")
                    //{
                    new InkWell(
                      child: page == "home"
                          ? new Text('مشاهده پروفایل',
                              style: Theme.of(context).textTheme.headline4)
                          : new Text('ثبت کد',
                              style: Theme.of(context).textTheme.headline4),
                      onTap: () => //launch('${result!.code}')
                          page == "home"
                              ? Navigator.of(context).pushNamed(
                                  Profile.routeName,
                                  arguments: '${result!.code}')
                              : fill(result!.code),
                    )
                  else
                    const Text(''),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Icon(
                                  snapshot.data == false
                                      ? Icons.flash_off
                                      : Icons.flash_on,
                                  size: 20);
                            },
                          ),
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.rotate_left,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          icon: Icon(
                            Icons.pause_circle_outline,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: IconButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          icon: Icon(
                            Icons.not_started,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).accentColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }
  bool scanned = false;
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (!scanned) {
          //controller.pauseCamera();
          scanned = true;
          /*page == "home"
              ?
              Navigator.of(context)
                  .pushNamed(Profile.routeName, arguments: '${result!.code}').then((value) => scanned = false)
              :*/ fill(result!.code);
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void fill(String? code) async{
    print('scanneer : ' + code!);
    final body = {
      //'qrcode': 'c3dfb460-9773-4354-b804-83745545de6a',
      'qrcode': code.split("/")[4],
    };
    final jsonString = convert.json.encode(body);
    final uri = Uri.http('caralapp.ir:8085', '/api/qrLink/verifyQRCode');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri, headers: headers, body: jsonString);
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      if(jsonResponse['result']) {
        var qrCodeID = jsonResponse['data'][0]['QrCodeID'];
        print('jsonResponse: $jsonResponse.');
        newUserAssign.fillQrCode(qrCodeID);
        Navigator.of(context)
            .pushNamed(Registration.routeName).then((value) => scanned = false);
      } else{
        print('profileLoading');
        Navigator.of(context)
            .pushNamed(Profile.routeName, arguments: '${result!.code}').then((value) => scanned = false);
      }
    }
  }
}
