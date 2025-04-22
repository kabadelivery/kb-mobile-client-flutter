import 'dart:async';
import 'dart:convert';

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
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/MeNewAccountPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/out_of_app.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/shipping_package.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import '../../../utils/functions/NotLoggedInPopUp.dart';
import '../../../utils/functions/OutOfAppOrder/dialogToFetchDistrict.dart';
import '_home/HomeWelcomeNewPage.dart';
import 'me/money/TransactionHistoryPage.dart';
import 'me/vouchers/AddVouchersPage.dart';
import 'me/vouchers/MyVouchersPage.dart';
import 'orders/DailyOrdersPage.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class HomePage extends StatefulWidget {
  static var routeName = "/HomePage";
  bool is_out_of_app_order;
  var argument;

  var destination;

  CustomerModel customer;

  var samePositionCount = 0;

  bool hasGps = false;

  HomePage(
      {Key key,
      this.destination,
      this.argument,
      this.is_out_of_app_order = false})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeWelcomeNewPage homeWelcomePage;

  ServiceMainPage serviceMainPage;
  DailyOrdersPage dailyOrdersPage;
  MeNewAccountPage meAccountPage;
  static String messageId = "";
  List<StatefulWidget> pages;
  final PageStorageBucket bucket = PageStorageBucket();

  final PageStorageKey homeKey = PageStorageKey("homeKey"),
      serviceMainKey = PageStorageKey("serviceMainKey"),
      orderKey = PageStorageKey("orderKey"),
      meKey = PageStorageKey("meKey");

  SharedPreferences prefs;

  var subscription;

  StreamSubscription<Position> positionStream;
  Position tmpLocation;

  Future<int> checkLogin() async {
    StatefulWidget launchPage = LoginPage(presenter: LoginPresenter());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expDate =
        prefs.getString("_login_expiration_date" + CustomerUtils.signature);
    int loginCheckResult = 0; // not logged in
    try {
      if (expDate != null) {
        if (DateTime.now()
            .isAfter(DateTime.fromMillisecondsSinceEpoch(int.parse(expDate)))) {
          _logout();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  content:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    SizedBox(
                        height: 80,
                        width: 80,
                        child: Icon(
                          Icons.account_circle,
                          color: KColors.primaryColor,
                        )),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context)!.translate('login_expired_please_login')}",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: KColors.new_black, fontSize: 13))
                  ]),
                  actions: <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('refuse')}",
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
                          "${AppLocalizations.of(context)!.translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _jumpToPage(context, launchPage);
                      },
                    ),
                  ]);
            },
          );
        } else {
          loginCheckResult = 1; // is logged in
        }
      }
    } catch (_) {
      xrint("error checklogin() ");
      loginCheckResult = 0; // not logged in
    }
    return loginCheckResult;
  }
  //sharedPreferences to save messageId

  void _logout() {
    CustomerUtils.clearCustomerInformations().whenComplete(() {
      StateContainer.of(context).updateLoggingState(state: 0);
      StateContainer.of(context).loggingState = 0;
      StateContainer.of(context).updateBalance(balance: 0);
      StateContainer.of(context).customer = null;
      StateContainer.of(context).myBillingArray = null;
      StateContainer.of(context).hasUnreadMessage = false;
      StateContainer.of(context).updateTabPosition(tabPosition: 0);
      Navigator.pushNamedAndRemoveUntil(
          context, SplashPage.routeName, (r) => false);
    });
  }

  // 0 not logged in
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    get_token();

    homeWelcomePage = HomeWelcomeNewPage(
        key: homeKey,
        presenter: HomeWelcomePresenter(),
        destination: widget.destination,
        argument: widget.argument);
    serviceMainPage =
        ServiceMainPage(key: serviceMainKey, presenter: ServiceMainPresenter());
    dailyOrdersPage = DailyOrdersPage(
        key: orderKey,
        presenter: DailyOrderPresenter(),
        is_out_of_app_order: widget.is_out_of_app_order);
    meAccountPage = MeNewAccountPage(key: meKey);
    pages = [homeWelcomePage, serviceMainPage, dailyOrdersPage, meAccountPage];
    super.initState();
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      /* if you are email... and you've been created in the last 2 minutes... congratulations, you've created e-mail account. */
      /* make sure you show it once on a single device... */

      SharedPreferences.getInstance().then((value) async {
        prefs = value;

        String _hasSeenEmailAccountNotification =
            prefs.getString("_hasSeenEmailAccountNotification");

        if (_hasSeenEmailAccountNotification != "1" &&
            Utils.isEmailValid(customer?.email))
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context)!.translate('welcome')}"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
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
                          "${AppLocalizations.of(context)!.translate("congrats_for_email_account")} 😊",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child:
                        Text("${AppLocalizations.of(context)!.translate('ok')}"),
                    onPressed: () {
                      prefs.setString("_hasSeenEmailAccountNotification", "1");
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
      });
    });

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
        if (message.messageId != messageId) {
          iLaunchNotifications(notificationItem);
          messageId = message.messageId;
        }
      }
    });

    _firebaseMessaging
        .subscribeToTopic(ServerConfig.TOPIC)
        .whenComplete(() async {
      SharedPreferences prefs_ = await SharedPreferences.getInstance();
      prefs_.setBool('has_subscribed', true);
    });

    Timer.run(() {
      initUniLinksStream();
    });

    Connectivity().checkConnectivity().then((connectivityResult) {
      if (!(connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi))
        StateContainer.of(context).is_offline = true;
      else
        StateContainer.of(context).is_offline = false;
    });

    // network
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      // Got a new connectivity status!
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        StateContainer.of(context).is_offline = false;
      } else {
        if (!StateContainer.of(context).is_offline) {
          SnackBar snackBar = SnackBar(
            content: Text(
                "${AppLocalizations.of(context)!.translate('offline_alert_description')}"),
            action: SnackBarAction(
              label: "${AppLocalizations.of(context)!.translate('ok')}"
                  .toUpperCase(),
              onPressed: () {
                // Some code to undo the change.
                ScaffoldMessenger.of(context).clearSnackBars();
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        StateContainer.of(context).is_offline = true;
      }
    });

    /* Save current address locally, then everytime the app restarts, we retrieve it. */
    CustomerUtils.getSavedAddressLocally().then((Position position) {
      if (position != null && position?.longitude != null) {
        setState(() {
          StateContainer.of(context).location = position;
        });
      }
    });

    CustomerUtils.getCustomer().then((value) {
      setState(() {
        StateContainer.of(context).customer = value;
      });
    });
    //  _resetValue();
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
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('refuse')}",
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
                          "${AppLocalizations.of(context)!.translate('accept')}",
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
                          "${AppLocalizations.of(context)!.translate('ok')}",
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
    xrint('p_notify Message also contained a notification: ${message.data}');
    NotificationItem notificationItem = _notificationFromMessage(message.data);
    _handlePayLoad(notificationItem.destination.toSpecialString());
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
    print('payloader $payload');

    Map<String, dynamic> notificationFDestination;
    String payloadData = '$payload';

    try {
      notificationFDestination = json.decode(payloadData);
      //  print('payloader ${notificationFDestination.type.toString()}');
      xrint(notificationFDestination.toString());
    } catch (e) {
      xrint(e);
    }
    int type = int.parse(notificationFDestination['type'].toString());
    int is_out_of_app =
        int.parse(notificationFDestination['is_out_of_app'].toString());
    int productId =
        int.parse(notificationFDestination['product_id'].toString());
    switch (type) {
      /* go to the activity we are supposed to go to with only the id */
      case NotificationFDestination.FOOD_DETAILS:
        _jumpToFoodDetailsWithId(productId);
        break;
      case NotificationFDestination.COMMAND_PAGE:
      case NotificationFDestination.COMMAND_DETAILS:
      case NotificationFDestination.COMMAND_PREPARING:
      case NotificationFDestination.COMMAND_SHIPPING:
      case NotificationFDestination.COMMAND_END_SHIPPING:
      case NotificationFDestination.COMMAND_CANCELLED:
      case NotificationFDestination.COMMAND_REJECTED:
        _jumpToOrderDetailsWithId(productId,
            is_out_of_app_order: is_out_of_app);
        break;
      case NotificationFDestination.MONEY_MOVMENT:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.SPONSORSHIP_TRANSACTION_ACTION:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.RESTAURANT_PAGE:
        _jumpToRestaurantDetailsPage(productId);
        break;
      case NotificationFDestination.RESTAURANT_MENU:
        _jumpToRestaurantMenuPage(productId);
        break;
      case NotificationFDestination.MESSAGE_SERVICE_CLIENT:
        _jumpToServiceClient();
        break;
    }
  }

  void _jumpToFoodDetailsWithId(int productId) {
    _jumpToPage(context,
        RestaurantMenuPage(foodId: productId, presenter: MenuPresenter(MenuView())));
  }

  void _jumpToOrderDetailsWithId(int productId, {int is_out_of_app_order = 0}) {
    _jumpToPage(
        context,
        OrderNewDetailsPage(
            is_out_of_app_order: is_out_of_app_order == 0 ? false : true,
            orderId: productId,
            presenter: OrderDetailsPresenter(OrderDetailsView())));
  }

  void _jumpToTransactionHistory() {
    xrint("_jumpINGToTransactionHistory");
    _jumpToPage(
        context, TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())));
  }

  void _jumpToRestaurantDetailsPage(int productId) {
    _jumpToPage(
        context,
        ShopDetailsPage(
            restaurantId: productId, presenter: RestaurantDetailsPresenter(RestaurantDetailsView())));
  }

  void _jumpToRestaurantMenuPage(int productId) {
    _jumpToPage(context,
        RestaurantMenuPage(menuId: productId, presenter: MenuPresenter(MenuView())));
  }

  void _jumpToServiceClient() {
    _jumpToPage(
        context, CustomerCareChatPage(presenter: CustomerCareChatPresenter(CustomerCareChatView())));
  }

  int loginStuffChecked = 0;
  //  //get device token
  void get_token() async {
    String token = await FirebaseMessaging.instance.getToken();
    print('Device token $token');
  }

  @override
  Widget build(BuildContext context) {
    if (loginStuffChecked == 0) {
      /* check the login status */
      checkLogin().then((value) {
        StateContainer.of(context).updateLoggingState(state: value);
      });

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
        selectedFontSize: 12.5,
        unselectedFontSize: 12,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.home), // Icon(Icons.home),
            activeIcon: SvgPicture.asset(VectorsData.home_selected),
            label: Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('home')}"),
            tooltip: Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('home')}"),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.buy),
            activeIcon: SvgPicture.asset(VectorsData.buy_selected),
            label: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('buy')}'),
            tooltip: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('buy')}'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.orders),
            // Icon(Icons.view_list),
            activeIcon: SvgPicture.asset(VectorsData.orders_selected),
            label: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('orders')}'),
            tooltip: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('orders')}'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(VectorsData.me), //  Icon(Icons.person),
            activeIcon: SvgPicture.asset(VectorsData.me_selected),
            label: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('account')}'),
            tooltip: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('account')}'),
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
                  "${AppLocalizations.of(context)!.translate('please_login_before_going_forward_title')}"),
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

                            image: new DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: new AssetImage(ImageAssets.login_description),
                        ))),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context)!.translate(msg[value % 2])}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14))
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('not_now')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('login')}"),
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
    } else if (value == 1) {
      _getLastKnowLocation(jumpToBuyPageDetails: true);
    } else {
      // 0
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription.cancel();
  }

  void _handleLinksImmediately(String link) async {
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
                TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())));
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
            // check if restaurant is out of app or colis
            if (pathSegments[1] == "795") {
              if (StateContainer.of(context).loggingState == 0) {
                NotLoggedInPopUp(context);
              } else {
                _jumpToPage(context, OutOfAppOrderPage());
              }
            } else if (pathSegments[1] == "794") {
              List<Map<String, dynamic>> districts = [];
              List<Map<String, dynamic>> cachedDistricts =
                  await CustomerUtils.getCachedDistricts();
              if (cachedDistricts != null && cachedDistricts.isNotEmpty) {
                districts = cachedDistricts;
              } else {
                try {
                  districts = await showLoadingDialog(context);
                  print("districts $districts");
                } catch (e) {
                  xrint("error $e");
                }
              }
              if (StateContainer.of(context).loggingState == 0) {
                NotLoggedInPopUp(context);
              } else {
                _jumpToPage(
                    context,
                    ShippingPackageOrderPage(
                      districts: districts,
                    ));
              }
            } else {
              _jumpToPage(
                  context,
                  ShopDetailsPage(
                      restaurant: ShopModel(id: widget.argument),
                      presenter: RestaurantDetailsPresenter(RestaurantDetailsView())));
            }
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
                  OrderNewDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter(OrderDetailsView())));
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
                    foodId: widget.argument, presenter: MenuPresenter(MenuView())));
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
                    menuId: widget.argument, presenter: MenuPresenter(MenuView())));
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
                  OrderNewDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter(OrderDetailsView())));
            }
          });
          break;
        case "customer-care-message":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context,
                CustomerCareChatPage(presenter: CustomerCareChatPresenter(CustomerCareChatView())));
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
      case "customer-care-message":
        widget.destination = SplashPage.CUSTOM_CARE;
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
                "${AppLocalizations.of(context)!.translate('please_login_before_going_forward_title')}"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  /* add an image*/
                  // location_permission
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          image: new DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: new AssetImage(ImageAssets.login_description),
                      ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context)!.translate("please_login_before_going_forward_random")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14))
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    "${AppLocalizations.of(context)!.translate('not_now')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context)!.translate('login')}"),
                onPressed: () {
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

  Future _getLastKnowLocation({bool jumpToBuyPageDetails = false}) async {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      String _has_accepted_gps = prefs.getString("_has_accepted_gps");
      /* no need to commit */
      /* expiration date in 3months */
      if (_has_accepted_gps != "ok") {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context)!.translate('request')}"
                      .toUpperCase(),
                  style: TextStyle(color: KColors.primaryColor)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    // location_permission
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            image: new DecorationImage(
                          image: new AssetImage(ImageAssets.address),
                        ))),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context)!.translate('location_explanation_pricing')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14))
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('refuse')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context)!.translate('accept')}"),
                  onPressed: () {
                    prefs.setString("_has_accepted_gps", "ok");
                    // call get location again...
                    Future.delayed(Duration(milliseconds: 1000), () {
                      _getLastKnowLocation(
                          jumpToBuyPageDetails: jumpToBuyPageDetails);
                    });
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        // permission has been accepted
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          /*  ---- */
          // await Geolocator.openAppSettings();
          /* ---- */
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context)!.translate('permission_')}"
                        .toUpperCase(),
                    style: TextStyle(color: KColors.primaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              image: new DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: new AssetImage(ImageAssets.address),
                          ))),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context)!.translate('request_location_permission')}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14))
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('accept')}"),
                    onPressed: () async {
                      /* */
                      await Geolocator.openAppSettings();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
          /* ---- */
        } else if (permission == LocationPermission.denied) {
          /* ---- */
          // Geolocator.requestPermission();
          /* ---- */
          return showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context)!.translate('permission_')}"
                        .toUpperCase(),
                    style: TextStyle(color: KColors.primaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              image: new DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: new AssetImage(ImageAssets.address),
                          ))),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context)!.translate('request_location_permission')}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14))
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('accept')}"),
                    onPressed: () async {
                      /* */
                      await Geolocator.requestPermission();
                      LocationPermission permission2 =
                          await Geolocator.checkPermission();
                      if (permission2 == LocationPermission.always ||
                          permission2 == LocationPermission.whileInUse) {
                        _getLastKnowLocation(
                            jumpToBuyPageDetails: jumpToBuyPageDetails);
                      }
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        } else {
          bool isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          if (!isLocationServiceEnabled) {
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      "${AppLocalizations.of(context)!.translate('permission_')}"
                          .toUpperCase(),
                      style: TextStyle(color: KColors.primaryColor)),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                image: new DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: new AssetImage(
                                  ImageAssets.location_permission),
                            ))),
                        SizedBox(height: 10),
                        Text(
                            "${AppLocalizations.of(context)!.translate('request_location_activation_permission')}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14))
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                          "${AppLocalizations.of(context)!.translate('refuse')}"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                          "${AppLocalizations.of(context)!.translate('accept')}"),
                      onPressed: () async {
                        /* */
                        Navigator.of(context).pop();
                        await Geolocator.openLocationSettings();
                      },
                    )
                  ],
                );
              },
            );
            /* ---- */
          } else {
            /* show loading dialog until this finishes then close */

            // switch to page two
            if (jumpToBuyPageDetails) {
              setState(() {
                StateContainer.of(context).updateTabPosition(tabPosition: 1);
              });
            }

            positionStream =
                Geolocator.getPositionStream().listen((Position position) {
              /* compare current and old position */
              if (position?.latitude != null &&
                  tmpLocation?.latitude != null &&
                  (position.latitude * 100).round() ==
                      (tmpLocation.latitude * 100).round() &&
                  (position.longitude * 100).round() ==
                      (tmpLocation.longitude * 100).round()) {
                widget.samePositionCount++;
              } else {
                widget.samePositionCount = 0;
                tmpLocation = StateContainer.of(context).location;
                if (position != null && mounted) {
                  widget.hasGps = true;
                  setState(() {
                    StateContainer.of(context)
                        .updateLocation(location: position);
                  });
                }
              }
              if (widget.samePositionCount >= 3 || widget.hasGps)
                positionStream?.cancel();
            });
          }
        }
      }
    });
  }

  void _requestGpsPermissionAndLocation() {
    /* has been requested already, we shouldnt request a second time during this time */
    //  explain to the user why we need it, and then pick it
    if (!StateContainer.of(context).location_asked)
      StateContainer.of(context).location_asked = true;
    else
      return;
    if (mounted) {
      _getLastKnowLocation();
      if (widget.hasGps == false &&
          StateContainer?.of(context)?.location != null) {
        xrint("init -- 1");
      } else {}
    }
  }
}

NotificationItem _notificationFromMessage(Map<String, dynamic> messageEntry) {
  xrint(" inside notificationFromMessage -- " + messageEntry.toString());

  try {
    var _data = jsonDecode(messageEntry["notification"]);
    Map<String, dynamic> destinationData = jsonDecode(_data["destination"]);
    NotificationItem notificationItem = new NotificationItem(
        title: _data["title"],
        body: _data["body"],
        image_link: _data["image_link"],
        priority: destinationData['priority'].toString(),
        destination: NotificationFDestination(
            type: int.parse(destinationData['type'].toString()),
            product_id: int.parse(destinationData["product_id"].toString()),
            is_out_of_app:
                int.parse(destinationData['is_out_of_app'].toString())));
    return notificationItem;
  } catch (_) {
    xrint(_.toString());
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
