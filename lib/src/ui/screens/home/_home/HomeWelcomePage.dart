import 'dart:async';
import 'dart:io';

import 'package:KABA/src/contracts/add_vouchers_contract.dart';
import 'package:KABA/src/contracts/address_contract.dart';
import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/contracts/evenement_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/contracts/vouchers_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/AlertMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/GroupAdsWidget.dart';
import 'package:KABA/src/ui/customwidgets/MRaisedButton.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShinningTextWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/address/MyAddressesPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/me/settings/SettingsPage.dart';
import 'package:KABA/src/ui/screens/home/me/vouchers/AddVouchersPage.dart';
//import 'package:KABA/src/ui/screens/home/me/vouchers/KabaScanPage.old';
import 'package:KABA/src/ui/screens/home/me/vouchers/MyVouchersPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart' as to;
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

// For Flutter applications, you'll most likely want to use
// the url_launcher package.

import '../../../../StateContainer.dart';
import 'events/EventsPage.dart';

class HomeWelcomePage extends StatefulWidget {
  HomeScreenModel? data;

  var argument;

  var destination;

  static HomeScreenModel? standardData;

  HomeWelcomePresenter? presenter;

  CustomerModel? customer;

  HomeWelcomePage(
      {Key? key, this.title, this.presenter, this.destination, this.argument})
      : super(key: key);

  final String? title;

  @override
  _HomeWelcomePageState createState() => _HomeWelcomePageState();
}

class _HomeWelcomePageState extends State<HomeWelcomePage>
    implements HomeWelcomeView {
  List<String>? popupMenus;

  List<String>? _popupMenus() {
    if (StateContainer.of(context).loggingState == 0) {
      return null;
    } else {
      return popupMenus;
    }
  }

  int _carousselPageIndex = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  void initState() {
    super.initState();

    /* if logged in .. we have settings and loggout */

    popupMenus = [
      "Add Voucher",
      /*"Scan QR",*/ "Settings",
      "Logout"
    ]; // standard

    this.widget.presenter!.homeWelcomeView = this;
    showLoading(true);

    CustomerUtils.getCustomer().then((customer) async {
      if (!(await CustomerUtils.isPusTokenUploaded())) {
        this.widget.presenter!.updateToken(customer!);
      }
      widget.customer = customer;
      /* check kaba points */
      Future.delayed(Duration(seconds: 1)).then((value) {
        this.widget.presenter!.checkBalance(customer!);
      });
    });

    this.widget.presenter!.fetchHomePage();
    this.widget.presenter!.checkVersion();
    this.widget.presenter!.checkServiceMessage();
    // check what type of account are you... if email...
    // we going to tell you only if you are just from creating
    // your account

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      this.widget.presenter!.checkUnreadMessages(customer!);
      popupMenus = [
        "${AppLocalizations.of(context)!.translate('add_voucher')}" /*,"${AppLocalizations.of(context)!.translate('scan')}"*/,
        "${AppLocalizations.of(context)!.translate('settings')}",
        "${AppLocalizations.of(context)!.translate('logout')}",
      ];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool has_subscribed = false;
      try {
        prefs.getBool('has_subscribed');
      } catch (_) {
        has_subscribed = false;
      }
      if (has_subscribed != true) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        _firebaseMessaging
            .subscribeToTopic(ServerConfig.TOPIC)
            .whenComplete(() => {prefs.setBool('has_subscribed', true)});
      }
    });

    Timer.run(() {
      if (!(DateTime.now().millisecondsSinceEpoch -
              StateContainer.of(context).lastTimeLinkMatchAction! >
          2000)) {
        return;
      }

      StateContainer.of(context).lastTimeLinkMatchAction =
          DateTime.now().millisecondsSinceEpoch;

      if (widget?.destination != null) {
        switch (widget.destination) {
          case SplashPage.TRANSACTIONS:
            _checkIfLoggedInAndDoAction(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: RouteSettings(
                      name: TransactionHistoryPage.routeName), // <----------
                  builder: (context) => TransactionHistoryPage(
                      presenter: TransactionPresenter(TransactionView())),
                ),
              );
            });
            break;
          case SplashPage.RESTAURANT_LIST:
            StateContainer.of(context).tabPosition = 1;
            break;
          case SplashPage.RESTAURANT:
            _jumpToPage(
                context,
                ShopDetailsPage(
                    restaurant: ShopModel(id: widget.argument),
                    presenter:
                        RestaurantDetailsPresenter(RestaurantDetailsView())));
            break;
          case SplashPage.VOUCHER:
            _checkIfLoggedInAndDoAction(() {
              _jumpToPage(
                  context,
                  AddVouchersPage(
                      presenter: AddVoucherPresenter(AddVoucherView()),
                      qrCode: "${widget.argument}".toUpperCase(),
                      autoSubscribe: true,
                      customer: widget.customer!));
            });
            break;
          case SplashPage.VOUCHERS:
            _checkIfLoggedInAndDoAction(() {
              _jumpToPage(context,
                  MyVouchersPage(presenter: VoucherPresenter(VoucherView())));
            });
            break;
          case SplashPage.ADDRESSES:
//           xrint("voucher homewelcome -> ${widget.argument}");
            _checkIfLoggedInAndDoAction(() {
              _jumpToPage(context,
                  MyAddressesPage(presenter: AddressPresenter(AddressView())));
            });
            break;
          case SplashPage.ORDER:
            _checkIfLoggedInAndDoAction(() {
              _jumpToPage(
                  context,
                  OrderNewDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter(OrderDetailsView())));
            });
            break;
          case SplashPage.FOOD:
            if (widget?.argument != null)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantMenuPage(
                      presenter: MenuPresenter(MenuView()),
                      foodId: widget.argument,
                      highlightedFoodId: widget.argument),
                ),
              );
            break;
          case SplashPage.MENU:
            _jumpToPage(
                context,
                RestaurantMenuPage(
                    menuId: widget.argument,
                    presenter: MenuPresenter(MenuView())));
            break;
          case SplashPage.REVIEW_ORDER:
            _checkIfLoggedInAndDoAction(() {
              _jumpToPage(
                  context,
                  OrderNewDetailsPage(
                      orderId: widget.argument,
                      presenter: OrderDetailsPresenter(OrderDetailsView())));
            });
            break;
          case SplashPage.LOCATION_PICKED:
            _checkIfLoggedInAndDoAction(() {
              // mToast("hwp current route is ${ModalRoute.of(context).settings.name}");
              _jumpToPage(
                  context,
                  MyAddressesPage(
                      presenter: AddressPresenter(AddressView()),
                      gps_location:
                          widget.argument.toString().replaceAll(",", ":")));
            });
            break;
        }
        widget.destination = null;
      }
    });
  }

  @override
  void didChangeDependencies() {
    xrint(
        "dig change dependencies hwelcomepage -> ${widget.destination} -- ${widget.argument}");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /* init fetch data bloc */
    return Scaffold(
        appBar: AppBar(
          title: SizedBox(
              height: 70,
//            margin: EdgeInsets.only(bottom: 30, top: 30),
//            decoration: BoxDecoration(
//                border: new Border(bottom: BorderSide(color: Colors.white, width: 2)),
//                color: Colors.yellow
//            ),
//            padding: EdgeInsets.only(left:8, right: 8, top:8, bottom:8),

              child: GestureDetector(
                onTap: () {
                  setState(() {
                    StateContainer.of(context)
                        .updateTabPosition(tabPosition: 1);
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15, top: 20),
                  decoration: BoxDecoration(
                    border: new Border(
                        bottom: BorderSide(color: Colors.white, width: 1)),
//                color: Colors.white.withAlpha(30)
                  ),
                  child: Container(
                      child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              hintText: widget.data?.feed == null
                                  ? "KABA DELIVERY"
                                  : widget.data?.feed,
                              hintStyle: TextStyle(color: Colors.white)),
                          style: TextStyle(
                              fontSize: _textSizeWithText(widget.data!.feed!)),
                          enabled: false)),
//                child: TextField(decoration:InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, )),hintText: widget.data?.feed, hintStyle: TextStyle(color:Colors.white.withAlpha(200))), style: TextStyle(fontSize: 12), enabled: false,)),
                ),
              )),
          leading: IconButton(
              icon: SizedBox(
                  height: 25,
                  width: 25,
                  child: SvgPicture.asset(
                    VectorsData.kaba_icon_svg,
                    color: Colors.white,
                  )),
              onPressed: () {
                _jumpToInfoPage();
              }),
          backgroundColor: KColors.primaryColor,
          actions: <Widget>[
            InkWell(
              onTap: () => _jumpToWhatsapp(),
              child: Container(
                width: 42,
                height: 42,
                child: IconButton(
                  icon: Image.asset(ImageAssets.whatsapp),
                  onPressed: () => _jumpToWhatsapp(),
                  // setup whatsapp button
                  /*child: FlareActor(
                    FlareData.new_message,
                    alignment: Alignment.center,
                    animation: "normal",
                    fit: BoxFit.contain,
                    isPaused : StateContainer.of(context).hasUnreadMessage != true*/
                ),
              ),
            ),
            StateContainer.of(context).loggingState == 0
                ? SizedBox(width: 15)
                : PopupMenuButton<String>(
                    onSelected: menuChoiceAction,
                    itemBuilder: (BuildContext context) {
                      return _popupMenus()!.map((String menuName) {
                        return PopupMenuItem<String>(
                            value: menuName, child: Text(menuName));
                      }).toList();
                    },
                  )
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: _buildHomeScreen(widget.data!),
        ));
  }

  void menuChoiceAction(String value) {
    /* jump to the other activity */
    switch (_popupMenus()!.indexOf(value)) {
      case 0:
        // scan
        _jumpToAddVoucherPage();
        break;
        /* case 1:
      // scan
        _jumpToScanPage();*/
        break;
      case 1:
        _jumpToPage(context, SettingsPage());
        break;
      case 2:
        /* logout */
        CustomerUtils.clearCustomerInformations().whenComplete(() {
          StateContainer.of(context).updateLoggingState(state: 0);
          StateContainer.of(context).updateBalance(balance: 0);
          // StateContainer.of(context).updateKabaPoints(kabaPoints: "");
          /*  StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);*/
          StateContainer.of(context).hasUnreadMessage = false;
          StateContainer.of(context).updateTabPosition(tabPosition: 0);

          Navigator.pushNamedAndRemoveUntil(
              context, SplashPage.routeName, (r) => false);
        });
        break;
    }
  }

  _carousselPageChanged(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  _mainRestaurantWidget({ShopModel? restaurant}) {
    return GestureDetector(
      onTap: () => {_jumpToRestaurantDetails(context, restaurant!)},
      child: Container(
        padding: EdgeInsets.only(top: 20, right: 15, left: 15),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Utils.inflateLink(restaurant!.pic!))))),
              SizedBox(height: 10),
              Text(restaurant.name!,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),
              _getShinningImage(restaurant)
            ]),
      ),
    );
  }

  void _jumpToBestSeller() {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BestSellersPage (presenter: BestSellerPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BestSellersPage(presenter: BestSellerPresenter(BestSellerView())),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }

  void _jumpToEvents() {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvenementPage (presenter: EvenementPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EvenementPage(presenter: EvenementPresenter(EvenementView())),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }

  Future<void> _refresh() async {
    widget.presenter!.fetchHomePage();
//    homeScreenBloc.fetchHomeScreenModel();
//    await Future.delayed(const Duration(seconds:1));
//    return;
  }

  void _jumpToInfoPage() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => InfoPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));

    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(), // ramener infos
      ),
    );*/
  }

  Widget _buildHomeScreen(HomeScreenModel data) {
    if (data != null) widget.data = data;
    if (widget.data != null)
      return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: ListView(
              children: <Widget>[
            /*top slide*/
            Stack(
              children: <Widget>[
                ClipPath(
                    clipper: KabaRoundTopClipper(),
                    child: data.slider!.length > 1
                        ? CarouselSlider(
                            options: CarouselOptions(
                              onPageChanged: _carousselPageChanged,
                              viewportFraction: 1.0,
                              autoPlay: data.slider!.length > 1 ? true : false,
                              reverse: data.slider!.length > 1 ? true : false,
                              enableInfiniteScroll:
                                  data.slider!.length > 1 ? true : false,
                              autoPlayInterval: Duration(seconds: 5),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 150),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              height:
                                  9 * MediaQuery.of(context).size.width / 16,
                            ),
                            items: data.slider!.map((admodel) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () => _jumpToAdsList(data.slider!,
                                        data.slider!.indexOf(admodel)),
                                    child: Container(
                                        height: 9 *
                                            MediaQuery.of(context).size.width /
                                            16,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                Utils.inflateLink(admodel.pic!),
                                            fit: BoxFit.cover)),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        : GestureDetector(
                            onTap: () => _jumpToAdsList(data.slider!, 0),
                            child: Container(
                                height:
                                    9 * MediaQuery.of(context).size.width / 16,
                                width: MediaQuery.of(context).size.width,
                                child: CachedNetworkImage(
                                    imageUrl:
                                        Utils.inflateLink(data.slider![0].pic!),
                                    fit: BoxFit.cover)),
                          )),
                Positioned(
                    bottom: 10,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 9.0),
                      child: Row(
                        children: <Widget>[]..addAll(List<Widget>.generate(
                                  data.slider!.length, (int index) {
                            return Container(
                                margin: EdgeInsets.only(right: 2.5, top: 2.5),
                                height: 9,
                                width: 9,
                                decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: new Border.all(color: Colors.white),
                                    color: (index == _carousselPageIndex ||
                                            index == data.slider!.length)
                                        ? Colors.white
                                        : Colors.transparent));
                          })
                              /* add a list of rounded views */
                              ),
                      ),
                    )),
              ],
            ),
            /* top restaurants */
            SizedBox(
                child: Table(
              children: <TableRow>[]..addAll(
                    // ignore: null_aware_before_operator
                    List<TableRow>.generate(
                        _getRestaurantRowCount(data.resto!.length),
                        (int rowIndex) {
                  return TableRow(
                      children: <TableCell>[]..addAll(
                            /*   List<TableCell>.generate ((data.resto.length-rowIndex*3)%4, (int cell_index) {
                                    return
                                      TableCell(child:_mainRestaurantWidget(restaurant:data.resto[cell_index]));
                                  })*/
                            List<TableCell>.generate(3, (int cell_index) {
                          if (data.resto!.length > rowIndex * 3 + cell_index) {
                            return TableCell(
                                child: _mainRestaurantWidget(
                                    restaurant: data
                                        .resto![rowIndex * 3 + cell_index]));
                          } else {
                            return TableCell(child: Container());
                          }
                        })));
                })
                    /* add a list of rounded views */
                    ),
            )),
            /* all the restaurants button*/
            SizedBox(height: 10),
            SizedBox(height: 10),
            Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          _switchAllRestaurant();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(20.0),
                                    bottomLeft: const Radius.circular(20.0))),
                            padding: EdgeInsets.only(left: 10),
                            child: Row(children: <Widget>[
                              Text(
                                  "${AppLocalizations.of(context)!.translate('all_restaurants')}",
                                  style: TextStyle(
                                      color: KColors.primaryColor,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color: KColors.primaryColor,
                                  ))
                            ])))
                  ],
                )),
            Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          _callCustomerCare();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.only(
                                    topRight: const Radius.circular(20.0),
                                    bottomRight: const Radius.circular(20.0))),
                            padding: EdgeInsets.only(right: 10),
                            child: Row(children: <Widget>[
                              SizedBox(width: 5),
                              Container(
                                height: 50,
                                width: 40,
                                decoration: BoxDecoration(
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            Utils.inflateLink(
                                                "/web/assets/app_icons/call.gif")))),
                              ),
                              SizedBox(width: 5),
                              Text(
                                  "${AppLocalizations.of(context)!.translate('call_us')}",
                                  style: TextStyle(
                                      color: KColors.mGreen,
                                      fontWeight: FontWeight.bold)),
                            ])))
                  ],
                )),
            /* meilleures ventes, cinema, evenemnts, etc... */
            Container(
                color: Colors.grey.shade100,
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(10),
                  child: Table(
                    /* table */
                    children: <TableRow>[
                      TableRow(children: <TableCell>[
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                InkWell(
                                    child: Container(
                                        child: Column(
                                      children: <Widget>[
                                        Text(
                                            "${AppLocalizations.of(context)!.translate('best_seller')}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: KColors.primaryColor)),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          height: 90,
                                          width: 120,
                                          child: CachedNetworkImage(
                                              fit: BoxFit.fitHeight,
                                              imageUrl: Utils.inflateLink(widget
                                                  .data!.promotion!.pic!)),
                                        ),
                                      ],
                                    )),
                                    onTap: _jumpToBestSeller),
                                InkWell(
                                  onTap: _jumpToEvents,
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                            "${AppLocalizations.of(context)!.translate('events')}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: KColors
                                                    .primaryYellowColor)),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          height: 90,
                                          width: 120,
                                          child: CachedNetworkImage(
                                              fit: BoxFit.fitHeight,
                                              imageUrl: Utils.inflateLink(
                                                  widget.data!.event!.pic!)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]),
                      // BON PLANS ET CINEMA
                      /* TableRow(
                              children: <TableCell>[
                                TableCell(
                                  child: Container(
                                    padding:EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text("CINEMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.mGreen)),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              height:90, width: 120,
                                              child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://freepngimg.com/thumb/roar/35300-2-lioness-roar-transparent-background.png"),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Text("BON PLANS", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.new_black)),
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              height:90, width: 120,
                                              child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://clipart.info/images/ccovers/1495725897Free-spiderman-png-transparent-background.png"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]
                          ) */
                    ],
                  ),
                )),
            /* groups ads */
            Column(
                children: <Widget>[]..addAll(
                      List<Widget>.generate(data.groupad!.length, (int index) {
                    return GroupAdsWidget(groupAd: data.groupad![index]);
                  })))
          ]..add(InkWell(
                  onTap: () {
                    _jumpToInfoPage();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.whatshot,
                            size: 20, color: KColors.primaryColor),
                        SizedBox(height: 5),
                        Text(
                          "${AppLocalizations.of(context)!.translate('powered_by_kaba_tech')}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ))));
    else {
      data = HomeWelcomePage.standardData!;
      return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Center(
              child: isLoading
                  ? MyLoadingProgressWidget()
                  : Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon:
                                Icon(Icons.flight_takeoff, color: Colors.grey),
                            onPressed: () {},
                          ),
                          SizedBox(height: 5),
                          Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('home_page_loading_error')}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey))),
                          SizedBox(height: 5),
                          MRaisedButton(
                              /* shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),*/
                              color: Colors.yellow,
                              child: Text(
                                  "${AppLocalizations.of(context)!.translate('try_again')}"),
                              onPressed: () {
                                widget.presenter!.fetchHomePage();
                              })
                        ],
                      ),
                    )));
    }
/*    setState(() {
      isLoading = false;
    });*/
  }

  int _getRestaurantRowCount(int restaurantCount) {
    int i;
    for (i = 1; i * 3 < restaurantCount; i++);
    return i;
  }

  void _switchAllRestaurant() {
    // tell welcome page to switch.
    /*setState(() {
      HomePage.updateSelectedPage(2);
    });*/
    StateContainer.of(context).updateTabPosition(tabPosition: 1);
  }

  @override
  void networkError() {
    // TODO: implement networkError
    showLoading(false);
    mToast("${AppLocalizations.of(context)!.translate('network_error')}");
    /* setState(() {
      hasNetworkError = true;
    });*/
  }

  @override
  void showErrorMessage(String message) {
    // TODO: implement showErrorMessage
    //  hasSystemError = true;
    showLoading(false);
    mToast("${AppLocalizations.of(context)!.translate('error_message')}");
  }

  @override
  void showLoading(bool isLoading) {
    // TODO: implement showLoading
    setState(() {
      this.isLoading = isLoading;
    });
  }

  @override
  void sysError() {
    // TODO: implement sysError
    setState(() {
      hasSystemError = true;
    });
  }

  @override
  void updateHomeWelcomePage(HomeScreenModel data) {
    // TODO: implement updateHomeWelcomePage
    setState(() {
      if (data != null) widget.data = data;
    });
  }

  void mToast(String message) {
    to.Toast.show(message, duration: 5);
  }

  _jumpToAdsList(List<AdModel> slider, int position) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AdsPreviewPage(
            ads: slider,
            position: position,
            presenter: AdsViewerPresenter(AdsViewerView())),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }

  _textSizeWithText(String feed) {
    double ssize = 0;
    if (feed != null) ssize = 1.0 * feed.length;
    // from 8 to 16 according to the size.
    // 8 for more than ...
    // to 16 as maximum.
    return (230 - 2 * ssize) / 13;
  }

  Future<void> _callCustomerCare() async {
//    Toast.show("call customer care", context);
    const url = "tel:+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      to.Toast.show("Call error");
    }
  }

  @override
  void tokenUpdateSuccessfully() {
    CustomerUtils.setPushTokenUploadedSuccessfully();
  }

  @override
  void hasUnreadMessages(bool hasNewMessage) {
    if (hasNewMessage) {
      // check inside the sharedprefs
      if (StateContainer.of(context).hasUnreadMessage) {
        // StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: hasNewMessage);
        StateContainer.of(context).hasUnreadMessage = hasNewMessage;
        _playMusicForNewMessage();
      }
      setState(() {
        /* StateContainer.of(context).updateUnreadMessage(
            hasUnreadMessage: hasNewMessage);
    */
        StateContainer.of(context).hasUnreadMessage = hasNewMessage;
      });
    } else {
      setState(() {
        /*    StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);*/
        StateContainer.of(context).hasUnreadMessage = false;
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _getShinningImage(ShopModel restaurant) {
    //
    if (restaurant.is_new == 1) {
      // new logo
      return ShinningTextWidget(
          text: "${AppLocalizations.of(context)!.translate('new')}",
          backgroundColor: KColors.primaryYellowColor,
          textColor: Colors.white);
    } else {
      if (restaurant.is_promotion == 1) {
        // promotion
        return ShinningTextWidget(
            text: "${AppLocalizations.of(context)!.translate('promo')}",
            backgroundColor: KColors.primaryColor,
            textColor: Colors.white);
      } else {
        return Container();
      }
    }
  }
/*
  Future<void> _jumpToScanPage() async {

    /* before we get here, we should ask some permission, the camera permission */
    if (!(await Permission.camera.request().isGranted)) {
      return;
    }

    Map results = await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            KabaScanPage(customer: widget.customer!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));

    if (results.containsKey("qrcode")) {
      String qrCode = results["qrcode"];
      /* continue transaction with this*/
      xrint("scan data : "+qrCode);
      var _res = _handleLinksImmediately(qrCode);
      if (_res == null) {
        xrint("_handleLinksImmediately sends  NULL");
      } else {
        // if it's a link, open the browser
        if (Utils.isWebLink(qrCode)) {
          xrint("is weblink");
          _launchURL(qrCode);
        } else {
          xrint("not link, then show dialog");
          mDialog(qrCode);
        }
        xrint("_handleLinksImmediately DO NOT SEND NULL");
      }
    } else {
      xrint("_handleLinksImmediately SCANNING WENT WRONG");
      mDialog("${AppLocalizations.of(context)!.translate('qr_code_wrong')}");
    }
  }
*/

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

  void _jumpToAddVoucherPage() {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddVouchersPage(
                presenter: AddVoucherPresenter(AddVoucherView()),
                customer: widget.customer!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));
  }

  @override
  void checkServiceMessage(AlertMessageModel data) {
    inflateServiceMessage(data);

    isMessageSeenMessageAlert(data).then((value) {
      if (value == false &&
          StateContainer.of(context).service_message["show"] == 1) {
        // showOverlayfunctionwithmessage(data);
        showDialogForEmergencyMessage(
            "${StateContainer.of(context).service_message["message"]}", data);
      }
    });
  }

  void showOverlayfunctionwithmessage(AlertMessageModel data) {
    showOverlayNotification((context) {
      return StateContainer.of(context).service_message["show"] == 1
          ? Container(
              color: KColors.mBlue,
              padding: EdgeInsets.only(left: 8, bottom: 5, right: 8, top: 45),
              child: Column(
                children: [
                  // {"message": smessage, "date": message_date};
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text("${AppLocalizations.of(context)!.translate('notice')}",
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            // fontFamily: "Dosis-Bold",
                            fontSize: 16))
                  ]),
                  Container(height: 3),
                  Text(
                      "${StateContainer.of(context).service_message["message"]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          // fontFamily: "Dosis-Light",
                          fontSize: 11)),
                  Container(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                      onPressed: () {
                        saveMessageAsRead(data);
                        setState(() {
                          OverlaySupportEntry.of(context)!
                              .dismiss(animate: true);
                        });
                      },
                      child: Text(
                          "${AppLocalizations.of(context)!.translate('alert_message_received')}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              // fontFamily: "Dosis-Bold",
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ])
                ],
              ),
              alignment: Alignment.center,
            )
          : Container();
    }, position: NotificationPosition.top, duration: Duration.zero);
  }

  void inflateServiceMessage(AlertMessageModel data) {
    String defaultLocale = Platform.localeName;
    String smessage = data.messages!["fr"];
    if (defaultLocale.contains("en")) {
      smessage = data.messages!["en"];
    } else if (defaultLocale.contains("fr")) {
      smessage = data.messages!["fr"];
    } else if (defaultLocale.contains("zh")) {
      smessage = data.messages!["zh"];
    }
    StateContainer.of(context).service_message = {
      "message": smessage,
      "show": data.showAlert
    };
  }

  @override
  void checkVersion(
      String code, int force, String cl_en, String cl_fr, String cl_zh) {
    String mCode = code.replaceAll(new RegExp(r'\.'), "");

    String defaultLocale = Platform.localeName;
    String cl = cl_fr;

    if (defaultLocale.contains("en")) {
      cl = cl_en;
    } else if (defaultLocale.contains("fr")) {
      cl = cl_fr;
    } else if (defaultLocale.contains("zh")) {
      cl = cl_zh;
    }

    int _code = int.parse(mCode);
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      String appCode_ = packageInfo.version.replaceAll(new RegExp(r'\.'), "");
      int appCode = int.parse(appCode_);
//     xrint("net-code = $code");
//     xrint("app-code = $appCode");
      if (appCode < _code) {
        // 2.3.4 < 4.5.6
        if (force == 1) {
          /* show the dialog. */
          Future.delayed(new Duration(seconds: 1)).then((value) {
            iShowDialog(code, 1, change_log: cl);
          });
        } else {
          /* check if  already shown, if not then we show it again.*/
          /* give a way to say no. */
          /* and save it to the shared preferences not to bother the client in the future */
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (prefs.get("${code}") != 1) {
            prefs.setInt("${code}", 1).then((value) {
              Future.delayed(new Duration(seconds: 1)).then((value) {
                iShowDialog(code, 0, change_log: cl);
              });
            });
          }
        }
      }
    });
  }

  void showDialogForEmergencyMessage(String message, AlertMessageModel data) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: new AssetImage(ImageAssets.emergency_icon),
                      ))),
              SizedBox(height: 10),
              Text("$message",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13)),
              SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                OutlinedButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.grey, width: 1))),
                  child: new Text(
                      "${AppLocalizations.of(context)!.translate('ok')}",
                      style: TextStyle(color: KColors.primaryColor)), // update
                  onPressed: () {
                    saveMessageAsRead(data);
                    Navigator.of(context).pop();
                  },
                )
              ])
            ]),
          );
        });
//  });
  }

  void iShowDialog(String version, int force, {String? change_log = null}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(
                    height: 80,
                    width: 80,
                    child: Icon(Icons.settings,
                        size: 80, color: KColors.primaryColor)),
                SizedBox(height: 10),
                Text(
                    "$version\n${change_log == null ? AppLocalizations.of(context)!.translate('new_version_available') : change_log} ",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KColors.new_black, fontSize: 13))
              ]),
              actions: force == 1
                  ? <Widget>[
                      OutlinedButton(
                        child: new Text(
                            "${AppLocalizations.of(context)!.translate('update')} $version",
                            style: TextStyle(color: KColors.primaryColor)),
                        onPressed: () {
                          _updateApp();
                        },
                      ),
                    ]
                  : <Widget>[
                      OutlinedButton(
                        style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                BorderSide(color: Colors.grey, width: 1))),
                        child: new Text(
                            "${AppLocalizations.of(context)!.translate('refuse')}",
                            style: TextStyle(color: Colors.grey)), // update
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(
                                color: KColors.primaryColor, width: 1))),
                        child: new Text(
                            "${AppLocalizations.of(context)!.translate('update')} $version",
                            style: TextStyle(color: KColors.primaryColor)),
                        onPressed: () {
                          _updateApp();
                        },
                      ),
                    ]);
        });
//  });
  }

  void _updateApp() {
    if (Platform.isAndroid) {
      _launchURL(ServerConfig.ANDROID_APP_LINK);
    } else if (Platform.isIOS) {
      _launchURL(ServerConfig.IOS_APP_LINK);
    }
  }

  Future<dynamic> _launchURL(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      try {
        throw 'Could not launch $url';
      } catch (_) {
        xrint(_);
      }
    }
    return -1;
  }

  @override
  void showBalance(String balance) {
    xrint("balance ${balance}");
    StateContainer.of(context).updateBalance(balance: int.parse(balance));
    showBalanceLoading(false);
  }

  @override
  void showBalanceLoading(bool isLoading) {
    setState(() {
      try {
        StateContainer.of(context)
            .updateBalanceLoadingState(isBalanceLoading: isLoading);
      } catch (_) {
        xrint(_.toString());
      }
    });
  }

  @override
  void updateKabaPoints(String kabaPoints) {
    // StateContainer.of(context).updateKabaPoints(kabaPoints: kabaPoints);
  }

  _jumpToWhatsapp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}',
      text: "${AppLocalizations.of(context)!.translate('i_have_an_inquiry')}",
    );
    // Convert the WhatsAppUnilink instance to a string.
    // Use either Dart's string interpolation or the toString() method.
    // The "launch" method is part of "url_launcher".
    await launch('$link');
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
//                      border: new Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                new AssetImage(ImageAssets.login_description),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context)!.translate("please_login_before_going_forward_random")}",
                      textAlign: TextAlign.center)
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
                  /* */
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

  Future<bool> isMessageSeenMessageAlert(AlertMessageModel data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool val = false;
    if (data.uuid != null && prefs.containsKey(data.uuid!))
      val = prefs.get(data.uuid!) as bool;
    return val;
  }

  Future<void> saveMessageAsRead(AlertMessageModel data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data?.uuid != null) prefs.setBool(data.uuid!, true);
  }
}

class KabaRoundTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * 0.97);
    path.arcToPoint(Offset(size.width, size.height),
        radius: Radius.circular(2000));
//    path.lineTo(size.width, size.height*1);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(KabaRoundTopClipper oldClipper) => true;
}

void _jumpToPage(BuildContext context, page) {
  /* Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );*/

  Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
            position: tween.animate(curvedAnimation), child: child);
      }));
}

Future<void> _playMusicForNewMessage() async {
  // play music
  // AudioPlayer audioPlayer = AudioPlayer();
  // audioPlayer.play(MusicData.new_message);
  /*if (await Vibration.hasVibrator()
  ) {
    Vibration.vibrate(duration: 500);
  }*/
}

void _jumpToRestaurantDetails(BuildContext context, ShopModel restaurantModel) {
  /* Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          ShopDetailsPage(restaurant: restaurantModel, presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
    ),
  );*/

  Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ShopDetailsPage(
          restaurant: restaurantModel,
          presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
            position: tween.animate(curvedAnimation), child: child);
      }));
}
