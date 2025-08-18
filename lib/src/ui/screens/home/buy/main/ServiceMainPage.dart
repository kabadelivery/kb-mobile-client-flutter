import 'dart:io';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/rating/rating_bloc.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/contracts/service_category_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/customwidgets/BuyCategoryWidget.dart';
import 'package:KABA/src/ui/customwidgets/CurrentLocationTile.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/SearchStatelessWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPageRefined.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/out_of_app.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/shipping_package.dart';
import 'package:KABA/src/ui/screens/rating/rating_delivery.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/recustomlib/place_picker_removed_nearbyplaces.dart'
    as Pp;
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../../../../microservices/kaba_chine/presentation/page_holder.dart';
import '../../../../../models/DeliveryRatingPending.dart';
import '../../../../../utils/_static_data/ServerConfig.dart';
import '../../../../../utils/_static_data/Vectors.dart';
import '../../../../../utils/functions/NotLoggedInPopUp.dart';
import '../../../../../utils/functions/OutOfAppOrder/dialogToFetchDistrict.dart';
import '../../../../../utils/functions/permissions.dart';
import '../../../out_of_app_orders/fetching_package.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../rating/dialogPage.dart';
import '../../../rating/rating_article.dart';
import '../../_home/InfoPage.dart';

class ServiceMainPage extends StatefulWidget {
  static var routeName = "/ServiceMainPage";

  var argument;

  var destination;

  ServiceMainPresenter? presenter;

  CustomerModel? customer;

  List<ServiceMainEntity>? available_services = [];

  List<ServiceMainEntity>? coming_soon_services = [];

  Position? initialLocation;

  ServiceMainPage({Key? key, this.presenter}) : super(key: key);

  @override
  ServiceMainPageState createState() => ServiceMainPageState();
}

class ServiceMainPageState extends State<ServiceMainPage>
    implements ServiceMainView {
  bool? isLoading;

  bool? hasNetworkError;

  bool? hasSystemError;

  DeliveryAddressModel? _selectedAddress;

  late SharedPreferences prefs;

  bool isPickLocation = false;

  CurrentLocationTile? _myCurrentTile;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    this.widget.presenter!.checkVersion();
    widget.presenter!.serviceMainView = this;
    _pageController = PageController();

    if (widget.available_services == null) widget.available_services = [];

    if (widget.coming_soon_services == null) widget.coming_soon_services = [];

    hasSystemError = false;
    hasNetworkError = false;
    isLoading = false;
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
      xrint("net-code = $code");
      xrint("app-code = $appCode");
      xrint("app-cl = $cl");
      if (appCode < _code) {
        // 2.3.4 < 4.5.6
        if (force == 1) {
          /* show the dialog. */
          Future.delayed(new Duration(seconds: 1)).then((value) {
            iShowDialog(context,code, 1, change_log: cl);
          });
        } else {
          Future.delayed(new Duration(seconds: 1)).then((value) {
            iShowDialog(context,code, 0, change_log: cl);
          });
        }
      }else {
        CustomerUtils utils = CustomerUtils();
        bool isUpdateSeen = await utils.getViewUpdate();
        xrint("isUpdateSeen $isUpdateSeen");
        DeliveryRatingPending deliveryRatingPending =DeliveryRatingPending().fake();

        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.transparent, // transparent outer dialog
              child: ClipRRect(                     // clip children to rounded shape
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white, // actual visible background
                  height: 600,
                  width: 400,
                  child: BlocSelector<RatingBloc, RatingState, RatingState>(
                      selector: (state) {
                       return state;
                      },
                      builder: (context, state) {
                        if(state is NextPageState){
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        if(state is PreviousPageState){
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                        return PageView(
                                        controller: _pageController,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          RatingDelivery(deliveryRatingPending: deliveryRatingPending),
                                          RatingArticle(deliveryRatingPending: deliveryRatingPending),
                                        ],
                                      );
                      },
                  ),
                ),
              ),
            );
          },
        );



        if(!isUpdateSeen){showNewFeature(context, code);}
      }
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void showNewFeature(BuildContext context, String version) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    String defaultLocale = Platform.localeName;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full-screen image
          Positioned.fill(
            child: Container(
              height: MediaQuery.of(context).size.height*.7,
              width:MediaQuery.of(context).size.width*.95,
              color: Colors.black.withOpacity(0.7), // Optional: slight dim effect
              child:  Image.asset(
                defaultLocale.contains("fr")?
                "assets/images/png/update.png"
                    :defaultLocale.contains("en")?
                "assets/images/png/update.png"
                    :"assets/images/png/update.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Update button at bottom right
          Positioned(
            bottom: 40,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(color: Colors.white, width: 1)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('ok'),
                    style: TextStyle(color: KColors.primaryColor),
                  ),
                  onPressed: () async{
                    CustomerUtils utils = CustomerUtils();
                    await utils.setViewUpdate(enable: true);
                    overlayEntry!.remove();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );

    overlayState.insert(overlayEntry);
  }

  void iShowDialog(BuildContext context, String version, int force,{String? change_log = null}) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full-screen image
          Positioned.fill(
            child: Container(
              height: MediaQuery.of(context).size.height*.7,
              width:MediaQuery.of(context).size.width*.95,
              color: Colors.black.withOpacity(0.7), // Optional: slight dim effect
              child: Image.network(
                change_log!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Update button at bottom right
          Positioned(
            bottom: 40,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Refuse" button (if force == 0)
                if (force == 0)
                  OutlinedButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(BorderSide(color: Colors.white, width: 1)),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('refuse'),
                      style: TextStyle(color: KColors.primaryColor),
                    ),
                    onPressed: () {
                      overlayEntry!.remove();
                    },
                  ),
                SizedBox(width: 10),
                // "Update" button
                OutlinedButton(
                  style: ButtonStyle(

                    backgroundColor: MaterialStateProperty.all(KColors.primaryColor),
                  ),
                  child: Text(
                    "${AppLocalizations.of(context)!.translate('update')} $version",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    overlayEntry!.remove();
                    _updateApp();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    overlayState.insert(overlayEntry);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.available_services?.length == 0 &&
        widget.coming_soon_services?.length == 0) {
      widget.presenter?.fetchServiceCategoryFromLocation(
          StateContainer.of(context).location);
    }
    widget.presenter?.fetchBilling();
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
  }
  Future<void> _callCustomerCare() async {
//    Toast.show("call customer care", context);
    const url = "tel:+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
    }
  }
  _jumpToWhatsapp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}',
      text: "${AppLocalizations.of(context)!.translate('i_have_an_inquiry')}",
    );
    await launch('$link');
  }

  _showBottomContactSheet() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      expand: false,
      context: context,
      builder: (context) => Container(
          width: 335,
          height: 155,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Container(
                  width:335 ,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Text("${AppLocalizations.of(context)!.translate('contact_our_customer_service')}",style: TextStyle(color: Colors.white,fontSize: 14))),
              InkWell(
                onTap: () => {_callCustomerCare()},
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.translate('phone_call')}",
                            style: TextStyle(
                                fontSize: 14,
                                color: KColors.new_black,
                                fontWeight: FontWeight.w500)),
                        Icon(Icons.call, size: 20, color: KColors.primaryColor)
                      ]),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: KColors.new_gray,
                  height: 1),
              InkWell(
                onTap: () => {_jumpToWhatsapp()},
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)!.translate('whatsapp')}",
                            style: TextStyle(
                                fontSize: 14,
                                color: KColors.new_black,
                                fontWeight: FontWeight.w500)),
                        // Icon(Icons.call, size: 20, color: KColors.primaryColor)
                        Container(
                            width: 20,
                            height: 20,
                            child: Image.asset(ImageAssets.whatsapp)),
                      ]),
                ),
              ),
            ],
          )),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
          centerTitle: true,
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
            actions: <Widget>[
            InkWell(
            onTap: () => _showBottomContactSheet(),
                child: Container(
                width: 70,
                height: 42,
                child: IconButton(
                icon: Icon(Icons.phone, color: Colors.white),
                onPressed: () => _showBottomContactSheet(),
                ),
                ),
    ),
            ],
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context)!.translate('buy')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
                top: true,
                child: Container(
                  child: Container(
                      child: isLoading!
                          ? Center(child: MyLoadingProgressWidget())
                          : (hasNetworkError!
                              ? Center(child: MyLoadingProgressWidget())
                              : hasSystemError!
                                  ? _buildSysErrorPage()
                                  : _buildServicePage())),
                ))));
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          widget.presenter!.fetchServiceCategoryFromLocation(
              StateContainer.of(context).location!);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          widget.presenter!.fetchServiceCategoryFromLocation(
              StateContainer.of(context).location!);
        });
  }

  _buildServicePage() {
    return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [

                  /* hint */
                  SizedBox(height: 20),
                  StateContainer.of(context).location == null
                      ? GestureDetector(
                          onTap: () {
                            showPlacePicker(context);
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                "${AppLocalizations.of(context)!.translate("current_address_tile_hint")}",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              )),
                              Container(
                                height: 40,
                                width: 40,
                                child:
                                    Lottie.asset(LottieAssets.hint_direction),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  GestureDetector(
                    onTap: () {
                      showPlacePicker(context);
                    },
                    child: Stack(
                      children: [
                        StateContainer?.of(context)?.location == null
                            ? Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 15),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                    color: KColors.mBlue.withAlpha(10),
                                    borderRadius: BorderRadius.circular(5)),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            child: Icon(Icons.location_on,
                                                color: KColors.mBlue, size: 15),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: KColors.mBlue
                                                    .withAlpha(30)),
                                            padding: EdgeInsets.all(5)),
                                        SizedBox(width: 10),
                                        Text(
                                            Utils.capitalize(
                                                "${AppLocalizations.of(context)!.translate('please_select_main_location')}"),
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Container(
                                        child: Icon(Icons.add,
                                            color: KColors.primaryColor,
                                            size: 15),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: KColors.primaryColor
                                                .withAlpha(30)),
                                        padding: EdgeInsets.all(5)),
                                  ],
                                ),
                              )
                            : getCurrentTile(),
                        isPickLocation
                            ? Positioned(
                                top: 35,
                                right: 70,
                                child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.green,
                                      strokeWidth: 2,
                                    )))
                            : Container()
                      ],
                    ),
                  ),
                  InkWell(
                      child: SearchStatelessWidget(
                          title:
                              "${AppLocalizations.of(context)!.translate("what_want_buy")}"),
                      onTap: () {
                        _jumpToSearchPage("all");
                      }),
                  GridView(
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      childAspectRatio: 2.7,
                    ),
                    shrinkWrap: true,
                    children: [
                      GestureDetector(
                        onTap: () async{
                          if (StateContainer.of(context).loggingState == 0){
                            NotLoggedInPopUp(context);
                          }else{
                             await Permission.camera.status;
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => OutOfAppOrderPage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var begin = Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end);
                                  var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                                  return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child
                                  );
                                }
                            ));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                  color: KColors.buy_category_button_bg,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                               Container(
                                   width: 40,
                                   height: 40,
                                   child: Lottie.network("https://lottie.host/0b8428d8-5220-452a-929c-da6701e5c25b/3xLtR3XYdy.json")),
                                SizedBox(width: 9),
                                Text(
                                    "${AppLocalizations.of(context)!.translate('out_of_app')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: KColors.new_black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (StateContainer.of(context).loggingState == 0){
                            NotLoggedInPopUp(context);
                          }else{

                            List<Map<String,dynamic>> districts = [];
                            List<Map<String, dynamic>> cachedDistricts = await CustomerUtils.getCachedDistricts();
                            if(cachedDistricts != null && cachedDistricts.isNotEmpty){
                              districts = cachedDistricts;
                            }else{
                          try{
                            districts  = await showLoadingDialog(context);
                            xrint("districts $districts");
                          }catch(e) {
                            xrint("error $e");
                          }
                            }
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ShippingPackageOrderPage(districts: districts),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var begin = Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end);
                                  var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                                  return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child
                                  );
                                }
                            ));
                          }

                        },
                        child: Container(
                          decoration: BoxDecoration(
                  color: KColors.buy_category_button_bg,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                               Container(
                                   width: 40,
                                   height: 40,
                                   child: Lottie.network("https://lottie.host/acceab2f-6b56-4702-b133-7ba13a9c1766/jrGYvITPDT.json")),
                                SizedBox(width: 9),
                                Text(
                                    "${AppLocalizations.of(context)!.translate('package')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: KColors.new_black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          if (StateContainer.of(context).loggingState == 0){
                            NotLoggedInPopUp(context);
                          }else{
                            await Permission.camera.status;
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => WelcomeToKabaChine(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var begin = Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end);
                                  var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                                  return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child
                                  );
                                }
                            ));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: KColors.buy_category_button_bg,
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    child: Lottie.network("https://lottie.host/fe005783-1b4c-457e-83a3-a826d7388550/3c37XYz9Fo.json")),
                                SizedBox(width: 9),
                                Text(
                                    "${AppLocalizations.of(context)!.translate('china')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: KColors.new_black)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]..addAll(widget.available_services
                        !.map((e) => BuyCategoryWidget(e,
                            available: true,
                            mDialog: mDialog,
                            showPlacePicker: showPlacePicker))
                        .toList()),
                  ),
                  SizedBox(height: 30),
                  widget.coming_soon_services!.length! > 0
                      ? Opacity(
                          opacity: 0.5,
                          child: Container(
                            child: Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(left: 30),
                                      child: Text(
                                          "${AppLocalizations.of(context)!.translate('coming_soon')}")),
                                ],
                              ),
                              GridView(
                                physics: BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(20),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.7,
                                ),
                                shrinkWrap: true,
                                children: []..addAll(widget.coming_soon_services
                                    !.map((e) => BuyCategoryWidget(e,
                                        available: false, mDialog: mDialog))
                                    .toList()),
                              ),
                            ]),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 160)
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: .5,
                    child: Lottie.network(
                        'https://dev.kaba-delivery.com/downloads/lottie/currentThemeLottie.json',
                        width: 160,
                        height: 160, errorBuilder: (BuildContext context,
                            Object error, StackTrace? stackTrace) {
                      return Container();
                    }),
                  ),
                ))
          ],
        ));
  }

  void _jumpToSearchPage(String type) {
    if (StateContainer.of(context).location?.latitude == null &&
        StateContainer.of(context).hasAskedLocation == false) {
      StateContainer.of(context).hasAskedLocation = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${AppLocalizations.of(context)!.translate('info')}"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
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
                child:
                    Text("${AppLocalizations.of(context)!.translate('refuse')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _jumpToPage(
                      context,
                      ShopListPageRefined(
                          context: context,
                          type: type,
                          foodProposalPresenter:
                              RestaurantFoodProposalPresenter(RestaurantFoodProposalView()),
                          restaurantListPresenter: RestaurantListPresenter(RestaurantListView())));
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context)!.translate('accept')}"),
                onPressed: () {
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs!.setString("_has_accepted_gps", "ok");
                  Navigator.of(context).pop();
                  // call get location again...
                  showPlacePicker(context);
                },
              )
            ],
          );
        },
      );
    } else {
      _jumpToPage(
          context,
          ShopListPageRefined(
              context: context,
              type: type,
              foodProposalPresenter: RestaurantFoodProposalPresenter(RestaurantFoodProposalView()),
              restaurantListPresenter: RestaurantListPresenter(RestaurantListView())));
    }
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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
  void inflateServiceCategory(List<ServiceMainEntity> data) {
    setState(() {
      widget.available_services = [];
      widget.coming_soon_services = [];
      for (int i = 0; i < data.length; i++) {
        if (data[i].is_active == 1) {
          widget.available_services!.add(data[i]);
        }
        if (data[i].is_coming_soon == 1) {
          widget.coming_soon_services!.add(data[i]);
        }
      }
    });
  }

  @override
  void networkError() {
    if (widget?.available_services?.length == 0 &&
        widget?.coming_soon_services?.length == 0)
      setState(() {
        hasNetworkError = true;
      });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      hasNetworkError = false;
      hasSystemError = false;
    });
  }

  @override
  void systemError() {
    if (widget?.available_services?.length == 0 &&
        widget?.coming_soon_services?.length == 0)
      setState(() {
        hasSystemError = true;
      });
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "$message",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String? svgIcons,
      Icon? icon,
      var message,
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
                  style: TextStyle(color: KColors.new_black, fontSize: 12))
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

  void showPlacePicker(BuildContext context) async {
    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      String? _has_accepted_gps = prefs!.getString("_has_accepted_gps");
      /* no need to commit */
      /* expiration date in 3 months */
      if (_has_accepted_gps != "ok") {
        return showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${AppLocalizations.of(context)!.translate('info')}"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    /* add an image*/
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
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
                  onPressed: () {
                    /* */
                    prefs!.setString("_has_accepted_gps", "ok");
                    showPlacePicker(context);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        /* get last know position */
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        } else if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        } else {
          bool isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          if (!isLocationServiceEnabled) {
            await Geolocator.openLocationSettings();
          } else {
            if (isPickLocation) {
              xrint("already picking address, OUTTTTT");
              return;
            } else {
              setState(() {
                if (StateContainer.of(context).location != null)
                  widget.initialLocation = StateContainer.of(context).location;
                StateContainer.of(context).location = null;
                StateContainer.of(context).placemark = null;
                isPickLocation = true;
              });

              await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);

              Stream<Position> positionStream = Geolocator.getPositionStream();
              positionStream.first.then((position) {
                xrint("position stream");
                positionStream = Geolocator.getPositionStream();
                positionStream.first.then((position1) {
                  // we do it twice to make sure we get a good location
                  _jumpToPickAddressPage();
                }).catchError((onError) {
                  setState(() {
                    isPickLocation = false;
                  });
                });
              }).catchError((onError) {
                setState(() {
                  isPickLocation = false;
                });
              });
            }
          }
        }
      }
    });
  }

  void _jumpToPickAddressPage() async {
    if (StateContainer.of(context)?.location != null) {
      xrint("moving to me");
      Pp.PlacePickerState.initialTarget = LatLng(
          StateContainer.of(context).location!.latitude,
          StateContainer.of(context).location!.longitude);
    }

    xrint("i pick address");

    /* get my position */
    LatLng result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Pp.PlacePicker(AppConfig.GOOGLE_MAP_API_KEY,
            alreadyHasLocation: StateContainer.of(context)?.location != null)));
    /* use this location to generate details about the place the user lives and so on. */
    Position pos = await Geolocator.getCurrentPosition();
    if (result?.longitude != null) {
      setState(() {
        _myCurrentTile = null;
        StateContainer.of(context).placemark = null;
        StateContainer.of(context).location =
            Position(
              latitude: result.latitude,
              longitude: result.longitude,
              timestamp: DateTime.now(),
              accuracy: pos.accuracy,
              altitude: pos.altitude,
              altitudeAccuracy: pos.altitudeAccuracy,
              heading: pos.heading,
              headingAccuracy: pos.headingAccuracy,
              speed: pos.speed,
              speedAccuracy: pos.speedAccuracy,
            );

      });
    } else {
      if (widget.initialLocation != null) {
        setState(() {
          StateContainer.of(context).location = widget.initialLocation;
          widget.initialLocation = null;
        });
      }
    }

    /* location is saved locally */
    CustomerUtils.saveAddressLocally(StateContainer.of(context).location!);

    setState(() {
      isPickLocation = false;
    });
  }

  getCurrentTile() {
    if (_myCurrentTile == null) _myCurrentTile = new CurrentLocationTile(key: null,);
    return _myCurrentTile;
  }
}
