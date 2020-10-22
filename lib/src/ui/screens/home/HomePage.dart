import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
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
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'me/money/TransactionHistoryPage.dart';
import 'me/vouchers/AddVouchersPage.dart';
import 'me/vouchers/MyVouchersPage.dart';
import 'orders/DailyOrdersPage.dart';
import 'package:KABA/src/utils/_static_data/Core.dart';


class HomePage extends StatefulWidget {

  static var routeName = "/HomePage";

  var argument;

  var destination;

  CustomerModel customer;

  HomePage({Key key, this.destination, this.argument}) : super(key: key) ;

  @override
  _HomePageState createState() => _HomePageState();

  static void updateSelectedPage(int index) {
//    _selectedIndex = index;
  }
}


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


class _HomePageState extends State<HomePage> {



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
    try {
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
    } catch (_) {
      print ("error checklogin() ");
      launchPage = HomePage();
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

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
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
    });
    // FLUTTER NOTIFICATION
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = new AndroidInitializationSettings(
        'mipmap/ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    // firebase
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        /* send json version of notification object. */
        NotificationItem notificationItem = _notificationFromMessage(message);
        iLaunchNotifications(notificationItem);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        /* send json version of notification object. */
        NotificationItem notificationItem = _notificationFromMessage(message);
        iLaunchNotifications(notificationItem);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        /* send json version of notification object. */
        NotificationItem notificationItem = _notificationFromMessage(message);
        iLaunchNotifications(notificationItem);
      },
      onBackgroundMessage: Platform.isIOS ? null : _backgroundMessageHandling,
    );

    _firebaseMessaging.subscribeToTopic(ServerConfig.TOPIC)
        .whenComplete(() async {
      SharedPreferences prefs_ = await SharedPreferences.getInstance();
      prefs_.setBool('has_subscribed', true);
    });

    Timer.run(() {
      // here we handle the signal
      initUniLinksStream();
    });
    //    popupMenus = ["${AppLocalizations.of(context).translate('settings')}"];
    //    jump to what i need to.
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    print("onDidReceiveLocalNotification ${payload}");
    _handlePayLoad(payload);
  }

  Future onSelectNotification(String payload) {
    print("onSelectedNotification ${payload}");
    _handlePayLoad(payload);
  }


  void _handlePayLoad(String payload) {
    NotificationFDestination notificationFDestination;

    try {
      notificationFDestination = NotificationFDestination
          .fromJson(json.decode(payload));
      print(notificationFDestination.toString());
    } catch (_) {
      print(_);
    }

    switch (notificationFDestination.type) {
    /* go to the activity we are supposed to go to with only the id */
      case NotificationFDestination.FOOD_DETAILS:
        _jumpToFoodDetailsWithId(notificationFDestination.product_id);
        break;
      case NotificationFDestination.COMMAND_PAGE:
      case NotificationFDestination.COMMAND_DETAILS:
      case NotificationFDestination.COMMAND_PREPARING:
      case NotificationFDestination.COMMAND_SHIPPING:
      case NotificationFDestination.COMMAND_END_SHIPPING:
      case NotificationFDestination.COMMAND_CANCELLED:
      case NotificationFDestination.COMMAND_REJECTED:
        _jumpToOrderDetailsWithId(notificationFDestination.product_id);
        break;
      case NotificationFDestination.MONEY_MOVMENT:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.SPONSORSHIP_TRANSACTION_ACTION:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.ARTICLE_DETAILS:
//        _jumpToArticleInterface(notificationFDestination.product_id);
        break;
      case NotificationFDestination.RESTAURANT_PAGE:
        _jumpToRestaurantDetailsPage(notificationFDestination.product_id);
        break;
      case NotificationFDestination.RESTAURANT_MENU:
        _jumpToRestaurantMenuPage(notificationFDestination.product_id);
        break;
      case NotificationFDestination.MESSAGE_SERVICE_CLIENT:
        _jumpToServiceClient();
        break;
      case NotificationFDestination.IMPORTANT_INFORMATION:
      /* important information */
        break;
    }
  }


  void _jumpToFoodDetailsWithId(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: -1*product_id);
  }


  void _jumpToOrderDetailsWithId(int product_id) {
    navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToTransactionHistory() {
    navigatorKey.currentState.pushNamed(TransactionHistoryPage.routeName);
  }

  /* void _jumpToArticleInterface(int product_id) {
    navigatorKey.currentState.pushNamed(WebViewPage.routeName, arguments: product_id);
  }*/

  void _jumpToRestaurantDetailsPage(int product_id) {
    /* send a negative id when we want to show the food inside the menu */
//    navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: product_id);
    _jumpToPage(context, RestaurantDetailsPage(restaurantId: product_id,presenter: RestaurantDetailsPresenter()));
  }

  void _jumpToRestaurantMenuPage(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: product_id);
  }

  void _jumpToServiceClient() {
    navigatorKey.currentState.pushNamed(CustomerCareChatPage.routeName);
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
      case "voucher":
        if (pathSegments.length > 1) {
          print("voucher id homepage -> ${pathSegments[1]}");
          widget.destination = SplashPage.VOUCHER;
          /* convert from hexadecimal to decimal */
          widget.argument = "${pathSegments[1]}";
          _jumpToPage(context, AddVouchersPage(presenter: AddVoucherPresenter(), qrCode: "${widget.argument}".toUpperCase(),customer: widget.customer));
        }
        break;
      case "vouchers":
        print("vouchers page");
        widget.destination = SplashPage.VOUCHERS;
        /* convert from hexadecimal to decimal */
        _jumpToPage(context, MyVouchersPage(presenter: VoucherPresenter()));
        break;
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
          /* convert from hexadecimal to decimal */
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
//          widget.argument = mHexToInt("${pathSegments[1]}");
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
//          widget.argument = mHexToInt("${pathSegments[1]}");
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
//          widget.argument = mHexToInt("${pathSegments[1]}");
          _jumpToPage(context, RestaurantMenuPage(
              menuId: widget.argument, presenter: MenuPresenter()));
        }
        break;
      case "review-order":
        if (pathSegments.length > 1) {
          print("review-order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.REVIEW_ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
//          widget.argument = mHexToInt("${pathSegments[1]}");
          _jumpToPage(context, OrderDetailsPage(
              orderId: widget.argument, presenter: OrderDetailsPresenter()));
//          navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: pathSegments[1]);
        }
        break;
    }
    pathSegments[0] = null;
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


Future<dynamic> _backgroundMessageHandling(Map<String, dynamic> message) async {
  print("onBackgroundMessage: $message");
/* send json version of notification object. */
  if (Platform.isAndroid) {
    NotificationItem notificationItem = _notificationFromMessage(message);
    return iLaunchNotifications(notificationItem);
  }
  return Future.value(0);
}

NotificationItem _notificationFromMessage(Map<String, dynamic> message_entry) {

  if (Platform.isIOS) {
// Android-specific code
    try {
      var _data = json.decode(message_entry["data"])["data"];
      NotificationItem notificationItem = new NotificationItem(
          title: _data["notification"]["title"],
          body: _data["notification"]["body"],
          image_link: _data["notification"]["image_link"],
          priority: "${_data["notification"]["destination"]["priority"]}",
          destination: NotificationFDestination(
              type: _data["notification"]["destination"]["type"],
              product_id: int.parse("${_data["notification"]["destination"]["product_id"] == null ? 0 : _data["notification"]["destination"]["product_id"] }"))
      );
      return notificationItem;
    } catch (_) {
      print(_);
    }
  } else if (Platform.isAndroid) {
// IOS-specific code
    try {
      var _data = json.decode(message_entry["data"]["data"])["data"];

      NotificationItem notificationItem = new NotificationItem(
          title: _data["notification"]["title"],
          body: _data["notification"]["body"],
          image_link: _data["notification"]["image_link"],
          priority: "${_data["notification"]["destination"]["priority"]}",
          destination: NotificationFDestination(
              type: int.parse("${_data["notification"]["destination"]["type"]}"),
              product_id: int.parse("${_data["notification"]["destination"]["product_id"]}"))
      );
      return notificationItem;
    } catch (_) {
      print(_);
    }
  }
  return null;
}

Future<void> iLaunchNotifications (NotificationItem notificationItem) async {

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConfig.CHANNEL_ID, AppConfig.CHANNEL_NAME, AppConfig.CHANNEL_DESCRIPTION,
      importance: Importance.Max, priority: Priority.High, ticker: notificationItem?.title);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  return flutterLocalNotificationsPlugin.show(
      0, notificationItem?.title, notificationItem?.body, platformChannelSpecifics,
      payload: notificationItem?.destination?.toSpecialString()
  );
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
