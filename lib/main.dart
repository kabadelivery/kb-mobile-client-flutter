import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:KABA/src/TestPage2.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'src/StateContainer.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(StateContainer(child: MyApp(appLanguage: appLanguage)));
}



FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class MyApp extends StatefulWidget {

  var appLanguage;

  MyApp({this.appLanguage});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = new AndroidInitializationSettings('mipmap/ic_launcher');

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

    _firebaseMessaging.subscribeToTopic(ServerConfig.TOPIC).whenComplete(() async {
      SharedPreferences prefs_ = await SharedPreferences.getInstance();
      prefs_.setBool('has_subscribed', true);
    });
  }

  @override
  Widget build(BuildContext context) {

    Image(image: AssetImage(ImageAssets.kaba_main));

    return ChangeNotifierProvider<AppLanguage>(
        create: (_) => widget.appLanguage,
        child: Consumer<AppLanguage>(builder: (context, model, child) {
          return MaterialApp(
            supportedLocales: [
              Locale('en', 'US'),
              Locale('fr', 'FR'),
              Locale.fromSubtags(languageCode: 'zh')
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            onGenerateTitle: (BuildContext context) =>
//            "${AppLocalizations.of(context).translate('app_title')}",
            "KABA",
            theme: ThemeData(primarySwatch: KColors.colorCustom),
//      home: RestaurantMenuPage(presenter: MenuPresenter(), restaurant: RestaurantModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
            home: SplashPage(),
//    home: OrderFeedbackPage(presenter: OrderFeedbackPresenter()),
//    home: RestaurantFoodDetailsPage(presenter: FoodPresenter(), foodId: 1999) ,
//    home: TransactionHistoryPage(presenter: TransactionPresenter()),
//    home: TopUpPage(presenter: TopUpPresenter()),
//    home: FeedsPage(presenter: FeedPresenter(),),
//    home: EvenementPage(presenter: EvenementPresenter(),),
//    home: NotificationTestPage(),
//    home: TopUpPage(presenter: TopUpPresenter()),
//    home: WebViewPage(agreement: true),
//    home: WebTestPage(),
//    home: TransferMoneySuccessPage(),
//            home: MyVouchersPage(),
//            home: VoucherDetailsPage(),
            routes: generalRoutes,
          );
        }));
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    print("onDidReceiveLocalNotification ${payload}");
    _handlePayLoad(payload);
  }

  Future onSelectNotification(String payload) {
    print("onSelectedNotification ${payload}");
    _handlePayLoad(payload);
  }

  static  NotificationItem _notificationFromMessage(Map<String, dynamic> message_entry) {

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
                type: _data["notification"]["destination"]["type"],
                product_id: int.parse("${_data["notification"]["destination"]["product_id"] == null ? 0 : _data["notification"]["destination"]["product_id"] }"))
        );
        return notificationItem;
      } catch (_) {
        print(_);
      }
    }
  }

  void _jumpToFoodDetailsWithId(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantFoodDetailsPage.routeName, arguments: product_id);
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
        _jumpToArticleInterface(notificationFDestination.product_id);
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

    }
  }

  void _jumpToOrderDetailsWithId(int product_id) {
    navigatorKey.currentState.pushNamed(OrderDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToTransactionHistory() {
    navigatorKey.currentState.pushNamed(TransactionHistoryPage.routeName);
  }

  void _jumpToArticleInterface(int product_id) {
    navigatorKey.currentState.pushNamed(WebViewPage.routeName, arguments: product_id);
  }

  void _jumpToRestaurantDetailsPage(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToRestaurantMenuPage(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: product_id);
  }

  void _jumpToServiceClient() {
    navigatorKey.currentState.pushNamed(CustomerCareChatPage.routeName);
  }

  static Future<dynamic> _backgroundMessageHandling(Map<String, dynamic> message) {
    print("onBackgroundMessage: $message");
    /* send json version of notification object. */
    if (Platform.isAndroid) {
      NotificationItem notificationItem = _notificationFromMessage(message);
      return iLaunchNotifications(notificationItem);
    }
    return Future.value(0);
  }


}

Future<void> iLaunchNotifications (NotificationItem notificationItem) async {

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConfig.CHANNEL_ID, AppConfig.CHANNEL_NAME, AppConfig.CHANNEL_DESCRIPTION,
      importance: Importance.Max, priority: Priority.High, ticker: notificationItem?.title);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  return flutterLocalNotificationsPlugin.show(
      0, notificationItem.title, notificationItem.body, platformChannelSpecifics,
      payload: notificationItem.destination.toSpecialString()
  );
}

