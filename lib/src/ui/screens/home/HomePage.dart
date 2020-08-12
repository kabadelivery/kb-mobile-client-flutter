import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'me/money/TransactionHistoryPage.dart';
import 'orders/DailyOrdersPage.dart';

class HomePage extends StatefulWidget {

  static var routeName = "/HomePage";

  var argument;

  var destination;

  HomePage({Key key, this.destination, this.argument}) : super(key: key) ;

  @override
  _HomePageState createState() => _HomePageState();

  static void updateSelectedPage(int index) {
//    _selectedIndex = index;
  }
}



class _HomePageState extends State<HomePage> {

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<
      NavigatorState>();

  HomeWelcomePage homeWelcomePage;
  RestaurantListPage restaurantListPage;
  DailyOrdersPage dailyOrdersPage;
  MeAccountPage meAccountPage;

  List<StatefulWidget> pages;

  final PageStorageBucket bucket = PageStorageBucket();

  final PageStorageKey homeKey = PageStorageKey("homeKey"),
      restaurantKey = PageStorageKey("restaurantKey"),
      orderKey = PageStorageKey("orderKey"),
      meKey = PageStorageKey("meKey");

  Future checkLogin() async {
    StatefulWidget launchPage = LoginPage(presenter: LoginPresenter());
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
  }


  @override
  void initState() {
    /* check the login status */
    checkLogin();
    homeWelcomePage = HomeWelcomePage(key: homeKey,
        presenter: HomeWelcomePresenter(),
        destination: widget.destination,
        argument: widget.argument);
    restaurantListPage = RestaurantListPage(
        key: restaurantKey, presenter: RestaurantFoodProposalPresenter());
    dailyOrdersPage =
        DailyOrdersPage(key: orderKey, presenter: DailyOrderPresenter());
    meAccountPage = MeAccountPage(key: meKey);
    pages =
    [homeWelcomePage, restaurantListPage, dailyOrdersPage, meAccountPage];
    super.initState();
    Timer.run(() {
      // here we handle the signal
      initUniLinksStream();
    });
    //    popupMenus = ["${AppLocalizations.of(context).translate('settings')}"];
    //    jump to what i need to.


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[StateContainer
          .of(context)
          .tabPosition],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("${AppLocalizations.of(context).translate('home')}"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            title: Text(
                '${AppLocalizations.of(context).translate('restaurant')}'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            title: Text('${AppLocalizations.of(context).translate('orders')}'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('${AppLocalizations.of(context).translate('account')}'),
          ),
        ],
        currentIndex: StateContainer
            .of(context)
            .tabPosition,
        selectedItemColor: KColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  /* keep gps location inside STATE CONTAINER and use it even for the map. */
  void _onItemTapped(int value) {
    /* zwitch */
    setState(() {
      StateContainer.of(context).updateTabPosition(tabPosition: value);
    });
    if (value == 1) {
      // ask for permission gps
//     restaurantListPage._getLastKnowLocation();
    }
  }


  StreamSubscription _sub;

  Future<Null> initUniLinksStream() async {
    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
      // Parse the link and warn the user, if it is not correct
      if (link == null)
        return;
      print("initialLinkStream ${link}");
      // send the links to home page to handle them instead
      _handleLinksImmediately(link);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      print("initialLinkStreamError");
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  void _handleLinksImmediately(String link) {
    /* streams */

    // if you are logged in, we can just move to the activity.
    Uri mUri = Uri.parse(link);
//    mUri.scheme == "https";
    print("host -> ${mUri.host}");
    print("path -> ${mUri.path}");
    print("pathSegments -> ${mUri.pathSegments.toList().toString()}");

// adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://app.kaba-delivery.com/transactions"'

    List<String> pathSegments = mUri.pathSegments.toList();

    /*
     * send informations to homeactivity, that may send them to either restaurant page, or menu activity, before the end food activity
     * */

    switch (pathSegments[0]) {
      case "transactions":
        _jumpToPage(
            context, TransactionHistoryPage(presenter: TransactionPresenter()));
//        navigatorKey.currentState.pushNamed(TransactionHistoryPage.routeName);
        break;
      case "restaurants":
      //    widget.destination = SplashPage.RESTAURANT_LIST;
        setState(() {
          StateContainer.of(context).updateTabPosition(tabPosition: 1);
        });
        break;
      case "restaurant":
        if (pathSegments.length > 1) {
          print("restaurant id -> ${pathSegments[1]}");
          widget.destination = SplashPage.RESTAURANT;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, RestaurantDetailsPage(
              restaurant: RestaurantModel(id: widget.argument),
              presenter: RestaurantDetailsPresenter()));
//          navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: pathSegments[1]);
        }
        break;
      case "order":
        if (pathSegments.length > 1) {
          print("order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, OrderDetailsPage(
              orderId: widget.argument, presenter: OrderDetailsPresenter()));
//          navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: pathSegments[1]);
        }
        break;
      case "food":
        if (pathSegments.length > 1) {
          print("food id -> ${pathSegments[1]}");
          widget.destination = SplashPage.FOOD;
          widget.argument = int.parse("${pathSegments[1]}");
//          _jumpToPage(context, RestaurantFoodDetailsPage(foodId: widget.argument, presenter: FoodPresenter()));
          _jumpToPage(context, RestaurantMenuPage(
              foodId: widget.argument, presenter: MenuPresenter()));
        }
        break;
      case "menu":
        if (pathSegments.length > 1) {
          print("menu id -> ${pathSegments[1]}");
          widget.destination = SplashPage.MENU;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, RestaurantMenuPage(
              menuId: widget.argument, presenter: MenuPresenter()));
        }
        break;
      case "review-order":
        if (pathSegments.length > 1) {
          print("review-order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.REVIEW_ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
          _jumpToPage(context, OrderDetailsPage(
              orderId: widget.argument, presenter: OrderDetailsPresenter()));
//          navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: pathSegments[1]);
        }
        break;
    }
  }

  void _handleLinks(String link) {
    // if you are logged in, we can just move to the activity.
    if (link == null)
      return;

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
* */

// adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://app.kaba-delivery.com/transactions"'

    List<String> pathSegments = mUri.pathSegments.toList();
//    if (pathSegments[0])
    switch (pathSegments[0]) {
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

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}

class AppbarhintFieldWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child:TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText:"Play basketball with us today", hintMaxLines: 1, hintStyle: TextStyle(color:Colors.white))),
      color: Colors.transparent,
    );
  }

}
