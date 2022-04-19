import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Authentication  {

  Future<bool> sendVerificationCode(String mobileNumber) async {
    final uri = Uri.http('caralapp.ir:8085', '/api/auth/SendVerificationCode');
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.post(uri,
        headers: headers,
        body: json.encode({
          'mobileNo': mobileNumber,
        }));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var test = jsonResponse['data'];
      print('Response: $test.');
      return true;
    } else {
      return false;
    }
  }

}
