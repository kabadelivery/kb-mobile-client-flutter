import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:KABA/src/TestPage.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/cinema_contract.dart';
import 'package:KABA/src/contracts/edit_address_contract.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/movie_contract.dart';
import 'package:KABA/src/contracts/register_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/topup_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginOTPConfirmationPage.dart';
import 'package:KABA/src/ui/screens/auth/register/RegisterPage.dart';
import 'package:KABA/src/ui/screens/home/buy/search/SearchProductPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/FlowerCatalogPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/movies/MovieCatalogePage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/movies/MovieDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/EditAddressPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TopUpPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';

// import 'package:KABA/src/ui/screens/home/me/vouchers/KabaScanPage.old';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/PresentationPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/routes.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:overlay_support/overlay_support.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/StateContainer.dart';

Future<void> main() async {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.none;

  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: KColors.primaryColor, // navigation bar color
  ));

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    AppConfig.CHANNEL_ID, // id
    AppConfig.CHANNEL_NAME, // title
    description: AppConfig.CHANNEL_DESCRIPTION, // description
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await Firebase.initializeApp();

  // wanna listen to realtime database and make changes, preparing it for version 3.3.4
  // DatabaseReference alertRef = FirebaseDatabase.instance.ref('mobile_app_alert');
  // alertRef.onValue.listen((DatabaseEvent event) {
  //   final data = event.snapshot.value;
  //   xrint("${data}");
  // });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    // await SentryFlutter.init(
    //       (options) {
    //     options.dsn = 'https://db3d3fa783f643539ad13a7e84437ad6@o1211273.ingest.sentry.io/6351988';
    //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    //     // We recommend adjusting this value in production.
    //     options.tracesSampleRate = 1.0;
    //   },
    //   appRunner: () =>  runApp(StateContainer(child: MyApp(appLanguage: appLanguage))),
    // );

    runApp(StateContainer(child: MyApp(appLanguage: appLanguage)));
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;

  var appLanguage;

  MyApp({this.appLanguage}) {
    analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytics);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // hms.Push.enableLogger();
    // logTextController = new TextEditingController();
    // topicTextController = new TextEditingController();
    // initPlatformState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // logTextController.dispose();
    // topicTextController.dispose();
    super.dispose();
  }

  void clearLog() {
    setState(() {
      // logTextController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // StateContainer.of(context);

    // precache logo of the splashPage
    precacheImage(AssetImage(ImageAssets.kaba_main), context);

    return ChangeNotifierProvider<AppLanguage>(
        create: (_) => widget.appLanguage,
        child: Consumer<AppLanguage>(builder: (context, model, child) {
          return OverlaySupport.global(
            child: MaterialApp(
              supportedLocales: [
                Locale('en', 'US'),
                Locale('fr', 'FR'),
                Locale.fromSubtags(languageCode: 'zh')
                /*      Locale("af"),
                Locale("am"),
                Locale("ar"),
                Locale("az"),
                Locale("be"),
                Locale("bg"),
                Locale("bn"),
                Locale("bs"),
                Locale("ca"),
                Locale("cs"),
                Locale("da"),
                Locale("de"),
                Locale("el"),
                Locale("es"),
                Locale("et"),
                Locale("fa"),
                Locale("fi"),
                Locale("gl"),
                Locale("ha"),
                Locale("he"),
                Locale("hi"),
                Locale("hr"),
                Locale("hu"),
                Locale("hy"),
                Locale("id"),
                Locale("is"),
                Locale("it"),
                Locale("ja"),
                Locale("ka"),
                Locale("kk"),
                Locale("km"),
                Locale("ko"),
                Locale("ku"),
                Locale("ky"),
                Locale("lt"),
                Locale("lv"),
                Locale("mk"),
                Locale("ml"),
                Locale("mn"),
                Locale("ms"),
                Locale("nb"),
                Locale("nl"),
                Locale("nn"),
                Locale("no"),
                Locale("pl"),
                Locale("ps"),
                Locale("pt"),
                Locale("ro"),
                Locale("ru"),
                Locale("sd"),
                Locale("sk"),
                Locale("sl"),
                Locale("so"),
                Locale("sq"),
                Locale("sr"),
                Locale("sv"),
                Locale("ta"),
                Locale("tg"),
                Locale("th"),
                Locale("tk"),
                Locale("tr"),
                Locale("tt"),
                Locale("uk"),
                Locale("ug"),
                Locale("ur"),
                Locale("uz"),
                Locale("vi")*/
              ],
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: widget.analytics),
                // SentryNavigatorObserver(),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                CountryLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              onGenerateTitle: (BuildContext context) =>
//          "${AppLocalizations.of(context).translate('app_title')}",
                  "KABA",
              theme: ThemeData(
                  primarySwatch: KColors.colorCustom, fontFamily: 'Inter'),
//      home: RestaurantMenuPage(presenter: MenuPresenter(), restaurant: ShopModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
             home: SplashPage(analytics: widget.analytics, observer: widget.observer),
//             home: MovieCatalogePage(presenter: CinemaPresenter(), cinema: ShopModel()..name="C. Olympia Godopé"),
//               home: MovieDetailsPage(presenter: MoviePresenter()),
//             home: SearchProductPage(),
//             home: ShopListPage(foodProposalPresenter: RestaurantFoodProposalPresenter(), restaurantListPresenter: RestaurantListPresenter()),
              // home: FlowerCatalogPage(presenter: MenuPresenter(), menuId: 800),
              //   home: ShopFlowerDetailsPage(presenter: FoodPresenter(), foodId: 396,),
              /*home: RestaurantListPage(
                  context: context,
                  foodProposalPresenter: RestaurantFoodProposalPresenter(),
                  restaurantListPresenter: RestaurantListPresenter()),*/
              // home: TransactionHistoryPage(presenter: TransactionPresenter()),
              // home : LoginOTPConfirmationPage(username: "90628725", otp_code: "8833"),
              //   home: TestPage(),
//          home: RegisterPage(presenter: RegisterPresenter()),
//           home: MyAddressesPage(presenter: AddressPresenter()),
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
            ),
          );
        }));
  }

  void _jumpToFoodDetailsWithId(int product_id) {
    navigatorKey.currentState
        .pushNamed(RestaurantMenuPage.routeName, arguments: -1 * product_id);
  }

  void _jumpToOrderDetailsWithId(int product_id) {
    navigatorKey.currentState
        .pushNamed(OrderDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToTransactionHistory() {
    navigatorKey.currentState.pushNamed(TransactionHistoryPage.routeName);
  }

  /* void _jumpToArticleInterface(int product_id) {
    navigatorKey.currentState.pushNamed(WebViewPage.routeName, arguments: product_id);
  }*/

  void _jumpToRestaurantDetailsPage(int product_id) {
    /* send a negative id when we want to show the food inside the menu */
    navigatorKey.currentState
        .pushNamed(RestaurantDetailsPage.routeName, arguments: product_id);
  }

  void _jumpToRestaurantMenuPage(int product_id) {
    navigatorKey.currentState
        .pushNamed(RestaurantMenuPage.routeName, arguments: product_id);
  }

  void _jumpToServiceClient() {
    navigatorKey.currentState.pushNamed(CustomerCareChatPage.routeName);
  }
}

class CustomIntentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text("hard"), color: Colors.white);
  }
}
