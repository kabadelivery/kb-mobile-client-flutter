import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/locale/locale.dart';
import 'package:kaba_flutter/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/screens/home/HomePage.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/Vectors.dart';

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

  void handleTimeout() {
    Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => LoginPage()));
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
