import 'package:flutter/material.dart';

class TextBoxRtl extends StatelessWidget {
  String title = '';
  double fontSize;

  TextBoxRtl(this.title, this.fontSize) {}

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Text(title,
            style: TextStyle(fontSize: fontSize, fontFamily: 'IRANSANS')));
  }
}
