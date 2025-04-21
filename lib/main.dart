import 'dart:core';

import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/routes.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'src/StateContainer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: KColors.primaryColor,
  ));

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    AppConfig.CHANNEL_ID,
    AppConfig.CHANNEL_NAME,
    description: AppConfig.CHANNEL_DESCRIPTION,
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(StateContainer(child:
    riverpod.ProviderScope(child:
    MyApp(appLanguage: appLanguage)))
    );
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  FirebaseAnalytics? analytics;
  FirebaseAnalyticsObserver? observer;

  var appLanguage;

  MyApp({this.appLanguage}) {
    analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytics!);
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* precache logo of the splashPage */
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
              ],
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: widget.analytics!),
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
              onGenerateTitle: (BuildContext context) => "KABA",
              theme: ThemeData(
                  primarySwatch: KColors.colorCustom, fontFamily: 'Inter'),
              // home: RestaurantMenuPage(presenter: MenuPresenter(), restaurant: ShopModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
              /*  home: ShopSimpleList(

            //  coque de noix de coco...

            //  desxintox, buvable, infections, probleme de trompes, dents, empoisonement,
            //  morsures danniamales, constipation, maux de foi, rein

                  type: "shop",
                  restaurantListPresenter: RestaurantListPresenter()),*/
              // home: TestPage(),
              home: SplashPage(
                  analytics: widget.analytics, observer: widget.observer),
              // home: DeleteAccountSuccessfulPage(),
              // home: DeleteAccountFixPropositionPage(),
              /*  home: ShopListPageRefined(foodProposalPresenter: RestaurantFoodProposalPresenter(),
                restaurantListPresenter: RestaurantListPresenter(), type: "food"), */
              // home: ShopScheduleMiniPage(restaurant_id: 3, presenter: new ShopSchedulePresenter()),
//             home: MovieCataloguePage(presenter: CinemaPresenter(), cinema: ShopModel()..name="C. Olympia Godopé"),
//               home: MovieDetailsPage(presenter: MoviePresenter()),
//             home: SearchProductPage(),
//             home: ShopListPage(foodProposalPresenter: RestaurantFoodProposalPresenter(), restaurantListPresenter: RestaurantListPresenter()),
              // home: FlowerCatalogPage(presenter: MenuPresenter(), menuId: 800),
              //   home: ShopFlowerDetailsPage(presenter: FoodPresenter(), foodId: 396,),
              /*home: RestaurantListPage (
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
}
