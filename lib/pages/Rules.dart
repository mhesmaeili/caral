import 'package:flutter/material.dart';

class Rules extends StatelessWidget {
  static const routeName = '/rules';

  Rules() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('قوانین و مقررات'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                elevation: 30,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        getNewLineString(),
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var readLines = [
    'کارال ابزاری جهت برقراری ارتباط با مالک یا راننده خودرو، بدون نیاز به اشتراک گذاری اطلاعات شخصی همچون شماره تماس و نام فرد می باشد. شما با استفاده از، یا عضویت در این سامانه، پذیرفته و متعهد گردیده اید که',
    'شرایط و قوانین سامانه کارال در طول زمان ممکن است تغییر نماید و شما با ادامه استفاده از آن، تعهد و پذیرش خود بر این قوانین جدید را تایید نموده اید',
    'اطلاعات ثبت شده توسط شما واقعی بوده و در صورت احراز عدم صحت آنها، بنا بر تصمیم مجموعه کارال، این مجموعه می تواند محدودیتهایی بر حساب شما اعمال یا مالکیت حساب شما را از شما سلب نماید',
    'کاربران از این سامانه صرفا به سبب پیغام رسانی جهت رفع مشکلات مربوط به خودرو استفاده می نمایند',
    'کاربران تایید می نمایند که سامانه کارال جهت اطلاع رسانی به آنها می تواند از یک یا تمام ابزارهای ممکن مانند، پیامک، push notification، ارتباط صوتی داخل نرم افزار یا تماس تلفنی استفاده نماید',
    'در صورت دسترسی کاربر به پیغامهای شخصی سازی شده، کاربران تنها می توانند در چهارچوب قوانین جمهوری اسلامی پیغام ارسال نمایند و مسئولیت هرگونه عدم انطباق با قوانین جمهوری اسلامی تنها بر عهده کاربر می باشد',
    'هرگونه فعالیت سوء که منجر به خدشه دار شدن نام و اعتبار مجموعه یا سامانه کارال گردد امکان شکایت این مجموعه از افراد و کاربران خاطی را فراهم می آورد',
    'هرگونه ایجاد مزاحمت توسط این ابزار پیگرد قانونی داشته و اطلاعات شخصی شما با دستور مراجع ذی صلاح در اختیار مراکز قانونی قرار خواهد گرفت',
    'در صورت سوء استفاده از این ابزار، مسئولیت آن تنها بر عهده فرد سوء استفاده گر بوده و سامانه کارال بواسطه ایجاد بستر ارتباطی هیچ گونه مسئولیتی در پیامدهای مربوطه نخواهد داشت',
    'در صورت اعلام کاربران در خصوص عدم انطباق اطلاعات ظاهری خودرو با اطلاعات نمایش داده شده از خودرو در سامانه محدودیتهایی بر حساب کاربری اعمال نموده و در صورت تکرار حساب کاربر بطور کامل تعلیق و سلب امتیاز خواهد گردید',
    'شماره پشتیبان تنها با کسب اجازه و تایید صاحبان شماره امکان پذیر بوده و در صورت عدم کسب اجازه مسئولیت هرگونه پیامد ایجاد شده با کاربر ثبت کننده شماره پشتیبان می باشد',
    'حساب کاربری و برچسب آن، امکان انتقال به غیر نداشته و هر لیبل تنها به نام یک فرد و برای یک شماره پلاک صادر می گردد و اگر فرد بصورت همزمان چند خودرو یا چند پلاک خودرو داشته باشد می بایست برای هر کدام بصورت مجزا برچسب تهیه نماید',
  ];

  String getNewLineString() {
    StringBuffer sb = new StringBuffer();
    for (String line in readLines) {
      sb.write(line + "\n"+ "\n");
    }
    return sb.toString();
  }
}