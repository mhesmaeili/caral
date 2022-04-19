import 'package:flutter/material.dart';

import 'main.dart';

class OrderBarcodes extends StatelessWidget {
  const OrderBarcodes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("کارال"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Column(
              children: [
                Text(
                  'جهت ارسال بارکد لطفا آدرس پستی خود را وارد نمایید',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  // onChanged: (val) => amountInput = val,
                ),
                Text(
                  'جهت دریافت بارکد مبلغ ۱۵۰۰۰ تومان در زمان تحویل از شما اخذ خواهد شد',
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                  child: Text('ثبت سفارش'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
