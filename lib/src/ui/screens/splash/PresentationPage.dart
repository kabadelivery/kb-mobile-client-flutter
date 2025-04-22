import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresentationPage extends StatefulWidget {
  static var routeName = "/PresentationPage";

  PresentationPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<PresentationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                pageColor: Color.fromRGBO(253, 216, 54, 0.1),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context)!.translate('choice_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context)!.translate('choice')}"
                      .toUpperCase(),
                ),
                titleTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                mainImage: Image.asset(
                  ImageAssets.choice,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor: Color.fromRGBO(24, 119, 213, 0.1),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context)!.translate('payment_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context)!.translate('payment')}"
                      .toUpperCase(),
                ),
                titleTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                mainImage: Image.asset(
                  ImageAssets.payment,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor: Color.fromRGBO(0, 88, 86, 0.1),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context)!.translate('address_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context)!.translate('address')}"
                      .toUpperCase(),
                ),
                titleTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                mainImage: Image.asset(
                  ImageAssets.address,
                  height: 285.0,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
              ),
              PageViewModel(
                pageColor: Color.fromRGBO(205, 31, 69, 0.1),
                // iconImageAssetPath: 'assets/air-hostess.png',
                bubble: Image.asset(ImageAssets.kaba_main),
                body: Text(
                  "${AppLocalizations.of(context)!.translate('enjoy_desc')}",
                ),
                title: Text(
                  "${AppLocalizations.of(context)!.translate('enjoy')}"
                      .toUpperCase(),
                ),
                titleTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
                bodyTextStyle: TextStyle(
                    color: KColors.new_black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
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
            showBackButton: true,
            onTapDoneButton: () {
              // Use Navigator.pushReplacement if you want to dispose the latest route
              // so the user will not be able to slide back to the Intro Views.
              _endOfTheSlides();
            },
            doneText: Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('done_text')}"),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KColors.primaryColor)),
            skipText: Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('skip_text')}"),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KColors.primaryColor)),
            nextText: Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)!.translate('next_text')} >"),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KColors.primaryColor)), //next
            backText: Text(
                "< " +
                    Utils.capitalize(
                        "${AppLocalizations.of(context)!.translate('previous_text')}"),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KColors.primaryColor)), //next
            /* pageButtonTextStyles: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold
            ),*/
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
    prefs
        .setBool(ServerConfig.SHARED_PREF_FIRST_TIME_IN_APP, false)
        .then((value) {
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
