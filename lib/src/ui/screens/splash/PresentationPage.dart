import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:KABA/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:nice_intro/nice_intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycolor/tinycolor.dart';

class PresentationPage extends StatefulWidget {

  static var routeName = "/PresentationPage";

  PresentationPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<PresentationPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screens = IntroScreens(
      onDone: () => _endOfTheSlides(),
      onSkip: () => _skipPresentation(),
      footerBgColor: TinyColor.fromString("#cc1641").lighten().color,
      activeDotColor: Colors.white,
      footerRadius: 18.0,
//      indicatorType: IndicatorType.CIRCLE,
      slides: [
        IntroScreen(
          title: '${AppLocalizations.of(context).translate('choice')}',
          mChild: SizedBox(
              height: MediaQuery.of(context).size.width*0.8,
              width: MediaQuery.of(context).size.width*0.8,
              child:SvgPicture.asset(
                VectorsData.p_f_1,
              )),
          description: '${AppLocalizations.of(context).translate('choice_desc')}',
          headerBgColor: Colors.white,
        ),
        IntroScreen(
          title: '${AppLocalizations.of(context).translate('payment')}',
          headerBgColor: Colors.white,
          mChild: SizedBox(
              height: MediaQuery.of(context).size.width*0.8,
              width: MediaQuery.of(context).size.width*0.8,
              child:SvgPicture.asset(
                VectorsData.p_f_2,
              )),
          description: "${AppLocalizations.of(context).translate('payment_desc')}",
        ),
        IntroScreen(
          title: '${AppLocalizations.of(context).translate('address')}',
          headerBgColor: Colors.white,
          mChild: SizedBox(
              height: MediaQuery.of(context).size.width*0.8,
              width: MediaQuery.of(context).size.width*0.8,
              child:SvgPicture.asset(
                VectorsData.p_f_3,
              )),
          description: "${AppLocalizations.of(context).translate('address_desc')}",
        ),
        IntroScreen(
          title: '${AppLocalizations.of(context).translate('enjoy')}',
          headerBgColor: Colors.white,
          mChild:  SizedBox(
              height: MediaQuery.of(context).size.width*0.8,
              width: MediaQuery.of(context).size.width*0.8,
              child:SvgPicture.asset(
                VectorsData.p_f_4,
              )),
          description: "${AppLocalizations.of(context).translate('enjoy_desc')}",
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: screens,
    );
  }

  _skipPresentation() {
    _endOfTheSlides();
  }

  _endOfTheSlides() async {
    // set seen at true, and move to whatever page the other page which is terms and conditions
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("_first_time", false);

    // jump to splashscreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SplashPage(),
      ),
    );
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

}