import 'dart:async';
import 'dart:io';

import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
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
import 'package:uni_links/uni_links.dart';

import '../../../StateContainer.dart';

class SplashPage extends StatefulWidget { // translated

  static const String TRANSACTIONS = "TRANSACTIONS",
      RESTAURANT = "RESTAURANT",
      ORDER = "ORDER",
      FOOD = "FOOD",
      MENU = "MENU",
      REVIEW_ORDER = "REVIEW-ORDER",
      RESTAURANT_LIST = "RESTAURANT-LIST";

  static var routeName = "/SplashPage";

  var destination;

  var argument;

  SplashPage({Key key, this.destination = 0, this.argument = 0}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimeout();

    _listenToUniLinks();
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
          // check if there is a destination out of deep-linking before doing this.
          launchPage = HomePage(destination: widget.destination, argument: widget.argument);
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

  void _listenToUniLinks() {
    initUniLinks();
    initUniLinksStream();
  }

// uni-links
  Future<Null> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      print("initialLink ${initialLink}");
      _handleLinks(initialLink);
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      print("initialLink PlatformException");
    }
  }

  StreamSubscription _sub;

  Future<Null> initUniLinksStream() async {

    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
      // Parse the link and warn the user, if it is not correct
      print("initialLinkStream ${link}");
      _handleLinksImmediately(link);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      print("initialLinkStreamError");
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  void _handleLinksImmediately(String link) {

    // if you are logged in, we can just move to the activity.
    Uri mUri = Uri.parse(link);
//    mUri.scheme == "https";
    print("host -> ${mUri.host}");
    print("path -> ${mUri.path}");
    print("pathSegments -> ${mUri.pathSegments.toList().toString()}");

// adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://app.kaba-delivery.com/transactions"'

    List<String> pathSegments = mUri.pathSegments.toList();
    switch(pathSegments[0]) {
      case "transactions":
        _jumpToPage(context, TransactionHistoryPage(presenter: TransactionPresenter()));
        break;
      case "restaurants":
        widget.destination = SplashPage.RESTAURANT_LIST;
        break;
      case "restaurant":
        if (pathSegments.length > 1) {
          print("restaurant id -> ${pathSegments[1]}");
          widget.destination = SplashPage.RESTAURANT;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, RestaurantDetailsPage(restaurant: RestaurantModel(id: widget.argument),presenter: RestaurantDetailsPresenter()));
        }
        break;
      case "order":
        if (pathSegments.length > 1) {
          print("order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, OrderDetailsPage(orderId: widget.argument, presenter: OrderDetailsPresenter()));
        }
        break;
      case "food":
        if (pathSegments.length > 1) {
          print("food id -> ${pathSegments[1]}");
          widget.destination = SplashPage.FOOD;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, RestaurantFoodDetailsPage(foodId: widget.argument, presenter: FoodPresenter()));
        }
        break;
      case "menu":
        if (pathSegments.length > 1) {
          print("menu id -> ${pathSegments[1]}");
          widget.destination = SplashPage.MENU;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, RestaurantMenuPage(menuId: widget.argument, presenter: MenuPresenter()));
        }
        break;
      case "review-order":
        if (pathSegments.length > 1) {
          print("review-order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.REVIEW_ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, OrderDetailsPage(orderId: widget.argument, presenter: OrderDetailsPresenter()));
        }
        break;
    }
  }

  void _handleLinks(String link) {

    // if you are logged in, we can just move to the activity.
    Uri mUri = Uri.parse(link);
//    mUri.scheme == "https";
    print("host -> ${mUri.host}");
    print("path -> ${mUri.path}");
    print("pathSegments -> ${mUri.pathSegments.toList().toString()}");
/*
* /food/345
* /menu/890
* /orders
* /order/000
* /transactions
* /restaurant/900
*
* */

// adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://app.kaba-delivery.com/transactions"'

    List<String> pathSegments = mUri.pathSegments.toList();
//    if (pathSegments[0])
    switch(pathSegments[0]) {
      case "transactions":
        widget.destination = SplashPage.TRANSACTIONS;
        break;
      case "restaurants":
        widget.destination = SplashPage.RESTAURANT_LIST;
        break;
      case "restaurant":
        if (pathSegments.length > 1) {
          print("restaurant id -> ${pathSegments[1]}");
          widget.destination = SplashPage.RESTAURANT;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "order":
        if (pathSegments.length > 1) {
          print("order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "food":
        if (pathSegments.length > 1) {
          print("food id -> ${pathSegments[1]}");
          widget.destination = SplashPage.FOOD;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "menu":
        if (pathSegments.length > 1) {
          print("menu id -> ${pathSegments[1]}");
          widget.destination = SplashPage.MENU;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "review-order":
        if (pathSegments.length > 1) {
          print("review-order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.REVIEW_ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
    }
  }

  void _jumpToPage (BuildContext context, page) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

}
