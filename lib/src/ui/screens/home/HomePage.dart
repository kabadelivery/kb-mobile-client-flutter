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
import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/remote_data_source.dart';
import 'package:KABA/src/microservices/expedition/domain/expedition/repo.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/homepage.dart';
import 'package:KABA/src/microservices/expedition/usecases/getUserExpedition.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/page_holder.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/models/NotificationItem.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/modals/Modal_2_connect.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/buy/main/ServiceMainPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/MeNewAccountPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/out_of_app.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/out_of_app_pres.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/pharmacy.dart';
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
import 'package:app_links/app_links.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../microservices/expedition/presentation/widget/expedition_widget.dart';
import '../../../microservices/expedition/presentation/widget/tracked_package_widget.dart';
import '../../../resources/app_api_provider.dart';
import '../../../utils/functions/NotLoggedInPopUp.dart';
import '../../../utils/functions/OutOfAppOrder/dialogToFetchDistrict.dart';
import '../../../utils/functions/permissions.dart';
import '../../../utils/functions/subscribe_with_code.dart';
import '../../customwidgets/permission.dart';
import '_home/HomeWelcomeNewPage.dart';
import 'me/abonnement/kaba_abonnements.dart';
import 'me/money/TransactionHistoryPage.dart';
import 'me/vouchers/AddVouchersPage.dart';
import 'me/vouchers/MyVouchersPage.dart';
import 'orders/DailyOrdersPage.dart';


FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class HomePage extends StatefulWidget {
  static var routeName = "/HomePage";
  bool is_out_of_app_order;
  var argument;

  var destination;

  CustomerModel? customer;

  var samePositionCount = 0;

  bool? hasGps = false;

  HomePage(
      {Key? key,
      this.destination,
      this.argument,
      this.is_out_of_app_order = false})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeWelcomeNewPage? homeWelcomePage;

  ServiceMainPage? serviceMainPage;
  DailyOrdersPage? dailyOrdersPage;
  MeNewAccountPage? meAccountPage;
  static String messageId = "";
  List<StatefulWidget>? pages;
  final PageStorageBucket bucket = PageStorageBucket();

  final PageStorageKey homeKey = PageStorageKey("homeKey"),
      serviceMainKey = PageStorageKey("serviceMainKey"),
      orderKey = PageStorageKey("orderKey"),
      meKey = PageStorageKey("meKey");

  late SharedPreferences prefs;

  var subscription;

  StreamSubscription<Position>? positionStream;
  Position? tmpLocation;

  Future<int> checkLogin() async {
    StatefulWidget launchPage =
        LoginPage(presenter: LoginPresenter(LoginView()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String expDate =
        prefs.getString("_login_expiration_date" + CustomerUtils.signature) ??
            "";
    int loginCheckResult = 0; // not logged in

      if (expDate != null && expDate.isNotEmpty) {
        debugPrint("expDate $expDate");
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
        presenter: HomeWelcomePresenter(HomeWelcomeView()),
        destination: widget.destination,
        argument: widget.argument);
    serviceMainPage = ServiceMainPage(
        key: serviceMainKey,
        presenter: ServiceMainPresenter(ServiceMainView()));
    dailyOrdersPage = DailyOrdersPage(
        key: orderKey,
        presenter: DailyOrderPresenter(DailyOrderView()),
        is_out_of_app_order: widget.is_out_of_app_order);
    meAccountPage = MeNewAccountPage(key: meKey);
    pages = [
      serviceMainPage!,
      homeWelcomePage!,
      dailyOrdersPage!,
      meAccountPage!
    ];
    super.initState();
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      /* if you are email... and you've been created in the last 2 minutes... congratulations, you've created e-mail account. */
      /* make sure you show it once on a single device... */

      SharedPreferences.getInstance().then((value) async {
        prefs = value;

        String? _hasSeenEmailAccountNotification =
            prefs.getString("_hasSeenEmailAccountNotification");

        if (_hasSeenEmailAccountNotification != "1" &&
            Utils.isEmailValid(customer.email ?? ""))
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
                    child: Text(
                        "${AppLocalizations.of(context)!.translate('ok')}"),
                    onPressed: () {
                      prefs!.setString("_hasSeenEmailAccountNotification", "1");
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
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        xrint("onDidReceiveNotificationResponse: ${response.payload.toString()}");
        final payload = response.payload;

        if (payload != null && payload.isNotEmpty) {
          final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
          if (!uuidRegex.hasMatch(payload)) {
            _handlePayLoad(payload);
          } else {
            _handleExpeditionPayload(payload);
          }
        } else {
          xrint("⚠️ No payload in notification tap");
        }
      },
    );

    // new try
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      xrint('pnotif Got a message whilst in the foreground!');
      xrint("FirebaseMessaging.onMessage.listen ${message}");
      var notificationPayload ={
        "title": jsonDecode(message.data["notification"])["title"] ?? "",
        "body":  jsonDecode(message.data["notification"])["body"]  ?? "",
        "image":jsonDecode(message.data["notification"])["image"] ?? "",
      };
      RemoteNotification localNotif =RemoteNotification(
        title: notificationPayload["title"],
        body: notificationPayload["body"],
        android: AndroidNotification(
          imageUrl: notificationPayload["image"],
        ),
      );
      xrint('pnotif Message data: ${message.data}');
      xrint('pnotif Message data: ${message.toMap().toString()}');

      if (localNotif != null) {
        xrint(
            'pnotif Message also contained a notification: ${message.data['notification']}');
        final notifString = message.data['notification'];
        Map<String, dynamic>? notif;
        try {
          notif = jsonDecode(notifString);
        } catch (e) {
        }
        if (notif != null && notif['expedition_id'] != null) {
          final expeditionId = notif['expedition_id'] ?? '';
          final title = notif['title'] ?? '';
          final body = notif['body'] ?? '';
          if (message.messageId != messageId) {
             iLaunchExpeditionNotification(
            title: title,
            body: body,
            expeditionId: expeditionId,
            );
            messageId = message.messageId!;
          }
        }else{
          debugPrint('XXX message.data ${message.data}');
          NotificationItem? notificationItem =
          _notificationFromMessage(message.data);
          if (message.messageId != messageId) {
            iLaunchNotifications(notificationItem!);
            messageId = message.messageId!;
          }
        }

      }
    });
    if(kDebugMode){
      _firebaseMessaging
          .subscribeToTopic(ServerConfig.DEV_TOPIC);
      debugPrint("✅Subscribed to ${ServerConfig.DEV_TOPIC} topic");
    }
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
    CustomerUtils.getSavedAddressLocally().then((Position? position) {
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
      {String? svgIcons,
      Icon? icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function? actionIfYes}) {
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
                          svgIcons!,
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
                        actionIfYes!();
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

    final data = message.data;

    if (!data.containsKey('product_id')) {
      try {
        final notif = jsonDecode(data['notification']);
        final expeditionId = notif['expedition_id'];
        if (expeditionId != null && expeditionId.toString().isNotEmpty) {
          _handleExpeditionPayload(expeditionId.toString());
          return;
        }
      } catch (e) {
        xrint('⚠️ Error decoding notification JSON: $e');
      }
    }
    NotificationItem? notificationItem = _notificationFromMessage(data);
    if (notificationItem?.destination != null) {
      _handlePayLoad(notificationItem!.destination!.toSpecialString());
    } else {
      _handlePayLoad('');
    }
  }


  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    xrint("_firebaseMessagingBackgroundHandler: ${message.data}");

    if (message.notification != null) {
      final data = message.data;

      // Check for expedition notification
      if (!data.containsKey('product_id')) {
        try {
          final notif = jsonDecode(data['notification']);
          final expeditionId = notif['expedition_id'];
          if (expeditionId != null && expeditionId.toString().isNotEmpty) {
            _handleExpeditionPayload(expeditionId.toString());
            return;
          }
        } catch (e) {
          xrint('⚠️ Error decoding notification JSON: $e');
        }
      }
   xrint('p_notify Message also contained a notification: $data');
      NotificationItem? notificationItem = _notificationFromMessage(data);

      if (notificationItem?.destination != null) {
        _handlePayLoad(notificationItem!.destination!.toSpecialString());
      } else {
        _handlePayLoad('');
      }
    }
  }

  Future<void> onDidReceiveLocalNotification(
      int? id,
      String? title,
      String? body,
      String? payload,
      ) async {
    xrint("onDidReceiveLocalNotification payload: $payload");
    if (payload != null && payload.isNotEmpty) {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );

      if (payload != null && payload.isNotEmpty) {
        !uuidRegex.hasMatch(payload)
            ? _handlePayLoad(payload)        // generic notification
            : _handleExpeditionPayload(payload); // expedition ID
      }
    } else {
      xrint("⚠️ No payload in local notification");
    }
  }


  Future<void> onSelectNotification(String? payload) async {
    xrint("onSelectedNotification payload: $payload");

    if (payload != null && payload.isNotEmpty) {
      // If payload looks like an expedition ID
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );

      if (payload != null && payload.isNotEmpty) {
        !uuidRegex.hasMatch(payload)
            ? _handlePayLoad(payload)        // generic notification
            : _handleExpeditionPayload(payload); // expedition ID
      }
    } else {
      xrint("⚠️ No payload found in selected notification");
    }
  }


  void _handlePayLoad(String payload) {
    print('payloader $payload');

    Map<String, dynamic>? notificationFDestination;
    String payloadData = '$payload';

    try {
      notificationFDestination = json.decode(payloadData);
      //  print('payloader ${notificationFDestination.type.toString()}');
      xrint(notificationFDestination.toString());
    } catch (e) {
      xrint(e);
    }
    int type = int.parse(notificationFDestination!['type'].toString());
    int is_out_of_app =
        int.parse(notificationFDestination!['is_out_of_app'].toString());
    int productId =
        int.parse(notificationFDestination!['product_id'].toString());
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
      case NotificationFDestination.SUBSCRIPTION_PAGE:
        _jumpToSubscriptionPAge();

    }
  }
  void _handleExpeditionPayload(String payload) async {
   String? expeditionId = payload;
    if (expeditionId != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: KColors.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${AppLocalizations.of(context)!.translate("in_progress")}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      await Future.delayed(Duration(seconds: 2));
      await _redirectUser(expeditionId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucun lien disponible pour cette notification")),
      );
    }
  }
  Future<void> _redirectUser(String id) async {

    CustomerModel customerModel = await CustomerUtils.getCustomer();
    GetUserExpedition getUserExpeditionUseCase = GetUserExpedition(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
    final expeditions = await getUserExpeditionUseCase(
      customerToken: customerModel.token!,
    );
    ExpeditionModel expedition =expeditions.where((element) => element.id == id).first;
    Navigator.pop(context);
    _jumpToPage(context, TrackingPackage(expeditionModel: expedition));

   }
  void _jumpToFoodDetailsWithId(int productId) {
    _jumpToPage(
        context,
        RestaurantMenuPage(
            foodId: productId, presenter: MenuPresenter(MenuView())));
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
        context,
        TransactionHistoryPage(
            presenter: TransactionPresenter(TransactionView())));
  }

  void _jumpToRestaurantDetailsPage(int productId) {
    _jumpToPage(
        context,
        ShopDetailsPage(
            restaurantId: productId,
            presenter: RestaurantDetailsPresenter(RestaurantDetailsView())));
  }

  void _jumpToRestaurantMenuPage(int productId) {
    _jumpToPage(
        context,
        RestaurantMenuPage(
            menuId: productId, presenter: MenuPresenter(MenuView())));
  }
  void _jumpToSubscriptionPAge() {
    _jumpToPage(
        context,Kaba_abonnement(presenter: TransactionPresenter(TransactionView()),));
  }
  void _jumpToServiceClient() {
    _jumpToPage(
        context,
        CustomerCareChatPage(
            presenter: CustomerCareChatPresenter(CustomerCareChatView())));
  }

  int loginStuffChecked = 0;
  //  //get device token
  void get_token() async {
    String? token = await FirebaseMessaging.instance.getToken();
    AppApiProvider apiProvider = AppApiProvider();
    CustomerModel ? customer = await CustomerUtils.getCustomer();
    customer.token = token;
    await apiProvider.updateUserFcmToken(token??"");
    print('Device token $token');
  }

  @override
  Widget build(BuildContext context) {
    if (loginStuffChecked == 0) {
      /* check the login status */
      checkLogin().then((value) {
        StateContainer.of(context).updateLoggingState(state: value);
      });
      // }
      loginStuffChecked = 1;
    }
    return Scaffold(
       
      body: pages![StateContainer.of(context)!.tabPosition!],
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 12.5,
        unselectedFontSize: 12,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset("assets/images/png/grey-service.png",width:20),
            activeIcon: Image.asset("assets/images/png/service.png",width:20),
            label: Utils.capitalize(
                'Services'),
            tooltip: Utils.capitalize(
                'Services'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_outlined), // Icon(Icons.home),
            activeIcon: Icon(Icons.rocket,color: KabaChineColors.primary,),
            label: Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('discover')}"),
            tooltip: Utils.capitalize(
                "${AppLocalizations.of(context)!.translate('discover')}"),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.basketShopping),
            // Icon(Icons.view_list),
            activeIcon: Icon(FontAwesomeIcons.basketShopping, color: KabaChineColors.primary),
            label: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('orders')}'),
            tooltip: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('orders')}'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_4_outlined), //  Icon(Icons.person),
            activeIcon: Icon(Icons.person_4,color: KabaChineColors.primary),
            label: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('account')}'),
            tooltip: Utils.capitalize(
                '${AppLocalizations.of(context)!.translate('account')}'),
          ),
        ],
        currentIndex: StateContainer.of(context).tabPosition!,
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
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [KColors.primaryColor, KColors.primaryColor.withOpacity(.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Titre
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('secure_access'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(" KABA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: KColors.primaryColor,
                            )),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Text(
                      "${AppLocalizations.of(context)!.translate("please_login_before_going_forward_description_account")}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:Color(0xFFD13457),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.person, color: Colors.white),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${AppLocalizations.of(context)!.translate('login')}",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LoginPage(presenter: LoginPresenter(LoginView())),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Bouton secondaire "Pas maintenant"
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "${AppLocalizations.of(context)!.translate('not_now')}",
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
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

  StreamSubscription<Uri>? _sub;
  final AppLinks _appLinks = AppLinks();


  Future<Null> initUniLinksStream() async {
    // Attach a listener to the stream
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      final link = uri.toString();
      xrint("initialLinkStream $link");
      _handleLinksImmediately(link);
    }, onError: (err) {
      xrint("initialLinkStreamError: $err");
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
            StateContainer.of(context)!.lastTimeLinkMatchAction! >
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
                presenter: AddressPresenter(AddressView()),
                gps_location: "${mUri.path}".replaceAll(",", ":")));
      });
    } else {
      // we dont have  a gps location
      xrint("path is not gps location -> ${link}");

      List<String?> pathSegments = mUri.pathSegments.toList();
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
                      presenter: AddVoucherPresenter(AddVoucherView()),
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
            _jumpToPage(context,
                MyVouchersPage(presenter: VoucherPresenter(VoucherView())));
          });
          break;
        case "addresses":
          _checkIfLoggedInAndDoAction(() {
            xrint("addresses page");
            widget.destination = SplashPage.ADDRESSES;
            /* convert from hexadecimal to decimal */
            _jumpToPage(context,
                MyAddressesPage(presenter: AddressPresenter(AddressView())));
          });
          break;
        case "transactions":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(
                context,
                TransactionHistoryPage(
                    presenter: TransactionPresenter(TransactionView())));
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

              _jumpToPage(
                  context,
                  ShopDetailsPage(
                      restaurant: ShopModel(id: widget.argument),
                      presenter:
                          RestaurantDetailsPresenter(RestaurantDetailsView())));
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
                    foodId: widget.argument,
                    presenter: MenuPresenter(MenuView())));
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
                    menuId: widget.argument,
                    presenter: MenuPresenter(MenuView())));
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
            _jumpToPage(
                context,
                CustomerCareChatPage(
                    presenter:
                        CustomerCareChatPresenter(CustomerCareChatView())));
          });
          break;
        case "hors_appli":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context, OutOfAppPres());
          });
          break;

        case "colis":
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
              print("error $e");
            }
          }

          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(
                context,
                ShippingPackageOrderPage(
                  districts: districts,
                ));
          });
          break;

        case "chine":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context, WelcomeToKabaChine());
          });
          break;

        case "expedition":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context, KabaExpeditionHomePage());
          });
          break;

        case "pharmacy":
          _checkIfLoggedInAndDoAction(() {
            _jumpToPage(context, PharmacyPage());
          });
          break;
        case "code_abonnement":
          if (pathSegments.length > 1) {
            showLoadingDialog(context);
           String? code = pathSegments[1];
           await subscribeByCode(code:code!).then((value){
             Map<String,dynamic> data = value;
             if(data['success']==true){
               Navigator.pop(context);
               _jumpToPage(context, Kaba_abonnement(presenter: TransactionPresenter(TransactionView())));
             }else{
               CherryToast.error(
                 title: Text("${AppLocalizations.of(context)!.translate("subscription_failed")}"),
               ).show(context);
             }
           });
          }
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
                          LoginPage(presenter: LoginPresenter(LoginView()))));
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

      String? _has_accepted_gps = await prefs.getString("_has_accepted_gps");
      var status = await Permission.location.status;
      var notif_status=await Permission.notification.status;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        /*  ---- */
        // await Geolocator.openAppSettings();
        /* ---- */
        if(status.isDenied &&!notif_status.isDenied){
          openLocationModal(context);
        }else{
          return  showDialog(
            context: context,
            builder: (_) => const PermissionsModal(),
          );
        }
        /* ---- */
      } else if (permission == LocationPermission.denied) {
        /* ---- */
        // Geolocator.requestPermission();
        /* ---- */
        if(status.isDenied &&!notif_status.isDenied){
          openLocationModal(context);
        }else{
          return  showDialog(
            context: context,
            builder: (_) => const PermissionsModal(),
          );
        }
      } else {
        bool isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
        var status  = await Permission.notification.status;
        if (!isLocationServiceEnabled ) {
          if(status.isDenied && !notif_status.isDenied){
            openLocationModal(context);
          }else{
            return  showDialog(
              context: context,
              builder: (_) => const PermissionsModal(),
            );
          }

          /* ---- */
        } else {
          /* show loading dialog until this finishes then close */

          // switch to page two
          if (jumpToBuyPageDetails) {
            setState(() {
              StateContainer.of(context).updateTabPosition(tabPosition: 1);
            });
          }

          positionStream =Geolocator.getPositionStream().listen((Position position) {
            /* compare current and old position */
            if (position?.latitude != null &&
                tmpLocation?.latitude != null &&
                (position.latitude * 100).round() ==
                    (tmpLocation!.latitude! * 100).round() &&
                (position.longitude * 100).round() ==
                    (tmpLocation!.longitude * 100).round()) {
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
            if (widget.samePositionCount >= 3 || widget.hasGps!)
              positionStream?.cancel();
          });
        }
      }
    });

    var loc_status =await Permission.location.status ;
    var notif_status=await Permission.notification.status;
    var storage_status = await Permission.storage.status;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      int sdkVersion = androidInfo.version.sdkInt;
      if (sdkVersion <= 32) {
        storage_status = await Permission.storage.status;
      }
    }
    if(loc_status.isGranted&&notif_status.isGranted){
      if(storage_status.isDenied){
        //  openPhotosModal(context);
        //   openLocationModal(context);
        // openNotificationModal(context);
      }
    }
  }

  void _requestGpsPermissionAndLocation() {
    /* has been requested already, we shouldnt request a second time during this time */
    //  explain to the user why we need it, and then pick it
    if (!StateContainer.of(context).location_asked)
      StateContainer.of(context).location_asked = true;
    else
      return;

  }
}

NotificationItem? _notificationFromMessage(Map<String, dynamic> messageEntry) {
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
            product_id:  destinationData["product_id"] != null
                ? int.parse(destinationData["product_id"].toString())
                : 0,
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
  final String? bigPictureUrl = notificationItem.image_link?.toString();

  String? filePath;
  if (bigPictureUrl != null && bigPictureUrl.isNotEmpty) {
    try {
      final directory = await getApplicationDocumentsDirectory();
      filePath = '${directory.path}/bigImage.jpg';
      final response = await http.get(Uri.parse(bigPictureUrl));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } catch (e) {
      debugPrint("Failed to download notification image: $e");
      filePath = null;
    }
  }

  // Android style information
  final BigPictureStyleInformation? bigPictureStyleInformation =
  (filePath != null)
      ? BigPictureStyleInformation(
    FilePathAndroidBitmap(filePath),
    contentTitle: notificationItem.title,
    summaryText: notificationItem.body,
    htmlFormatContentTitle: true,
    htmlFormatSummaryText: true,
  )
      : null;

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    AppConfig.CHANNEL_ID,
    AppConfig.CHANNEL_NAME,
    channelDescription: AppConfig.CHANNEL_DESCRIPTION,
    importance: Importance.max,
    priority: Priority.max,
    ticker: notificationItem.title,
    styleInformation: bigPictureStyleInformation,
    largeIcon: (filePath != null) ? FilePathAndroidBitmap(filePath) : null,
  );

  // iOS style information
  final List<DarwinNotificationAttachment> iOSAttachments = [];
  if (filePath != null) {
    iOSAttachments.add(DarwinNotificationAttachment(filePath));
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

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  return flutterLocalNotificationsPlugin!.show(
    notificationItem.hashCode,
    notificationItem.title,
    notificationItem.body,
    platformChannelSpecifics,
    payload: notificationItem.destination?.toSpecialString(),
  );
}


Future<void> iLaunchExpeditionNotification({
  required String title,
  required String body,
  required String expeditionId,
}) async {
  try {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'expedition_channel', // ID unique du canal
      'Expéditions',        // Nom affiché
      channelDescription: 'Notifications liées aux expéditions',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Expédition',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin!.show(
      expeditionId.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: expeditionId,
    );
    debugPrint("✅ Notification d’expédition affichée : $expeditionId");
  } catch (e) {
    debugPrint("❌ Erreur lors de l’affichage de la notification : $e");
  }
}