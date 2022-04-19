import 'dart:convert' as convert;
import 'dart:io';

import 'package:caralapp/model/Brands.dart';
import 'package:caralapp/model/GeneralInfo.dart';
import 'package:caralapp/model/Models.dart';
import 'package:caralapp/model/NewUserAssign.dart';
import 'package:caralapp/model/VehicleColors.dart';
import 'package:caralapp/widgets/MainDrawer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CommonFunction.dart';

class Registration extends StatefulWidget {
  static const routeName = '/Registration';

  Registration() {}

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  var _loadedInitData = false;
  List<Models> vehicles = [];
  List<Brands> brands = [];
  List<Models> models = [];
  List<VehicleColors> vehiclesColors = [];
  List<GeneralInfo> plateTypes = [];
  late Brands brandNamevalue;

  late Models modelNamevalue = new Models(0, 0, 'انتخاب مدل');
  late VehicleColors vehicleColorValue = new VehicleColors(0, 'انتخاب رنگ');
  late GeneralInfo plateTypeValue = new GeneralInfo(0, 0, 'نوع پلاک', 0, '');
  String plateValue2 = 'الف';

  late AnimationController controller;

  final _form = GlobalKey<FormState>();
  final familyFocusNode = FocusNode();
  final mobileFocusNode = FocusNode();
  final brandFocusNode = FocusNode();
  final plate1FocusNode = FocusNode();
  final plate2FocusNode = FocusNode();
  final plate3FocusNode = FocusNode();
  final plate4FocusNode = FocusNode();

  late NewUserAssign newUserAssign;

  late String token;

  void _saveForm() async {
    if (!_form.currentState!.validate()) {
      print('notValid');
      return;
    }
    print('valid');
    _form.currentState!.save();

    print(newUserAssign);
    if (newUserAssign.plateType == 2) {
      newUserAssign.plateNo = newUserAssign.plateNo1 +
          newUserAssign.plateNo2 +
          newUserAssign.plateNo3 +
          newUserAssign.plateNo4;
    } else {
      newUserAssign.plateNo = newUserAssign.plateNo1 + newUserAssign.plateNo2;
    }

    if (newUserAssign.plateType == 2) {
      if (newUserAssign.plateNo.length < 8) {
        CommonFunction.showSnackBar('پلاک را وارد کنید', 4, context);
        return;
      }
    } else {
      if (newUserAssign.plateNo.length < 7) {
        CommonFunction.showSnackBar('پلاک را وارد کنید', 4, context);
        return;
      }
    }

    if (newUserAssign.qrCode_Id == null || newUserAssign.qrCode_Id == 0) {
      CommonFunction.showSnackBar('برچسب خود را اسکن کنید', 4, context);
      return;
    }

    print('token : ' + token);

    final body = {
      'firstName': newUserAssign.firstName,
      'lastName': newUserAssign.lastName,
      'mobileNo': newUserAssign.mobileNo,
      'userType_Id': 3,
      'password': '',
      'userCode': newUserAssign.mobileNo,
      'address': '',
      'vehicleModel_Id': newUserAssign.vehicleModel_Id,
      'vehicleColor_Id': newUserAssign.vehicleColor_Id,
      'qrCode_Id': newUserAssign.qrCode_Id,
      'plateNo': newUserAssign.plateNo,
      'plateType': newUserAssign.plateType
    };
    print('input : ' + body.toString());
    final jsonString = convert.json.encode(body);
    final uri =
        Uri.http('caralapp.ir:8085', '/api/userCarAssign/saveNewAssignInfo');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token
    };

    final response = await http.post(uri, headers: headers, body: jsonString);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse);
      var result = jsonResponse['result'];
      if (result) {
        var outVal = jsonResponse['data'][0]['OutVal'];
        if (outVal) {
          newUserAssign = NewUserAssign();
          Navigator.of(context).pop();
          CommonFunction.showSnackBar("اطلاعات با موفقیت ثبت شد", 5, context);
        } else {
          CommonFunction.showSnackBar("خطا در ثبت اطلاعات", 5, context);
        }
      } else {
        CommonFunction.showSnackBar("خطا در ثبت اطلاعات", 5, context);
      }
    } else {
      CommonFunction.showSnackBar("خطا در ثبت اطلاعات", 5, context);
    }
  }

  Future<String> getToken(String key) async {
    var pref = await SharedPreferences.getInstance();
    var token = pref.getString(key) ?? '';
    return token;
  }

  @override
  void dispose() {
    familyFocusNode.dispose();
    mobileFocusNode.dispose();
    brandFocusNode.dispose();
    plate1FocusNode.dispose();
    plate2FocusNode.dispose();
    plate3FocusNode.dispose();
    plate4FocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      getToken('TOKEN_CARAL').then((value) {
        token = value;
        loadAllVehicles();
        loadVehiclesColor();
        loadPlateType();
      });
      _loadedInitData = true;
    }

    /*if (ModalRoute.of(context)!.settings.arguments != null) {
      var arguments = ModalRoute.of(context)!.settings.arguments;

      if (arguments is Map<String, String>) {
        var map = arguments as Map<String, String>;
        if (map["qrCode"] != null) {
          setState(() {
            newUserAssign.qrCode_Id = int.parse(arguments["qrCode"].toString());
          });
        }
      }
    }*/
    super.didChangeDependencies();
  }

  void loadAllVehicles() async {
    final uri = Uri.http('caralapp.ir:8085', '/api/vehicle/getAllVehicles');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token
    };
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final parsed = convert
          .jsonDecode(response.body)['data']
          .cast<Map<String, dynamic>>();
      List<Models> vehicleList =
          parsed.map<Models>((json) => Models.fromJson(json)).toList();
      List<Brands> brandList =
          parsed.map<Brands>((json) => Brands.fromJson(json)).toList();

      setState(() {
        vehicles = vehicleList;
        brands = brandList.toSet().toList();
        models = vehicles.where((tx) {
          return tx.Brand_ID == -1;
        }).toList();
        brandNamevalue = new Brands(0, 'انتخاب برند');
      });
    }
  }

  void loadVehiclesColor() async {
    final uri =
        Uri.http('caralapp.ir:8085', '/api/vehicleColor/getVehicleColors');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token
    };
    final response = await http.get(uri, headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final parsed = convert
          .jsonDecode(response.body)['data']
          .cast<Map<String, dynamic>>();
      List<VehicleColors> list = parsed
          .map<VehicleColors>((json) => VehicleColors.fromJson(json))
          .toList();
      setState(() {
        vehiclesColors = list;
      });
    }
  }

  void loadPlateType() async {
    final uri = Uri.http('caralapp.ir:8085', '/api/generalInfo/getPlateTypes');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    final response = await http.get(uri, headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final parsed = convert
          .jsonDecode(response.body)['data']
          .cast<Map<String, dynamic>>();
      List<GeneralInfo> list = parsed
          .map<GeneralInfo>((json) => GeneralInfo.fromJson(json))
          .toList();
      setState(() {
        plateTypes = list;
        plateTypeValue = plateTypes.elementAt(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    newUserAssign = Provider.of<NewUserAssign>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("کارال"),
        centerTitle: true,
      ),
      body: (brands != null && brands.isNotEmpty)
          ? Card(
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'نام',
                            hintStyle: Theme.of(context).textTheme.subtitle1),
                        textAlign: TextAlign.right,
                        maxLength: 20,
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(familyFocusNode);
                        },
                        onSaved: (value) {
                          newUserAssign.firstName = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'نام را وارد کنید';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'نام خانوادگی',
                            hintStyle: Theme.of(context).textTheme.subtitle1),
                        textAlign: TextAlign.right,
                        maxLength: 35,
                        keyboardType: TextInputType.text,
                        focusNode: familyFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(mobileFocusNode);
                        },
                        onSaved: (value) {
                          newUserAssign.lastName = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'نام خانوادگی را وارد کنید';
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.subtitle2,
                        // onChanged: (val) => amountInput = val,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'شماره موبایل',
                            hintStyle: Theme.of(context).textTheme.subtitle1),
                        textAlign: TextAlign.left,
                        maxLength: 11,
                        keyboardType: TextInputType.number,
                        focusNode: mobileFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(brandFocusNode);
                        },
                        onSaved: (value) {
                          newUserAssign.mobileNo = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'شماره موبایل را وارد کنید';
                          }
                          if (int.tryParse(value) == null) {
                            return 'مقدار عددی وارد شود';
                          }
                          if (value.toString().length < 11 ||
                              (value.toString().length >= 2 &&
                                  !value
                                      .toString()
                                      .substring(0, 2)
                                      .contains("09"))) {
                            return ('شماره وارد شده معتبر نمی باشد');
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(height: 20),
                      DropdownSearch<Brands>(
                        mode: Mode.DIALOG,
                        dropdownSearchTextAlignVertical:
                            TextAlignVertical.center,
                        focusNode: brandFocusNode,
                        showSearchBox: true,
                        dropdownSearchTextAlign: TextAlign.center,
                        items: brands,
                        onChanged: (Brands? Value) {
                          setState(() {
                            brandNamevalue = Value!;
                            modelNamevalue = new Models(0, 0, 'انتخاب مدل');
                            models = vehicles.where((tx) {
                              return tx.Brand_ID == brandNamevalue.Brand_ID;
                            }).toList();
                          });
                        },
                        onSaved: (value) {},
                        validator: (value) {
                          if (value == null ||
                              value.Brand_ID == null ||
                              value.Brand_ID == 0) {
                            return 'برند را انتخاب کنید';
                          }
                          return null;
                        },
                        selectedItem: brandNamevalue,
                      ),
                      SizedBox(height: 5),
                      DropdownSearch<Models>(
                          mode: Mode.DIALOG,
                          showSearchBox: true,
                          items: models,
                          onChanged: (Models? Value) {
                            setState(() {
                              modelNamevalue = Value!;
                            });
                          },
                          onSaved: (value) {
                            newUserAssign.vehicleModel_Id = value!.Model_ID;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.Model_ID == null ||
                                value.Model_ID == 0) {
                              return 'مدل را انتخاب کنید';
                            }
                            return null;
                          },
                          selectedItem: modelNamevalue),
                      SizedBox(height: 5),
                      DropdownSearch<VehicleColors>(
                          mode: Mode.DIALOG,
                          showSearchBox: true,
                          items: vehiclesColors,
                          onChanged: (VehicleColors? Value) {
                            setState(() {
                              vehicleColorValue = Value!;
                            });
                          },
                          onSaved: (value) {
                            newUserAssign.vehicleColor_Id = value!.Color_ID;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.Color_ID == null ||
                                value.Color_ID == 0) {
                              return 'رنگ را انتخاب کنید';
                            }
                            return null;
                          },
                          selectedItem: vehicleColorValue),
                      SizedBox(height: 5),
                      DropdownSearch<GeneralInfo>(
                        mode: Mode.DIALOG,
                        items: plateTypes,
                        onChanged: (GeneralInfo? Value) {
                          setState(() {
                            plateTypeValue = Value!;
                            newUserAssign.plateNo1 = "";
                            newUserAssign.plateNo2 = "";
                            newUserAssign.plateNo3 = "";
                            newUserAssign.plateNo4 = "";
                          });
                        },
                        selectedItem: plateTypeValue,
                        onSaved: (value) {
                          newUserAssign.plateType = value!.GeneralCode;
                        },
                      ),
                      plateTypeValue.GeneralCode == 2
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, top: 30),
                                      child: SizedBox(
                                        width: 50,
                                        child: Center(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            textAlign: TextAlign.center,
                                            maxLength: 2,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              newUserAssign.plateNo1 = value!;
                                            },
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      plate3FocusNode);
                                            },
                                            focusNode: plate1FocusNode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: SizedBox(
                                        width: 80,
                                        child: DropdownSearch<String>(
                                          mode: Mode.DIALOG,
                                          items: [
                                            'الف',
                                            'ب',
                                            'ت',
                                            'ج',
                                            'د',
                                            'س',
                                            'ص',
                                            'ط',
                                            'ع',
                                            'ق',
                                            'ک',
                                            'گ',
                                            'ل',
                                            'م',
                                            'ن',
                                            'و',
                                            'ه',
                                            'ی',
                                            'S',
                                            'D'
                                          ],
                                          onChanged: (String? Value) {
                                            setState(() {
                                              plateValue2 = Value!;
                                            });
                                          },
                                          selectedItem: plateValue2,
                                          onSaved: (value) {
                                            newUserAssign.plateNo2 = value!;
                                          },
                                          focusNode: plate2FocusNode,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: SizedBox(
                                        width: 65,
                                        child: Center(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            textAlign: TextAlign.center,
                                            maxLength: 3,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              newUserAssign.plateNo3 = value!;
                                            },
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      plate4FocusNode);
                                            },
                                            focusNode: plate3FocusNode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 30),
                                      child: SizedBox(
                                        width: 55,
                                        child: Center(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                            textAlign: TextAlign.center,
                                            maxLength: 2,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              newUserAssign.plateNo4 = value!;
                                            },
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                            focusNode: plate4FocusNode,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : plateTypeValue.GeneralCode == 1
                              ? Stack(
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
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 65, top: 30),
                                          child: SizedBox(
                                            width: 88,
                                            child: Center(
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5))),
                                                textAlign: TextAlign.center,
                                                maxLength: 5,
                                                keyboardType:
                                                    TextInputType.number,
                                                onSaved: (value) {
                                                  newUserAssign.plateNo1 =
                                                      value!;
                                                },
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                                onFieldSubmitted: (_) {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          plate2FocusNode);
                                                },
                                                focusNode: plate1FocusNode,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 30),
                                          child: SizedBox(
                                            width: 43,
                                            child: Center(
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5))),
                                                textAlign: TextAlign.center,
                                                maxLength: 2,
                                                keyboardType:
                                                    TextInputType.number,
                                                onSaved: (value) {
                                                  newUserAssign.plateNo2 =
                                                      value!;
                                                },
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                                focusNode: plate2FocusNode,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              : Text(''),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /*IconButton(
                          icon: Icon(Icons.camera_alt,size: 25,),
                          onPressed: () {
                            //Scanner();
                            Navigator.of(context).pushNamed(Scanner.routeName,
                                arguments: "register");
                          }),*/
                            Text(
                              newUserAssign.qrCode_Id != 0
                                  ? newUserAssign.qrCode_Id.toString()
                                  : 'اسکن برچسب',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: Text('ثبت'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: SizedBox(
                width: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    //strokeWidth: 10,
                    color: Theme.of(context).accentColor,
                    semanticsLabel: 'در حال بارگذاری',
                  ),
                ),
              ),
            ),
      endDrawer: MainDrawer(),
    );
  }
}

/*child: SizedBox(
                        height: 150,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            itemCount: vehicles.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                color: Colors.black12,
                                child: Text(
                                  vehicles[index].BrandName,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              );
                            }),
                      ),

                      /*DropdownButton<Vehicles>(
                      hint: Text("Select item"),
                      value: modelNamevalue,
                      onChanged: (Vehicles? Value) {
                        setState(() {
                          modelNamevalue = Value!;
                        });
                      },
                      items: vehicles.map((Vehicles user) {
                        return DropdownMenuItem<Vehicles>(
                          value: user,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                user.ModelName,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )*/

                      */
/*
Future<void> _printAndCopy(String cmd) async {
  print(cmd);

  await Clipboard.setData(ClipboardData(text: cmd));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied to Clipboard')),
  );
}*/

//{result: true, data: [{ID: 3134, OutVal: true}], token: U2FsdGVkX18rg3eWyfIG8L/Y55tUg1vq1yNKP2tuD613CSQsDJTW2vBqLtPMmuG9JDwwoF7RVBApp0at600wvGCbUNwJlYHV3VkF4gwae38GNI3NJ4Kxm9/7iDhgkNR2yY38Ln6BfQLcLJ7ZvqFR4HIBomMVThtNsCv8/5Ilk4/ZeupXLzgnKUF4a4YA6FxLVJELJXnW/0ygRZt45qZOHQLpZCFs9tqI/E8EHgtfdluqqH/bnIIRrCd9pdwe1FuUeuAg8TojopbFehI9YTZtYZ2tTE8u2jmsk+31y8wm43IjjogF0GdsPZZd88v6BvmIy1wJuoYq1mG64ULPaPs7Z/LQ5EZ7DPMETMxlMcojXb7sHpHPZrmN7EJeli9HP6lOjKl4qVGjeT8mLVAfXhMZNg==}
