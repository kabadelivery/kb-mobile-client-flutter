import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaba_flutter/src/contracts/bestseller_contract.dart';
import 'package:kaba_flutter/src/contracts/evenement_contract.dart';
import 'package:kaba_flutter/src/contracts/feeds_contract.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/contracts/menu_contract.dart';
import 'package:kaba_flutter/src/contracts/order_contract.dart';
import 'package:kaba_flutter/src/contracts/transaction_contract.dart';
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
import 'package:kaba_flutter/src/ui/screens/home/me/settings/WebViewPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:kaba_flutter/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/ImageAssets.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/routes.dart';

import 'contracts/topup_contract.dart';
import 'locale/locale.dart';


void main() => runApp(MyApp());

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _firebaseMessaging = FirebaseMessaging();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('kaba_icon');
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
//        _showItemDialog(message);
        iLaunchNotifications();
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
//        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
//        _navigateToItemDetail(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    Image(image: AssetImage(ImageAssets.kaba_main));

    return MaterialApp(
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
//      home: TransactionHistoryPage(presenter: TransactionPresenter()),
//      home: TopUpPage(presenter: TopUpPresenter()),
//      home: FeedsPage(presenter: FeedPresenter(),),
//         home: EvenementPage(presenter: EvenementPresenter(),),
      routes: generalRoutes,
    );
  }

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Item ${item.itemId} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    print("onDidReceiveLocalNotification ${payload}");
  }

  Future onSelectNotification(String payload) {
    print("onSelectedNotification ${payload}");
  }
}

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
          () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}


class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item ${_item.itemId}"),
      ),
      body: Material(
        child: Center(child: Text("Item status: ${_item.status}")),
      ),
    );
  }
}

iLaunchNotifications () async {
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
}
