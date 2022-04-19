import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

/*void main() {
  String token =
      'U2FsdGVkX19+xzX4AW3of4NZnxlWtReoXySH0lebRfEC9PW7pdxxkhNvEq7B8QzYvlnraAjTd/y1gMzhAi7DhuaewOl62A5oRHmTMPY95iUPtpmvNkYq9a/7v+AbUjswSz6/YwwtnnLktCP2TICW+A6WMRUYmPa5129pLL+/mtA7bJX/k0i4V1ByA6oB56v2UuWlUYOcvYPXyUdzNQpuonWnnwBwp5WdLs9UuSVaz44yqOehNU2FSlCz42G29/3hUYdg9yDJjWihHYARxFvF2WsdSpuFhQ3MS85Tgr+KzJBh3ICkO8ei50cnbOcfuSTyo/nhmnkFGQps1RgfdhjPlAZjCCDslDMaeGR/aWN0f5upkcxsiDdZqAENzbvGhNgjvjP4EHND54FVLcOBc5t1lA==';
  String decode = decryptAESCryptoJS(token, '8c10%\$#f9be0b053082');
  print(decode);

  //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJKV1QgRGVjb2RlIiwiaWF0IjoxNjA4NTgxNzczLCJleHAiOjE2NDAxMTc3NzMsImF1ZCI6Ind3dy5qd3RkZWNvZGUuY29tIiwic3ViIjoiQSBzYW1wbGUgSldUIiwibmFtZSI6IlZhcnVuIFMgQXRocmV5YSIsImVtYWlsIjoidmFydW4uc2F0aHJleWFAZ21haWwuY29tIiwicm9sZSI6IkRldmVsb3BlciJ9.vXE9ogUeMMsOTz2XQYHxE2hihVKyyxrhi_qfhJXamPQ';
  //String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTAyNywiZmlyc3ROYW1lIjoi2YXYrdmF2K_Yrdiz24zZhiIsImxhc3ROYW1lIjoi2KfYs9mF2KfYuduM2YTbjCIsIm1vYmlsZU5vIjoiMDkxMjYxMzA5NzUiLCJ1c2VyVHlwZSI6IkRyaXZlciIsImlhdCI6MTY0MDg2MjE0MCwiZXhwIjoxNjQwOTQ4NTQwfQ.CIYwCzN5wDX20cGgIRStiie0E5rBP4jZjfpptJ1OCNo';
  Map<String, dynamic> payload = Jwt.parseJwt(decode);
  print(Jwt.isExpired(decode));
  print(payload);
}*/

String decryptAESCryptoJS(String encrypted, String passphrase) {
  try {
    Uint8List encryptedBytesWithSalt = base64.decode(encrypted);

    Uint8List encryptedBytes =
        encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
    final salt = encryptedBytesWithSalt.sublist(8, 16);
    var keyndIV = deriveKeyAndIV(passphrase, salt);
    final key = encrypt.Key(keyndIV.item1);
    final iv = encrypt.IV(keyndIV.item2);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final decrypted =
        encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
    return decrypted;
  } catch (error) {
    throw error;
  }
}

Tuple2<Uint8List, Uint8List> deriveKeyAndIV(String passphrase, Uint8List salt) {
  var password = createUint8ListFromString(passphrase);
  Uint8List concatenatedHashes = Uint8List(0);
  Uint8List currentHash = Uint8List(0);
  bool enoughBytesForKey = false;
  Uint8List preHash = Uint8List(0);

  while (!enoughBytesForKey) {
    int preHashLength = currentHash.length + password.length + salt.length;
    if (currentHash.length > 0)
      preHash = Uint8List.fromList(currentHash + password + salt);
    else
      preHash = Uint8List.fromList(password + salt);

    currentHash = md5.convert(preHash).bytes as Uint8List;
    concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
    if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
  }

  var keyBtyes = concatenatedHashes.sublist(0, 32);
  var ivBtyes = concatenatedHashes.sublist(32, 48);
  return new Tuple2(keyBtyes, ivBtyes);
}

Uint8List createUint8ListFromString(String s) {
  var ret = new Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

/*String encryptAESCryptoJS(String plainText, String passphrase) {
  try {
    final salt = genRandomWithNonZero(8);
    var keyndIV = deriveKeyAndIV(passphrase, salt);
    final key = encrypt.Key(keyndIV.item1);
    final iv = encrypt.IV(keyndIV.item2);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    Uint8List encryptedBytesWithSalt = Uint8List.fromList(
        createUint8ListFromString("Salted__") + salt + encrypted.bytes);
    return base64.encode(encryptedBytesWithSalt);
  } catch (error) {
    throw error;
  }
}*/

/*Uint8List genRandomWithNonZero(int seedLength) {
  final random = Random.secure();
  const int randomMax = 245;
  final Uint8List uint8list = Uint8List(seedLength);
  for (int i = 0; i < seedLength; i++) {
    uint8list[i] = random.nextInt(randomMax) + 1;
  }
  return uint8list;
}*/

/*void main(List<String> arguments) async {
  final body = {
    'mobileNo': '09126130975',
  };
  final jsonString = convert.json.encode(body);
  final uri = Uri.http('caralapp.ir:8085', '/api/auth/SendVerificationCode');
  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  try {
    final response = await http.post(uri, headers: headers, body: jsonString);
    if (response.statusCode == 200) {
      var jsonResponse =
      convert.jsonDecode(response.body) as Map<String, dynamic>;
      var test = jsonResponse['data'];
      print('Response: $test.');
    }
  }
  on Exception catch (e) {
    print(e);
  }
}*/

/*void main(List<String> arguments) async {
  final body = {
    'mobileNo': '09126130975',
    'code': '92917',
  };
  final jsonString = convert.json.encode(body);
  final uri = Uri.http('caralapp.ir:8085', '/api/auth/VerifyCode');
  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  final response = await http.post(uri, headers: headers, body: jsonString);
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var test = jsonResponse['data'];
    print('Response: $test.');
  }
}*/

/*void main(List<String> arguments) async {
  String url="http://caralapp.ir/code/c3dfb460-9773-4354-b804-83745545de6a";
  final body = {
    'id': url.split("/")[4],
  };
  final jsonString = convert.json.encode(body);
  final uri = Uri.http('caralapp.ir:8085', '/api/userCarAssign/getUserCarAssignInfoBasedOnQrCode');
  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  final response = await http.post(uri, headers: headers, body: jsonString);
  if (response.statusCode == 200) {
    var jsonResponse =
    convert.jsonDecode(response.body) as Map<String, dynamic>;
    var test = jsonResponse['data'];
    print('Response: $test.');
  }
}*/

/*void main(List<String> arguments) async {
  final uri = Uri.http('caralapp.ir:8085', '/api/messageTemplate/getMessageTemplates');
  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  final response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonResponse =
    convert.jsonDecode(response.body) as Map<String, dynamic>;
    var test = jsonResponse['data'];
    print('Response: $test.');
  }
}*/

/*void main(List<String> arguments) async {
  final uri = Uri.http('caralapp.ir:8085', '/api/vehicle/getAllVehicles');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'x-auth-token': 'U2FsdGVkX1/DWSPM/X0B0SqoZtksep3ocfE3nOS4rgP1F0RHsRY6LIPispWDLQfKzR9DSFirHWNp7CDql5slS6LQfZzhGdMmHu3kieYnsRzWuvbs4TR3lCipRRB0Cps2O00hqfBmdUIU4KRyseQm/Nqec1Tu2JEQFOMaAB/e0GIA6TxCB46Y8YJxzDi6zsrgeb9MUFdCsjqr519mm5LV3StYo+tZE9eE7c+fPzDKtO/KLxL6TsCQFFQ+SupYeTO0h/YfqyUKsxelIccjug7czjfG4sZpkSQyPwlcOo7beDC4xdCHBWFhtZHQC2V89uWOWe9zvXRyiVqh/FvfcN9rNmyovtEz+z7I5Pe8quYpYGm8i5pZXDYKOj4maM5ZxEWbTWOurFAc1uI5locXEc1QRg==',
  };
  final response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonResponse =
    convert.jsonDecode(response.body) as Map<String, dynamic>;
    var test = jsonResponse['data'];
    print('Response: $test.');
  }
}*/

/*void main(List<String> arguments) async {
  final body = {
    //'qrcode': 'c3dfb460-9773-4354-b804-83745545de6a',
    'qrcode': 'd7641c60-5ea8-44e3-a992-b7721d554322',
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
      print('Response: $qrCodeID.');
    } else{
      print('Response : خطا');
    }
  }
}*/

/*void main(List<String> arguments) async {
  final uri = Uri.http('caralapp.ir:8085', '/api/generalInfo/getPlateTypes');
  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  final response = await http.get(uri, headers: headers);
  //if (response.statusCode == 200) {
  var jsonResponse =
  convert.jsonDecode(response.body) as Map<String, dynamic>;
  var test = jsonResponse['data'];
  print('Response: $test.');
  //}
}*/

/*void main(List<String> arguments) async {
  final uri =
  Uri.http('caralapp.ir:8085', '/api/vehicleColor/getVehicleColors');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'x-auth-token':
    'U2FsdGVkX1/DWSPM/X0B0SqoZtksep3ocfE3nOS4rgP1F0RHsRY6LIPispWDLQfKzR9DSFirHWNp7CDql5slS6LQfZzhGdMmHu3kieYnsRzWuvbs4TR3lCipRRB0Cps2O00hqfBmdUIU4KRyseQm/Nqec1Tu2JEQFOMaAB/e0GIA6TxCB46Y8YJxzDi6zsrgeb9MUFdCsjqr519mm5LV3StYo+tZE9eE7c+fPzDKtO/KLxL6TsCQFFQ+SupYeTO0h/YfqyUKsxelIccjug7czjfG4sZpkSQyPwlcOo7beDC4xdCHBWFhtZHQC2V89uWOWe9zvXRyiVqh/FvfcN9rNmyovtEz+z7I5Pe8quYpYGm8i5pZXDYKOj4maM5ZxEWbTWOurFAc1uI5locXEc1QRg==',
  };
  final response = await http.get(uri, headers: headers);
  //if (response.statusCode == 200) {
  var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
  var test = jsonResponse['data'];
  print('Response: $test.');
  //}
}*/

/*void main(List<String> arguments) async {
  final uri = Uri.http(
      'caralapp.ir:8085', '/api/userCarAssignMessage/getAllMessagesForUser');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'x-auth-token': 'U2FsdGVkX1/DWSPM/X0B0SqoZtksep3ocfE3nOS4rgP1F0RHsRY6LIPispWDLQfKzR9DSFirHWNp7CDql5slS6LQfZzhGdMmHu3kieYnsRzWuvbs4TR3lCipRRB0Cps2O00hqfBmdUIU4KRyseQm/Nqec1Tu2JEQFOMaAB/e0GIA6TxCB46Y8YJxzDi6zsrgeb9MUFdCsjqr519mm5LV3StYo+tZE9eE7c+fPzDKtO/KLxL6TsCQFFQ+SupYeTO0h/YfqyUKsxelIccjug7czjfG4sZpkSQyPwlcOo7beDC4xdCHBWFhtZHQC2V89uWOWe9zvXRyiVqh/FvfcN9rNmyovtEz+z7I5Pe8quYpYGm8i5pZXDYKOj4maM5ZxEWbTWOurFAc1uI5locXEc1QRg==',
  };
  final response = await http.post(uri, headers: headers, body: '');
  //final response = await http.get(uri, headers: headers);
  var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
  var test = jsonResponse['data'];
  print('Response: $test.');
}*/

/*void main(List<String> arguments) async {
  final uri = Uri.http(
        'caralapp.ir:8085', '/api/messageTemplate/getAllMessageResponseTemplates');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    'x-auth-token': 'U2FsdGVkX1/DWSPM/X0B0SqoZtksep3ocfE3nOS4rgP1F0RHsRY6LIPispWDLQfKzR9DSFirHWNp7CDql5slS6LQfZzhGdMmHu3kieYnsRzWuvbs4TR3lCipRRB0Cps2O00hqfBmdUIU4KRyseQm/Nqec1Tu2JEQFOMaAB/e0GIA6TxCB46Y8YJxzDi6zsrgeb9MUFdCsjqr519mm5LV3StYo+tZE9eE7c+fPzDKtO/KLxL6TsCQFFQ+SupYeTO0h/YfqyUKsxelIccjug7czjfG4sZpkSQyPwlcOo7beDC4xdCHBWFhtZHQC2V89uWOWe9zvXRyiVqh/FvfcN9rNmyovtEz+z7I5Pe8quYpYGm8i5pZXDYKOj4maM5ZxEWbTWOurFAc1uI5locXEc1QRg==',
  };
  final response = await http.get(uri, headers: headers);
  //final response = await http.get(uri, headers: headers);
  var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
  var test = jsonResponse['data'];
  print('Response: $test.');
}*/

void main(List<String> arguments) async {
  final uri = Uri.http(
      'caralapp.ir:8085', '/api/downloadApp/getLatestVersionOfAppByType');
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    //'x-auth-token': 'U2FsdGVkX1/DWSPM/X0B0SqoZtksep3ocfE3nOS4rgP1F0RHsRY6LIPispWDLQfKzR9DSFirHWNp7CDql5slS6LQfZzhGdMmHu3kieYnsRzWuvbs4TR3lCipRRB0Cps2O00hqfBmdUIU4KRyseQm/Nqec1Tu2JEQFOMaAB/e0GIA6TxCB46Y8YJxzDi6zsrgeb9MUFdCsjqr519mm5LV3StYo+tZE9eE7c+fPzDKtO/KLxL6TsCQFFQ+SupYeTO0h/YfqyUKsxelIccjug7czjfG4sZpkSQyPwlcOo7beDC4xdCHBWFhtZHQC2V89uWOWe9zvXRyiVqh/FvfcN9rNmyovtEz+z7I5Pe8quYpYGm8i5pZXDYKOj4maM5ZxEWbTWOurFAc1uI5locXEc1QRg==',
  };
  final response = await http.post(uri,
      headers: headers,
      body: json.encode({
        'appType': 1,
      }));
  var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
  var test = jsonResponse['data'];
  print('Response: $test.');
}

/*void main() {
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';

  final key = Key.fromBase16("8c10%\$#f9be0b053082");
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  final decrypted = encrypter.decrypt16("U2FsdGVkX19RPWLPgVu7TCmAlvGMEWXtTNHvqDnGKCAWumgFhzzFgbHQ5HMeHueA2kpi+5Q/iCYs9GLVIEYNC28raDuRMk5JvtWplOBqR7npQmvdUemfq3o8N9oNAfytY3aAT8DfySojgf2YkGnQrzVlGZKUq32c8ncWtbEXsWVs75juCCnnqdj3PGBFpgpDFHJQ+STSJsP4VVAfGxFJLuaHqa+72trAJzogFZVGBwrJEEKHwY040mp4f4UYsPcTyyYKNO3shfj+S0iwBOGPs3jggu4svSClQPlWNujocakIpRcTyITcp3wTnvNzDrLgYcfed41wFFXFnbroCF0nDfATZCWHjeKWvGk4xWGyNN07TxT6bWREKpRDItHGnZohnuMxbtAkKRjbWqDyTYaFQQ==", iv: iv);

  print(decrypted);
  print(encrypted.bytes);
  print(encrypted.base16);
  print(encrypted.base64);
}*/

//U2FsdGVkX19RPWLPgVu7TCmAlvGMEWXtTNHvqDnGKCAWumgFhzzFgbHQ5HMeHueA2kpi+5Q/iCYs9GLVIEYNC28raDuRMk5JvtWplOBqR7npQmvdUemfq3o8N9oNAfytY3aAT8DfySojgf2YkGnQrzVlGZKUq32c8ncWtbEXsWVs75juCCnnqdj3PGBFpgpDFHJQ+STSJsP4VVAfGxFJLuaHqa+72trAJzogFZVGBwrJEEKHwY040mp4f4UYsPcTyyYKNO3shfj+S0iwBOGPs3jggu4svSClQPlWNujocakIpRcTyITcp3wTnvNzDrLgYcfed41wFFXFnbroCF0nDfATZCWHjeKWvGk4xWGyNN07TxT6bWREKpRDItHGnZohnuMxbtAkKRjbWqDyTYaFQQ==
