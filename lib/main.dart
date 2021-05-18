import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/KabaScanPage.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/StateContainer.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: KColors.primaryColor, // navigation bar color
  ));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(StateContainer(child: MyApp(appLanguage: appLanguage)));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("onBackgroundMessage: $message");
/* send json version of notification object. */
//  if (Platform.isAndroid) {
//    NotificationItem notificationItem = _notificationFromMessage(message);
//    return iLaunchNotifications(notificationItem);
//  }
//  return Future.value(0);
}


class MyApp extends StatefulWidget {

  var appLanguage;

  MyApp({this.appLanguage});

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  // initialize flutter fire
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

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
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            onGenerateTitle: (BuildContext context) =>
//          "${AppLocalizations.of(context).translate('app_title')}",
            "KABA",
            theme: ThemeData(primarySwatch: KColors.colorCustom,
                fontFamily: 'GoogleSans'),
//      home: RestaurantMenuPage(presenter: MenuPresenter(), restaurant: RestaurantModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
            home: SplashPage(),
//          home: RegisterPage(presenter: RegisterPresenter()),
//          home: EditAddressPage(presenter: EditAddressPresenter()),
//      home: OrderFeedbackPage(presenter: OrderFeedbackPresenter()),
//      home: RestaurantFoodDetailsPage(presenter: FoodPresenter(), foodId: 1999) ,
//      home: TransactionHistoryPage(presenter: TransactionPresenter()),
//      home: TopUpPage(presenter: TopUpPresenter()),
//      home: FeedsPage(presenter: FeedPresenter(),),
//      home: EvenementPage(presenter: EvenementPresenter(),),
//      home: NotificationTestPage(),
//            home: TopUpPage(presenter: TopUpPresenter()),
//      home: WebViewPage(agreement: true),
//      home: WebTestPage(),
//      home: TransferMoneySuccessPage(),
//      home: MyVouchersPage(presenter: VoucherPresenter()),
//      home: AddVouchersPage(presenter: AddVoucherPresenter()),
//      home: VoucherDetailsPage(),
//          home: VoucherSubscribeSuccessPage(voucher: VoucherModel.randomDelivery()),
            routes: generalRoutes,
          );
        }));
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
    navigatorKey.currentState.pushNamed(RestaurantDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToRestaurantMenuPage(int product_id) {
    navigatorKey.currentState.pushNamed(RestaurantMenuPage.routeName, arguments: product_id);
  }

  void _jumpToServiceClient() {
    navigatorKey.currentState.pushNamed(CustomerCareChatPage.routeName);
  }

}


