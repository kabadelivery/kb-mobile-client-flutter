import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
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
    SystemChrome.setEnabledSystemUIOverlays ([]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Exit full screen
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) => IntroViewsFlutter(
            [
              PageViewModel(
                pageColor: Color(0x85FDD047),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context).translate('choice_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context).translate('choice')}",
                ),
                titleTextStyle: const TextStyle(color: Colors.white),
                bodyTextStyle: const TextStyle(color: Colors.white),
                mainImage: Image.asset(
                  ImageAssets.choice,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor: Color(0x8D00C9AF),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context).translate('payment_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context).translate('payment')}",
                ),
                titleTextStyle: const TextStyle(color: Colors.white),
                bodyTextStyle: const TextStyle(color: Colors.white),
                mainImage: Image.asset(
                  ImageAssets.payment,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor: Color(0x8830DBFF),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context).translate('address_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context).translate('address')}",
                ),
                titleTextStyle: const TextStyle(color: Colors.white),
                bodyTextStyle: const TextStyle(color: Colors.white),
                mainImage: Image.asset(
                  ImageAssets.address,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor:  Color(0x99CC1641),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context).translate('enjoy_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context).translate('enjoy')}",
                ),
                titleTextStyle: const TextStyle(color: Colors.white),
                bodyTextStyle: const TextStyle(color: Colors.white),
                mainImage: Image.asset(
                  ImageAssets.enjoy,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              // payment , address , enjoy
            ],
            showSkipButton: true,
            showNextButton: true,
            showBackButton: false,
            onTapDoneButton: () {
              // Use Navigator.pushReplacement if you want to dispose the latest route
              // so the user will not be able to slide back to the Intro Views.
              _endOfTheSlides();
            },
            doneText: Text("${AppLocalizations.of(context).translate('done_text')}"),
            skipText: Text("${AppLocalizations.of(context).translate('skip_text')}"), //skip_text
            nextText: Text("${AppLocalizations.of(context).translate('next_text')}"), //next
            pageButtonTextStyles: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  _skipPresentation() {
    _endOfTheSlides();
  }

  _endOfTheSlides() async {
    // set seen at true, and move to whatever page the other page which is terms and conditions
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("_first_time", false).then((value) {

      // jump to splashscreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashPage(),
        ),
      );
    });
  }




}