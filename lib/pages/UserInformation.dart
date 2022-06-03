import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '/widgets/MainDrawer.dart';
import '../CommonFunction.dart';
import '../ConstVariable.dart';
import '../model/Brands.dart';
import '../model/CarAssignInfoEdit.dart';
import '../model/GeneralInfo.dart';
import '../model/Models.dart';
import '../model/UserInfo.dart';
import '../model/VehicleColors.dart';
import '../widgets/TextBoxRtl.dart';

class UserInformation extends StatefulWidget {
  static const routeName = '/userInformation';

  const UserInformation({Key? key}) : super(key: key);

  @override
  _UserInformation createState() => _UserInformation();
}

class _UserInformation extends State<UserInformation> {
  late UserInfo userInfo;
  late List<CarAssignInfoEdit> carAssignList = [];
  final _form = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  List<Models> vehicles = [];
  List<Brands> brands = [];
  List<Models> models = [];
  List<VehicleColors> vehiclesColors = [];
  List<GeneralInfo> plateTypes = [];
  late Brands brandNamevalue;
  late Models modelNamevalue = new Models(0, 0, 'انتخاب مدل');
  late GeneralInfo plateTypeValue = new GeneralInfo(0, 0, 'نوع پلاک', 0, '');
  late VehicleColors vehicleColorValue = new VehicleColors(0, 'انتخاب رنگ');
  String plateValue1 = '';
  String plateValue2 = '';
  String plateValue3 = '';
  String plateValue4 = '';

  var _loadedInitData = false;
  late String token = '';
  late bool noData = false;
  late bool isSwitched = false;
  late int userId = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('TOKEN_CARAL').then((value) {
        token = value;
        getUserInfoById().then((value) {
          if (userInfo.MessageType == 2) {
            isSwitched = false;
          } else {
            isSwitched = true;
          }
          getUserCarAssignInfoByUserId().then((value) {
            loadAllVehicles();
            loadVehiclesColor();
            loadPlateType();
            noData = true;
          });
        });
      });
      _loadedInitData = true;
    }
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

  TabBar get _tabBar => TabBar(
        indicatorColor: Colors.redAccent,
        tabs: [
          Tab(
              icon: Icon(Icons.supervised_user_circle_outlined),
              text: 'تنظیمات کاربری'),
          Tab(icon: Icon(Icons.directions_car), text: 'برچسب های تخصیصی'),
        ],
      );

  @override
  Widget build(BuildContext context) {
    //var width = responsive.calcWidth(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('اطلاعات کاربری'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: Colors.deepPurpleAccent,
              child: _tabBar,
            ),
          ),
        ),
        body: token != '' && noData
            ? Center(
                child: Container(
                  alignment: Alignment.topCenter,
                  //width: width,
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 10,
                      ),
                      child: TabBarView(
                        children: [
                          _createProfile(),
                          _createDataTable(),
                        ],
                      ),
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
      ),
    );
  }

  Form _createProfile() {
    return Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(children: [
          TextFormField(
            initialValue: userInfo.FirstName,
            decoration: InputDecoration(
                hintText: 'نام',
                hintStyle: Theme.of(context).textTheme.subtitle1),
            textAlign: TextAlign.right,
            maxLength: 20,
            keyboardType: TextInputType.text,
            /*onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(familyFocusNode);
                    },*/
            onSaved: (value) {
              userInfo.FirstName = value!;
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'نام را وارد کنید';
              }
              return null;
            },
            style: Theme.of(context).textTheme.subtitle2,
            //style: TextStyle(fontFamily: 'IRANSANS'),
          ),
          TextFormField(
            initialValue: userInfo.LastName,
            decoration: InputDecoration(
                hintText: 'نام خانوادگی',
                hintStyle: Theme.of(context).textTheme.subtitle1),
            textAlign: TextAlign.right,
            maxLength: 35,
            keyboardType: TextInputType.text,
            //focusNode: familyFocusNode,
            /*onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(mobileFocusNode);
                      },*/
            onSaved: (value) {
              userInfo.LastName = value!;
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'نام خانوادگی را وارد کنید';
              }
              return null;
            },
            style: Theme.of(context).textTheme.subtitle2,
            // onChanged: (val) => amountInput = val,
          ),
          TextFormField(
            initialValue: userInfo.Email,
            decoration: InputDecoration(
                hintText: 'ایمیل',
                hintStyle: Theme.of(context).textTheme.subtitle1),
            textAlign: TextAlign.left,
            //maxLength: 35,
            keyboardType: TextInputType.emailAddress,
            //focusNode: familyFocusNode,
            /*onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(mobileFocusNode);
                      },*/
            onSaved: (value) {
              userInfo.Email = value!;
            },
            /*validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'ایمیل را وارد کنید';
                              }
                              return null;
                            },*/
            style: Theme.of(context).textTheme.subtitle2,
            // onChanged: (val) => amountInput = val,
          ),
          TextFormField(
            initialValue: userInfo.Address,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
                hintText: 'آدرس',
                hintStyle: Theme.of(context).textTheme.subtitle1),
            textAlign: TextAlign.right,
            keyboardType: TextInputType.text,
            onSaved: (value) {
              userInfo.Address = value!;
            },
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('پیامک',
                  style: TextStyle(fontSize: 13, fontFamily: 'IRANYEKAN')),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              Text('صوتی',
                  style: TextStyle(fontSize: 13, fontFamily: 'IRANYEKAN')),
              TextBoxRtl('نوع دریافت پیام : ', 15),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: userInfo.AllowReceiveMessageFromNotLoginUser,
                onChanged: (value) {
                  setState(() {
                    userInfo.AllowReceiveMessageFromNotLoginUser = value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
              TextBoxRtl(
                  'اجازه دریافت پیام از فرد ورود نکرده به سامانه : ', 15),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveForm,
            child: Text('اعمال تغییرات'),
          ),
        ]),
      ),
    );
  }

  DataTable _createDataTable() {
    return DataTable(
        columnSpacing: 0, columns: _createColumns(), rows: _createRows());
  }

  List<DataColumn> _createColumns() {
    final double width = MediaQuery.of(context).size.width;
    return [
      DataColumn(
          label:
              Container(width: width * .10, child: TextBoxRtl('عملیات', 13))),
      DataColumn(
          label: Container(width: width * .10, child: TextBoxRtl('رنگ', 13))),
      DataColumn(
          label: Container(width: width * .12, child: TextBoxRtl('برند', 13))),
      DataColumn(
          label: Container(width: width * .14, child: TextBoxRtl('نام', 13))),
      DataColumn(
          label: Container(width: width * .1, child: TextBoxRtl('ردیف', 13))),
    ];
  }

  List<DataRow> _createRows() {
    final double width = MediaQuery.of(context).size.width;
    List<DataRow> list = [];
    int i = 1;
    carAssignList.reversed.forEach((element) {
      list.add(DataRow(cells: [
        DataCell(Container(
          width: width * .10,
          child: IconButton(
            icon: Icon(
              Icons.edit,
            ),
            iconSize: 20,
            color: Colors.grey,
            onPressed: () {
              brandNamevalue =
                  new Brands(element.VehicleBrand_ID, element.Brand);
              models = vehicles.where((tx) {
                return tx.Brand_ID == element.VehicleBrand_ID;
              }).toList();
              modelNamevalue = new Models(element.VehicleBrand_ID,
                  element.VehicleModel_ID, element.Name);
              vehicleColorValue =
                  new VehicleColors(element.VehicleColor_ID, element.Color);
              _showEditDialog(element);
            },
          ),
        )),
        DataCell(Container(
            width: width * .10, child: TextBoxRtl(element.Color, 12))),
        DataCell(Container(
            width: width * .12, child: TextBoxRtl(element.Brand, 12))),
        DataCell(
            Container(width: width * .14, child: TextBoxRtl(element.Name, 12))),
        DataCell(
            Container(width: width * .1, child: TextBoxRtl(i.toString(), 12))),
      ]));
      i++;
    });
    return list;
  }

  Future<void> getUserInfoById() async {
    final uri = Uri.http(ConstVariable.WEB_URL, '/api/user/getUserInfoById');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final response = await http.post(uri, headers: headers, body: '');
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      //print('Response: $jsonResponse.');
      bool result = jsonResponse['result'];
      if (result) {
        setState(() {
          userInfo = UserInfo.fromJson(jsonResponse['data'][0]);
        });
      }
    }
  }

  Future<void> getUserCarAssignInfoByUserId() async {
    final uri = Uri.http(ConstVariable.WEB_URL,
        '/api/userCarAssign/getUserCarAssignInfoByUserId');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token,
    };
    final response = await http.post(uri, headers: headers, body: '');
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      bool result = jsonResponse['result'];
      if (result) {
        final parsed = convert
            .jsonDecode(response.body)['data']
            .cast<Map<String, dynamic>>();
        List<CarAssignInfoEdit> list = parsed
            .map<CarAssignInfoEdit>((json) => CarAssignInfoEdit.fromJson(json))
            .toList();
        setState(() {
          carAssignList = list;
        });
      }
    }
  }

  void _saveForm() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    _form.currentState!.save();

    if (isSwitched) {
      userInfo.MessageType = 3;
    } else {
      userInfo.MessageType = 2;
    }

    final body = {
      'firstName': userInfo.FirstName,
      'lastName': userInfo.LastName,
      'email': userInfo.Email,
      'address': userInfo.Address,
      'messageType': userInfo.MessageType,
      'allowReceiveMessageFromNotLoginUser':
          userInfo.AllowReceiveMessageFromNotLoginUser,
      'id': userInfo.ID,
    };
    print('input : ' + body.toString());
    final jsonString = convert.json.encode(body);
    final uri = Uri.http(ConstVariable.WEB_URL, '/api/user/updateUserInfo');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token
    };

    final response = await http.post(uri, headers: headers, body: jsonString);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      //print(jsonResponse);
      var result = jsonResponse['result'];
      if (result) {
        CommonFunction.showSnackBar("اطلاعات با موفقیت ویرایش شد", 5, context);
      } else {
        CommonFunction.showSnackBar("خطا در ویرایش اطلاعات", 5, context);
      }
    } else {
      CommonFunction.showSnackBar("خطا در ویرایش اطلاعات", 5, context);
    }
  }

  Future<void> _showEditDialog(CarAssignInfoEdit carAssignInfoEdit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: 10,
                      child: Icon(
                        Icons.close,
                        size: 20,
                      ),
                      backgroundColor: Colors.black,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownSearch<Brands>(
                            mode: Mode.DIALOG,
                            dropdownSearchTextAlignVertical:
                                TextAlignVertical.center,
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
                            onSaved: (value) {
                              carAssignInfoEdit.VehicleBrand_ID =
                                  value!.Brand_ID;
                            },
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
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownSearch<Models>(
                              mode: Mode.DIALOG,
                              showSearchBox: true,
                              items: models,
                              onChanged: (Models? Value) {
                                setState(() {
                                  modelNamevalue = Value!;
                                });
                              },
                              onSaved: (value) {
                                carAssignInfoEdit.VehicleModel_ID =
                                    value!.Model_ID;
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
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownSearch<VehicleColors>(
                              mode: Mode.DIALOG,
                              showSearchBox: true,
                              items: vehiclesColors,
                              onChanged: (VehicleColors? Value) {
                                setState(() {
                                  vehicleColorValue = Value!;
                                });
                              },
                              onSaved: (value) {
                                carAssignInfoEdit.VehicleColor_ID =
                                    value!.Color_ID;
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
                        ),
                        carAssignInfoEdit.PlateType == 2
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
                                            left: 10, top: 30),
                                        child: SizedBox(
                                          width: 50,
                                          child: Center(
                                            child: TextFormField(
                                              initialValue: carAssignInfoEdit
                                                  .PlateNo.substring(0, 2),
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              textAlign: TextAlign.center,
                                              maxLength: 2,
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (value) {
                                                plateValue1 = value!;
                                              },
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
                                            selectedItem: carAssignInfoEdit
                                                .PlateNo.substring(2, 3),
                                            onSaved: (value) {
                                              plateValue2 = value!;
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: SizedBox(
                                          width: 65,
                                          child: Center(
                                            child: TextFormField(
                                              initialValue: carAssignInfoEdit
                                                  .PlateNo.substring(3, 6),
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              textAlign: TextAlign.center,
                                              maxLength: 3,
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (value) {
                                                plateValue3 = value!;
                                              },
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, top: 30),
                                        child: SizedBox(
                                          width: 50,
                                          child: Center(
                                            child: TextFormField(
                                              initialValue: carAssignInfoEdit
                                                  .PlateNo.substring(6, 8),
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                              textAlign: TextAlign.center,
                                              maxLength: 2,
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (value) {
                                                plateValue4 = value!;
                                              },
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : carAssignInfoEdit.PlateType == 1
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
                                                  initialValue:
                                                      carAssignInfoEdit.PlateNo
                                                          .substring(0, 5),
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                  textAlign: TextAlign.center,
                                                  maxLength: 5,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onSaved: (value) {
                                                    plateValue1 = value!;
                                                  },
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
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
                                                  initialValue:
                                                      carAssignInfoEdit.PlateNo
                                                          .substring(5, 7),
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                  textAlign: TextAlign.center,
                                                  maxLength: 2,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onSaved: (value) {
                                                    plateValue2 = value!;
                                                  },
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
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
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            child: Text("اعمال تغییرات"),
                            onPressed: () {
                              _saveCarAssign(carAssignInfoEdit);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _saveCarAssign(CarAssignInfoEdit carAssignInfoEdit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    String plateNo = '';
    if (carAssignInfoEdit.PlateType == 2) {
      plateNo = plateValue1 + plateValue2 + plateValue3 + plateValue4;
    } else {
      plateNo = plateValue1 + plateValue2;
    }

    final body = {
      'modelId': carAssignInfoEdit.VehicleModel_ID,
      'userCarAssignID': carAssignInfoEdit.UserCarAssign_ID,
      'colorID': carAssignInfoEdit.VehicleColor_ID,
      'plateNo': plateNo,
    };
    print('input : ' + body.toString());
    final jsonString = convert.json.encode(body);
    final uri = Uri.http(
        ConstVariable.WEB_URL, '/api/userCarAssign/updateCarAssignInfo');
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'x-auth-token': token
    };

    final response = await http.post(uri, headers: headers, body: jsonString);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      //print(jsonResponse);
      var result = jsonResponse['result'];
      if (result) {
        CommonFunction.showSnackBar("اطلاعات با موفقیت ویرایش شد", 5, context);
        setState(() {
          getUserCarAssignInfoByUserId();
        });
      } else {
        CommonFunction.showSnackBar("خطا در ویرایش اطلاعات", 5, context);
      }
    } else {
      CommonFunction.showSnackBar("خطا در ویرایش اطلاعات", 5, context);
    }
    Navigator.of(context).pop();
  }
}
