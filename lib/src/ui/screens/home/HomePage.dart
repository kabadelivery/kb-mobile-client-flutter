import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/service_category_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/buy/main/ServiceMainPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import '_home/HomeWelcomePage.dart';
import 'me/MeAccountPage.dart';
import 'me/money/TransactionHistoryPage.dart';
import 'me/vouchers/AddVouchersPage.dart';
import 'me/vouchers/MyVouchersPage.dart';
import 'orders/DailyOrdersPage.dart';

class HomePage extends StatefulWidget {
  static var routeName = "/HomePage";

  var argument;

  var destination;

  CustomerModel customer;

  HomePage({Key key, this.destination, this.argument}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

  static void updateSelectedPage(int index) {
//    _selectedIndex = index;
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class _HomePageState extends State<HomePage> {
  HomeWelcomePage homeWelcomePage;

  // RestaurantListPage restaurantListPage;
  ServiceMainPage serviceMainPage;
  DailyOrdersPage dailyOrdersPage;
  MeAccountPage meAccountPage;

  List<StatefulWidget> pages;

  final PageStorageBucket bucket = PageStorageBucket();

  final PageStorageKey homeKey = PageStorageKey("homeKey"),
      // restaurantKey = PageStorageKey("restaurantKey"),
      serviceMainKey = PageStorageKey("serviceMainKey"),
      orderKey = PageStorageKey("orderKey"),
      meKey = PageStorageKey("meKey");

  SharedPreferences prefs;

  Future<int> checkLogin() async {
    StatefulWidget launchPage = LoginPage(presenter: LoginPresenter());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expDate = prefs.getString("_login_expiration_date");
    int res = 0; // not logged in
    try {
      if (expDate != null) {
        if (DateTime.now()
            .isAfter(DateTime.fromMillisecondsSinceEpoch(int.parse(expDate)))) {
          /* session expired : clean params */
          prefs.remove("_customer");
          prefs.remove("_token");
          prefs.remove("_login_expiration_date");
        } else {
          res = 1; // is logged in
        }
      }
    } catch (_) {
      xrint("error checklogin() ");
      res = 0; // not logged in
    }
    return res;
  }

  // 0 not logged in
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    homeWelcomePage = HomeWelcomePage(
        key: homeKey,
        presenter: HomeWelcomePresenter(),
        destination: widget.destination,
        argument: widget.argument);
    // restaurantListPage = RestaurantListPage(context: context,
    //     key: restaurantKey, foodProposalPresenter: RestaurantFoodProposalPresenter(), restaurantListPresenter: RestaurantListPresenter());
    serviceMainPage = ServiceMainPage(
        key: serviceMainKey , presenter: ServiceMainPresenter());
    dailyOrdersPage =
        DailyOrdersPage(key: orderKey, presenter: DailyOrderPresenter());
    meAccountPage = MeAccountPage(key: meKey);
    pages = [
      homeWelcomePage,
      serviceMainPage,
      // restaurantListPage,
      dailyOrdersPage,
      meAccountPage
    ];
    super.initState();
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      /* if you are email... and you've been created in the last 2 minutes... congratualitions, you've created e-main account. */
      /* make sure you show it once on a single device... */

      SharedPreferences.getInstance().then((value) async {
        prefs = value;

        String _has_seen_email_account_notification =
            prefs.getString("_has_seen_email_account_notification");

        if (_has_seen_email_account_notification != "1" &&
            Utils.isEmailValid(customer?.email))
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context).translate('welcome')}"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            ImageAssets.diaspora,
                            height: 100.0,
                            width: 100.0,
                            alignment: Alignment.center,
                          )),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context).translate("congrats_for_email_account")} 😊",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center)
                      /*      RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${AppLocalizations.of(context).translate("congrats_for_email_account")}',
                      ),
                      TextSpan(
                        text: '😊', // emoji characters
                        // style: TextStyle(
                        //   fontFamily: 'EmojiOne',
                        // ),
                      ),
                    ],
                  ),
                )*/
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child:
                        Text("${AppLocalizations.of(context).translate('ok')}"),
                    onPressed: () {
                      prefs.setString(
                          "_has_seen_email_account_notification", "1");
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
      });
    });
    // FLUTTER NOTIFICATION
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging.instance;

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettingsMacOs = MacOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    // new try
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      xrint('pnotif Got a message whilst in the foreground!');
      xrint("FirebaseMessaging.onMessage.listen");
      xrint('pnotif Message data: ${message.data}');

      if (message.notification != null) {
        xrint(
            'pnotif Message also contained a notification: ${message.notification.toString()}');

        NotificationItem notificationItem =
            _notificationFromMessage(message.data);
        iLaunchNotifications(notificationItem);
      }
    });

    _firebaseMessaging
        .subscribeToTopic(ServerConfig.TOPIC)
        .whenComplete(() async {
      SharedPreferences prefs_ = await SharedPreferences.getInstance();
      prefs_.setBool('has_subscribed', true);
    });

    Timer.run(() {
      // here we handle the signal
      initUniLinksStream();
    });
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  Future<void> _firebaseMessagingOpenedAppHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    xrint("_firebaseMessagingOpenedAppHandler: ${message.data})");
    if (message.notification != null) {
      xrint('p_notify Message also contained a notification: ${message.data}');
      NotificationItem notificationItem =
          _notificationFromMessage(message.data);
      _handlePayLoad(notificationItem.destination.toSpecialString());
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();

    xrint("_firebaseMessagingBackgroundHandler: ${message.data})");
    if (message.notification != null) {
      xrint('p_notify Message also contained a notification: ${message.data}');
      NotificationItem notificationItem =
          _notificationFromMessage(message.data);
      _handlePayLoad(notificationItem.destination.toSpecialString());
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    xrint("onDidReceiveLocalNotification ${payload}");
    _handlePayLoad(payload);
  }

  Future onSelectNotification(String payload) {
    xrint("onSelectedNotification ${payload}");
    _handlePayLoad(payload);
  }

  void _handlePayLoad(String payload) {
    NotificationFDestination notificationFDestination;

    try {
      notificationFDestination =
          NotificationFDestination.fromJson(json.decode(payload));
      xrint(notificationFDestination.toString());
    } catch (_) {
      xrint(_);
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
    _jumpToPage(context,
        RestaurantMenuPage(foodId: product_id, presenter: MenuPresenter()));
    // navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: -1*product_id);
  }

  void _jumpToOrderDetailsWithId(int product_id) {
    _jumpToPage(
        context,
        OrderDetailsPage(
            orderId: product_id, presenter: OrderDetailsPresenter()));
    // navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToTransactionHistory() {
    xrint("_jumpINGToTransactionHistory");
    _jumpToPage(
        context, TransactionHistoryPage(presenter: TransactionPresenter()));
    // navigatorKey.currentState.pushNamed(TransactionHistoryPage.routeName);
  }

  /* void _jumpToArticleInterface(int product_id) {
    navigatorKey.currentState.pushNamed(WebViewPage.routeName, arguments: product_id);
  }*/

  void _jumpToRestaurantDetailsPage(int product_id) {
    /* send a negative id when we want to show the food inside the menu */
//    navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: product_id);
    _jumpToPage(
        context,
        RestaurantDetailsPage(
            restaurantId: product_id, presenter: RestaurantDetailsPresenter()));
  }

  void _jumpToRestaurantMenuPage(int product_id) {
    _jumpToPage(context,
        RestaurantMenuPage(menuId: product_id, presenter: MenuPresenter()));
    // navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: product_id);
  }

  void _jumpToServiceClient() {
    _jumpToPage(
        context, CustomerCareChatPage(presenter: CustomerCareChatPresenter()));
    // navigatorKey.currentState.pushNamed(CustomerCareChatPage.routeName);
  }

  int loginStuffChecked = 0;

  @override
  Widget build(BuildContext context) {
    if (loginStuffChecked == 0) {
      /* check the login status */
      checkLogin().then((value) {
        StateContainer.of(context).updateLoggingState(state: value);
      }); // keep the value somewhere

      // Get any messages which caused the application to open from
      // a terminated state.
      // if (StateContainer
      //     .of(context)
      //     .loggingState == 1) {
      try {
        _firebaseMessaging.getInitialMessage().then((initialMessage) {
          if (initialMessage != null) {
            _firebaseMessagingOpenedAppHandler(initialMessage);
          } else {
            FirebaseMessaging.onBackgroundMessage(
                _firebaseMessagingBackgroundHandler);
            FirebaseMessaging.onMessageOpenedApp
                .listen(_firebaseMessagingOpenedAppHandler);
          }
        });
      } catch (_) {
        xrint(
            "===========================================================\nYOU MUST LOGIN BEFORE\n===============================================");
      }
      // }

      loginStuffChecked = 1;
    }
    return Scaffold(
      body: pages[StateContainer.of(context).tabPosition],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.home), // Icon(Icons.home),
            activeIcon: SvgPicture.asset(VectorsData.home_selected),
            label: ("${AppLocalizations.of(context).translate('home')}"),
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.restaurant),
            // label: ('${AppLocalizations.of(context).translate('restaurant')}'),
            icon: SvgPicture.asset(VectorsData.buy), // Icon(FontAwesomeIcons.shoppingCart),
            activeIcon: SvgPicture.asset(VectorsData.buy_selected),
            label: ('${AppLocalizations.of(context).translate('buy')}'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.orders), // Icon(Icons.view_list),
            activeIcon: SvgPicture.asset(VectorsData.orders_selected),
            label: ('${AppLocalizations.of(context).translate('orders')}'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.me), //  Icon(Icons.person),
            activeIcon: SvgPicture.asset(VectorsData.me_selected),
            label: ('${AppLocalizations.of(context).translate('account')}'),
          ),
        ],
        currentIndex: StateContainer.of(context).tabPosition,
        selectedItemColor: KColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }

  /* keep gps location inside STATE CONTAINER and use it even for the map. */
  _onItemTapped(int value) {
    /* first check if user is connected / logged in
    * - if yes, switch
    * - otherwise, no switch, send him to login page...
    *
    * */
    var msg = [
      "please_login_before_going_forward_description_orders",
      "please_login_before_going_forward_description_account"
    ];
    if (value == 2 || value == 3) {
      if (StateContainer.of(context).loggingState == 0) {
        // not logged in... show dialog and also go there
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('please_login_before_going_forward_title')}"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    /* add an image*/
                    // location_permission
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  new AssetImage(ImageAssets.login_description),
                            ))),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context).translate(msg[value % 2])}",
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('not_now')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('login')}"),
                  onPressed: () {
                    /* */
                    /* jump to login page... */
                    Navigator.of(context).pop();

                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            LoginPage(presenter: LoginPresenter())));
                  },
                )
              ],
            );
          },
        );
      } else {
        /* zwitch */
        setState(() {
          StateContainer.of(context).updateTabPosition(tabPosition: value);
        });
        if (value == 3) {
          // ask for permission gps
          xrint("we are starting to load balance fees");
          //
        }
      }
    } else {
      // 0,1
      setState(() {
        StateContainer.of(context).updateTabPosition(tabPosition: value);
      });
    }
  }

  StreamSubscription _sub;

  Future<Null> initUniLinksStream() async {
    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
      // Parse the link and warn the user, if it is not correct
      if (link == null) return;
      xrint("initialLinkStream ${link}");
      // send the links to home page to handle them instead
      _handleLinksImmediately(link);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      xrint("initialLinkStreamError");
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  void _handleLinksImmediately(String link) {
    if (!(DateTime.now().millisecondsSinceEpoch -
            StateContainer.of(context).lastTimeLinkMatchAction >
        2000)) {
      return;
    }

    StateContainer.of(context).lastTimeLinkMatchAction =
        DateTime.now().millisecondsSinceEpoch;

    // if you are logged in, we can just move to the activity.
    Uri mUri = Uri.parse(link);
//    mUri.scheme == "https";
    xrint("host -> ${mUri.host}");
    xrint("path -> ${mUri.path}");
    xrint("pathSegments -> ${mUri.pathSegments.toList().toString()}");

// adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://app.kaba-delivery.com/transactions"'

    if (link.substring(0, 3).compareTo("geo") == 0 &&
        CustomerUtils.isGpsLocation("${mUri.path}")) {
      // we have a gps location
      xrint("path is gps location -> ${link}");
      /*6.33:3.44*/
      _checkIfLoggedInAndDoAction(() {
        StateContainer.of(context).tabPosition = 3;
        _jumpToPage(
            context,
            MyAddressesPage(
                presenter: AddressPresenter(),
                gps_location: "${mUri.path}".replaceAll(",", ":")));
      });
    } else {
      // we dont have  a gps location
      xrint("path is not gps location -> ${link}");

      List<String> pathSegments = mUri.pathSegments.toList();
      /*
     * send informations to homeactivity, that may send them to either restaurant page, or menu activity, before the end food activity
     * */
      switch (pathSegments[0]) {
        case "voucher":
          _checkIfLoggedInAndDoAction(() {
            if (pathSegments.length > 1) {
              xrint("voucher id homepage -> ${pathSegments[1]}");
              widget.destination = SplashPage.VOUCHER;
              /* convert from hexadecimal to decimal */
              widget.argument = "${pathSegments[1]}";
              _jumpToPage(
                  context,
                  AddVouchersPage(
                      presenter: AddVoucherPresenter(),
                      qrCode: "${widget.argument}".toUpperCase(),
                      customer: widget.customer));
            }
          });
          break;
        case "vouchers":
          _checkIfLoggedInAndDoAction(() {
            xrint("vouchers page");
            widget.destination = SplashPage.VOUCHERS;
            /* convert from hexadecimal to decimal */
            _jumpToPage(context, MyVouchersPage(presenter: VoucherPresenter()));
          });
          break;
        case "addresses":
          _checkIfLoggedInAndDoAction(() {
            xrint("addresses page");
            widget.destination = SplashPage.ADDRESSES;
            /* convert from hexadecimal to decimal */
            _jumpToPage(
                context, MyAddressesPage(presenter: AddressPresenter()));
          });
          break;
        case "transactions":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context,
                TransactionHistoryPage(presenter: TransactionPresenter()));
          });
          break;
        case "restaurants":
          //    widget.destination = SplashPage.RESTAURANT_LIST;
          setState(() {
            StateContainer.of(context).updateTabPosition(tabPosition: 1);
          });
          break;
        case "restaurant":
          if (pathSegments.length > 1) {
            xrint("restaurant id -> ${pathSegments[1]}");
            widget.destination = SplashPage.RESTAURANT;
            /* convert from hexadecimal to decimal */
            widget.argument = int.parse("${pathSegments[1]}");
            _jumpToPage(
                context,
                RestaurantDetailsPage(
                    restaurant: ShopModel(id: widget.argument),
                    presenter: RestaurantDetailsPresenter()));
//          navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: pathSegments[1]);
          }
          break;
        case "order":
          _checkIfLoggedInAndDoAction(() {
            if (pathSegments.length > 1) {
              xrint("order id -> ${pathSegments[1]}");
              widget.destination = SplashPage.ORDER;
              widget.argument = int.parse("${pathSegments[1]}");
              _jumpToPage(
                  context,
                  OrderDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter()));
            }
          });
          break;
        case "food":
          if (pathSegments.length > 1) {
            xrint("food id -> ${pathSegments[1]}");
            widget.destination = SplashPage.FOOD;
            widget.argument = int.parse("${pathSegments[1]}");
            _jumpToPage(
                context,
                RestaurantMenuPage(
                    foodId: widget.argument, presenter: MenuPresenter()));
          }
          break;
        case "menu":
          if (pathSegments.length > 1) {
            xrint("menu id -> ${pathSegments[1]}");
            widget.destination = SplashPage.MENU;
            widget.argument = int.parse("${pathSegments[1]}");
//          widget.argument = mHexToInt("${pathSegments[1]}");
            _jumpToPage(
                context,
                RestaurantMenuPage(
                    menuId: widget.argument, presenter: MenuPresenter()));
          }
          break;
        case "review-order":
          _checkIfLoggedInAndDoAction(() {
            if (pathSegments.length > 1) {
              xrint("review-order id -> ${pathSegments[1]}");
              widget.destination = SplashPage.REVIEW_ORDER;
              widget.argument = int.parse("${pathSegments[1]}");
              _jumpToPage(
                  context,
                  OrderDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter()));
            }
          });
          break;
      }
      pathSegments[0] = null;
    }
  }

  void _handleLinks(String link) {
    // if you are logged in, we can just move to the activity.
    if (link == null) return;

    Uri mUri = Uri.parse(link);
//    mUri.scheme == "https";
    xrint("host -> ${mUri.host}");
    xrint("path -> ${mUri.path}");
    xrint("pathSegments -> ${mUri.pathSegments.toList().toString()}");
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
          xrint("restaurant id -> ${pathSegments[1]}");
          widget.destination = SplashPage.RESTAURANT;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "order":
        if (pathSegments.length > 1) {
          xrint("order id -> ${pathSegments[1]}");
          widget.destination = SplashPage.ORDER;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "food":
        if (pathSegments.length > 1) {
          xrint("food id -> ${pathSegments[1]}");
          widget.destination = SplashPage.FOOD;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "menu":
        if (pathSegments.length > 1) {
          xrint("menu id -> ${pathSegments[1]}");
          widget.destination = SplashPage.MENU;
          widget.argument = int.parse("${pathSegments[1]}");
        }
        break;
      case "review-order":
        if (pathSegments.length > 1) {
          xrint("review-order id -> ${pathSegments[1]}");
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
        ));
  }

  void _checkIfLoggedInAndDoAction(Function callback) {
    if (StateContainer.of(context).loggingState == 0) {
      // not logged in... show dialog and also go there
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "${AppLocalizations.of(context).translate('please_login_before_going_forward_title')}"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  /* add an image*/
                  // location_permission
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                new AssetImage(ImageAssets.login_description),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate("please_login_before_going_forward_random")}",
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    "${AppLocalizations.of(context).translate('not_now')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('login')}"),
                onPressed: () {
                  /* */
                  /* jump to login page... */
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoginPage(presenter: LoginPresenter())));
                },
              )
            ],
          );
        },
      );
    } else {
      callback();
    }
  }
}

/*

Future<dynamic> _backgroundMessageHandling(Map<String, dynamic> message) async {
  xrint("onBackgroundMessage: $message");
*/
/* send json version of notification object. */ /*

  if (Platform.isAndroid) {
    NotificationItem notificationItem = _notificationFromMessage(message);
    return iLaunchNotifications(notificationItem);
  } else {
    NotificationItem notificationItem = _notificationFromMessage(message);
    return iLaunchNotifications(notificationItem);
  }
  return Future.value(0);
}
*/

NotificationItem _notificationFromMessage(Map<String, dynamic> message_entry) {
  xrint(" inside notificationFromMessage -- " + message_entry.toString());

  if (Platform.isIOS) {
// Android-specific code
    try {
      var _data = json.decode(message_entry["data"])["data"];
      xrint(" inside notificationFromMessage 840 -- " + _data.toString());
      NotificationItem notificationItem = new NotificationItem(
          title: _data["notification"]["title"],
          body: _data["notification"]["body"],
          image_link: _data["notification"]["image_link"],
          priority: "${_data["notification"]["destination"]["priority"]}",
          destination: NotificationFDestination(
              type: _data["notification"]["destination"]["type"],
              product_id: int.parse(
                  "${_data["notification"]["destination"]["product_id"] == null ? 0 : _data["notification"]["destination"]["product_id"]}")));
      return notificationItem;
    } catch (_) {
      xrint(_.toString());
    }
  } else if (Platform.isAndroid) {
// IOS-specific code
    try {
      var _data = json.decode(message_entry["data"])["data"];
      xrint(" inside notificationFromMessage 857 -- " + _data.toString());
      NotificationItem notificationItem = new NotificationItem(
          title: _data["notification"]["title"],
          body: _data["notification"]["body"],
          image_link: _data["notification"]["image_link"],
          priority: "${_data["notification"]["destination"]["priority"]}",
          destination: NotificationFDestination(
              type: _data["notification"]["destination"]["type"],
              product_id: int.parse(
                  "${_data["notification"]["destination"]["product_id"] == null ? 0 : _data["notification"]["destination"]["product_id"]}")));
      return notificationItem;
    } catch (_) {
      xrint(_.toString());
    }
  }
  return null;
}

Future<void> iLaunchNotifications(NotificationItem notificationItem) async {

  String groupKey = "tg.tmye.kaba.brave.one";

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConfig.CHANNEL_ID, AppConfig.CHANNEL_NAME,
      channelDescription: AppConfig.CHANNEL_DESCRIPTION,
      importance: Importance.max,
      priority: Priority.max,
      groupKey: groupKey,
      ticker: notificationItem?.title);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  return flutterLocalNotificationsPlugin.show(notificationItem.hashCode,
      notificationItem?.title, notificationItem?.body, platformChannelSpecifics,
      payload: notificationItem?.destination?.toSpecialString());
}
