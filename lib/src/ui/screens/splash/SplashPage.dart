import 'dart:async';
import 'dart:io';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:KABA/src/ui/screens/splash/PresentationPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:location/location.dart' as lo;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../StateContainer.dart';

class SplashPage extends StatefulWidget { // translated

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

  Future _getLastKnowLocation() async {
    // save in to state container.
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    if (position != null)
      StateContainer.of(context).updateLocation(location: position);
  }

  Future handleTimeout() async {

    /* check if first opening the app */
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstTime = await _getIsFirstTime();

    if (isFirstTime) {
      // jump to presentation screens
      _jumpToFirstTimeScreen();
    } else {
      StatefulWidget launchPage = LoginPage(presenter: LoginPresenter());
      prefs = await SharedPreferences.getInstance();
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
  }

  startTimeout() async {

    var duration = const Duration(milliseconds: 1500);
    return new Timer(duration, handleTimeout);
  }

  _checkLocationActivated () async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${AppLocalizations.of(context).translate('cant_get_location')}"),
              content: Text("${AppLocalizations.of(context).translate('please_enable_gps')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text("${AppLocalizations.of(context).translate('ok')}"),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // for ios only.
    return Scaffold(
      body:  AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Center(
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
                  Text("${AppLocalizations.of(context).translate('app_title')}",
                      style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: 18))
                ]
            )),
      ),
    );
  }

  Future<bool> _getIsFirstTime() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = true;
    try {
      // prove me it's not first time
      isFirstTime = prefs.getBool("_first_time");
    } catch(_){
      // is first time
      isFirstTime = true;
    }
    if (isFirstTime == null)
      isFirstTime = true;
    return isFirstTime;
  }

  Future<bool> _getIsOkWithTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOkWithTerms = false;
    try {
      // prove me it's not first time
      isOkWithTerms = prefs.getBool("_is_ok_with_terms");
    } catch(_){
      // is first time
      isOkWithTerms = false;
    }
    if (isOkWithTerms == null)
      isOkWithTerms = false;
    return isOkWithTerms;
  }

  void _jumpToFirstTimeScreen() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PresentationPage(),
      ),
    );
  }

  void _jumpToTermsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: "${AppLocalizations.of(context).translate('cgu')}",link: ServerRoutes.CGU_PAGE, agreement: true),
      ),
    );
  }
}
