import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaba_flutter/src/TestPage.dart';
import 'package:kaba_flutter/src/contracts/bestseller_contract.dart';
import 'package:kaba_flutter/src/contracts/evenement_contract.dart';
import 'package:kaba_flutter/src/contracts/feeds_contract.dart';
import 'package:kaba_flutter/src/contracts/food_contract.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/contracts/menu_contract.dart';
import 'package:kaba_flutter/src/contracts/order_contract.dart';
import 'package:kaba_flutter/src/contracts/transaction_contract.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_amount_confirmation_contract.dart';
import 'package:kaba_flutter/src/contracts/transfer_money_request_contract.dart';
import 'package:kaba_flutter/src/models/NotificationFDestination.dart';
import 'package:kaba_flutter/src/models/NotificationItem.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage2.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/HomeWelcomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/InfoPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/events/EventsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/MeAccountPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/feeds/FeedsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransferMoneyAmountConfirmationPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransferMoneyRequestPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransferMoneySuccessPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/AppConfig.dart';
import 'package:kaba_flutter/src/utils/_static_data/ImageAssets.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/routes.dart';

import 'StateContainer.dart';
import 'contracts/topup_contract.dart';
import 'locale/locale.dart';


void main() => runApp(StateContainer(child: MyApp()));

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class MyApp extends StatefulWidget {

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
    var initializationSettingsAndroid = new AndroidInitializationSettings('kaba_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
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
    );
  }

  @override
  Widget build(BuildContext context) {

    Image(image: AssetImage(ImageAssets.kaba_main));

    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        KabaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr'), // French
        const Locale('en'), // English
        const Locale('zh'), // Chinese
//        const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
      onGenerateTitle: (BuildContext context) =>
      "KABA",
      theme: ThemeData(primarySwatch: KColors.colorCustom),

//      home: RestaurantMenuPage(presenter: MenuPresenter(), restaurant: RestaurantModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
      home: SplashPage(),
//home: RestaurantFoodDetailsPage(presenter: FoodPresenter(), foodId: 1999) ,
//      home: TransactionHistoryPage(presenter: TransactionPresenter()),
//      home: TopUpPage(presenter: TopUpPresenter()),
//      home: FeedsPage(presenter: FeedPresenter(),),
//         home: EvenementPage(presenter: EvenementPresenter(),),
//      home: TestPage(),
//      home: TransferMoneySuccessPage(),
      routes: generalRoutes,
    );
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    print("onDidReceiveLocalNotification ${payload}");
    _handlePayLoad(payload);
  }

  Future onSelectNotification(String payload) {
    print("onSelectedNotification ${payload}");
    _handlePayLoad(payload);
  }

  NotificationItem _notificationFromMessage(message_entry) {

    if (Platform.isIOS) {
      // Android-specific code
      var destination = json.decode(message_entry["destination"].toString());
      NotificationItem notificationItem = new NotificationItem(
          title: message_entry["title"],
          body: message_entry["body"],
          image_link: message_entry["image_link"],
          priority: message_entry["priority"],
          destination: NotificationFDestination(type: destination["type"] as int, product_id: destination["product_id"] as int)
      );
      return notificationItem;
    } else if (Platform.isAndroid) {
      // IOS-specific code
      var destination = json.decode(message_entry["data"]["destination"].toString());
      NotificationItem notificationItem = new NotificationItem(
          title: message_entry["data"]["title"],
          body: message_entry["data"]["body"],
          image_link: message_entry["data"]["image_link"],
          priority: message_entry["data"]["priority"],
          destination: NotificationFDestination(type: destination["type"] as int, product_id: destination["product_id"] as int)
      );
      return notificationItem;
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

}


void iLaunchNotifications (NotificationItem notificationItem) async {

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConfig.CHANNEL_ID, AppConfig.CHANNEL_NAME, AppConfig.CHANNEL_DESCRIPTION,
      importance: Importance.Max, priority: Priority.High, ticker: notificationItem.title);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0, notificationItem.title, notificationItem.body, platformChannelSpecifics,
      payload: notificationItem.destination.toSpecialString()
  );
}



/*iLaunchNotifications (NotificationItem i) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//  flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails)
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}*/
