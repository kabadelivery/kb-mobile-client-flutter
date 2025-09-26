import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:KABA/src/blocs/rating/rating_bloc.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/estimation/estimation_bloc.dart';
import 'package:KABA/src/microservices/expedition/presentation/bloc/expedition/expedition_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/history/history_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/information/information_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/menu/menu_bloc.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/order/order_bloc.dart';
import 'package:KABA/src/models/DeliveryRatingPending.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/ui/screens/rating/rating_article.dart';
import 'package:KABA/src/ui/screens/rating/rating_delivery.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/routes.dart';
import 'package:KABA/src/xrint.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeLocalNotifications();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(StateContainer(child:
    riverpod.ProviderScope(
        child:MultiBlocProvider(
            providers: [
              BlocProvider<InformationBloc>(
                create: (context) => InformationBloc(),
              ),
              BlocProvider<MenuBloc>(
                create: (context) => MenuBloc(),
              ),
              BlocProvider<OrderBloc>(
                create: (context) => OrderBloc(),
              ),
              BlocProvider<HistoryBloc>(
                create: (context) => HistoryBloc(),
              ),
              BlocProvider<ChatBloc>(
                create: (context) => ChatBloc(),
              ),
              BlocProvider<RatingBloc>(
                create: (context) => RatingBloc(),
              ),
              BlocProvider<ExpeditionBloc>(
                create: (context) => ExpeditionBloc(),
              ),
              BlocProvider<EstimationBloc>(
                create: (context) => EstimationBloc(),
              ),
        ], child: MyApp(appLanguage: appLanguage))))
    );
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

  final InitializationSettings settings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
}
class NotificationHandler {
  static String? lastMessageId;
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.messageId != null &&
      message.messageId == NotificationHandler.lastMessageId) {
    print("Skipping duplicate background message: ${message.messageId}");
    return;
  }
  NotificationHandler.lastMessageId = message.messageId;
  // Parse safely your payload
  try {
    final Map<String, dynamic> data = message.data;
    final notificationRaw = data["notification"];
    final decodedNotification = jsonDecode(notificationRaw);

    final title = decodedNotification["title"];
    final body = decodedNotification["body"];
    final imageUrl = decodedNotification["image_link"];
    final destination = jsonDecode(decodedNotification["destination"]);

    final destinationString = jsonEncode(destination); // For payload
    String? imagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/notif_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        imagePath = filePath;
      } catch (e) {
        print("❌ Erreur lors du téléchargement de l'image : $e");
      }
    }
  }

  if (kDebugMode) {
    FirebaseMessaging.instance.subscribeToTopic('kaba_testeurs');
    xrint('Subscribed to kaba_testeurs (debug only)');
  } else {
    xrint('Not in debug mode — skipping topic subscription');
  }

  // Init plugin (important in background)
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit, iOS: iosInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Notification style for Android
  final BigPictureStyleInformation? bigPictureStyle = (imagePath != null)
      ? BigPictureStyleInformation(
    FilePathAndroidBitmap(imagePath),
    contentTitle: title,
    summaryText: body,
    htmlFormatContentTitle: true,
    htmlFormatSummaryText: true,
  )
      : null;

  final AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    AppConfig.CHANNEL_ID,
    AppConfig.CHANNEL_NAME,
    channelDescription: AppConfig.CHANNEL_DESCRIPTION,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: bigPictureStyle,
    enableLights: true,
    showWhen: true,
    largeIcon:
    (imagePath != null) ? FilePathAndroidBitmap(imagePath) : null,
  );

  // Notification style for iOS
  final List<DarwinNotificationAttachment> iOSAttachments = [];
  if (imagePath != null) {
    iOSAttachments.add(DarwinNotificationAttachment(imagePath));
  }

  final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    attachments: iOSAttachments,
    categoryIdentifier: "plainCategory",
    threadIdentifier: "thread1",
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: "default",
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    notificationDetails,
    payload: destinationString,
  );
}

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
    DeliveryRatingPending deliveryRatingPending =DeliveryRatingPending().fake();
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
                appBarTheme: AppBarTheme(
                  iconTheme: IconThemeData(color: Colors.white),
                ),
          dialogTheme: DialogTheme(
          backgroundColor: Colors.white),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KColors.colorCustom, // couleur de fond
                      foregroundColor: Colors.white,        // texte / icône
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.white,
                    primary: KColors.colorCustom,
                    brightness: Brightness.light,
                    onPrimary: Colors.white,
                      secondary: KColors.colorCustom,
                      onSecondary: Colors.white,
                      surface: Colors.white,

                    
                  ),
                  scaffoldBackgroundColor: Colors.white,
                  primarySwatch: KColors.colorCustom, fontFamily: 'Inter'),
              // home: RestaurantMenuPage(presenter: MenuPresenter(MenuView()), restaurant: ShopModel(id:31, name:"FESTIVAL DES GLACES")),
//      home: OrderConfirmationPage2 (presenter: OrderConfirmationPresenter()),
              /*  home: ShopSimpleList(

            //  coque de noix de coco...

            //  desxintox, buvable, infections, probleme de trompes, dents, empoisonement,
            //  morsures danniamales, constipation, maux de foi, rein

                  type: "shop",
                  restaurantListPresenter: RestaurantListPresenter()),*/
              // home: TestPage(),

              home:  //RatingArticle(deliveryRatingPending:deliveryRatingPending ,),
               SplashPage(   analytics: widget.analytics, observer: widget.observer),
              // home: DeleteAccountSuccessfulPage(),
              // home: DeleteAccountFixPropositionPage(),
              /*  home: ShopListPageRefined(foodProposalPresenter: RestaurantFoodProposalPresenter(),
                restaurantListPresenter: RestaurantListPresenter(), type: "food"), */
              // home: ShopScheduleMiniPage(restaurant_id: 3, presenter: new ShopSchedulePresenter()),
//             home: MovieCataloguePage(presenter: CinemaPresenter(), cinema: ShopModel()..name="C. Olympia Godopé"),
//               home: MovieDetailsPage(presenter: MoviePresenter()),
//             home: SearchProductPage(),
//             home: ShopListPage(foodProposalPresenter: RestaurantFoodProposalPresenter(), restaurantListPresenter: RestaurantListPresenter()),
              // home: FlowerCatalogPage(presenter: MenuPresenter(MenuView()), menuId: 800),
              //   home: ShopFlowerDetailsPage(presenter: FoodPresenter(), foodId: 396,),
              /*home: RestaurantListPage (
                  context: context,
                  foodProposalPresenter: RestaurantFoodProposalPresenter(),
                  restaurantListPresenter: RestaurantListPresenter()),*/
              // home: TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())),
              // home : LoginOTPConfirmationPage(username: "90628725", otp_code: "8833"),
              //   home: TestPage(),
//          home: RegisterPage(presenter: RegisterPresenter()),
//           home: MyAddressesPage(presenter: AddressPresenter(AddressView())),
//          home: EditAddressPage(presenter: EditAddressPresenter(AddressView())),
//      home: OrderFeedbackPage(presenter: OrderFeedbackPresenter()),
//      home: RestaurantFoodDetailsPage(presenter: FoodPresenter(), foodId: 1999) ,
//      home: TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())),
//      home: TopUpPage(presenter: TopUpPresenter(TopUpView())),
//      home: FeedsPage(presenter: FeedPresenter(FeedView()),),
//      home: EvenementPage(presenter: EvenementPresenter(),),
//      home: NotificationTestPage(),
//            home: TopUpPage(presenter: TopUpPresenter(TopUpView())),
//      home: WebViewPage(agreement: true),
//      home: WebTestPage(),
//      home: TransferMoneySuccessPage(),
//      home: MyVouchersPage(presenter: VoucherPresenter(VoucherView())),
//      home: AddVouchersPage(presenter: AddVoucherPresenter(AddVoucherView())),
//      home: VoucherDetailsPage(),
//          home: VoucherSubscribeSuccessPage(voucher: VoucherModel.randomDelivery()),
              routes: generalRoutes,
            ),
          );
        }));
  }
}
