import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/locale/locale.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {

  static var routeName = "/SplashPage";

  SplashPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimeout();
  }

  Future handleTimeout() async {
    StatefulWidget launchPage =  LoginPage(presenter: LoginPresenter());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expDate = prefs.getString("_login_expiration_date");
    if (expDate != null) {
      if (DateTime.now().isAfter(DateTime.parse(expDate))) {
        /* session expired : clean params */
        prefs.remove("_customer");
        prefs.remove("_token");
        prefs.remove("_login_expiration_date");
      } else {
        launchPage = HomePage();
      }
    }
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => launchPage));
  }

  startTimeout() async {
    var duration = const Duration(seconds: 3);
    return new Timer(duration, handleTimeout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /* image */
                  SizedBox(
                    height: 50,
                   width: 50,
                   child:SvgPicture.asset(
                      VectorsData.kaba_icon_svg,
                      color: KColors.primaryColor,
                      semanticsLabel: 'LOGO',
                  )),
                  /* text */
                  SizedBox(height: 10),
                  Text(KabaLocalizations.of(context).app_name.toString().toUpperCase(),
                   style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 18))
                ]
          )),
    );
  }
}
