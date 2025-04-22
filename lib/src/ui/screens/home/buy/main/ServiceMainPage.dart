import 'package:KABA/src/StateContainer.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../utils/functions/NotLoggedInPopUp.dart';
import '../../../../../utils/functions/OutOfAppOrder/dialogToFetchDistrict.dart';
import '../../../out_of_app_orders/fetching_package.dart';

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

  SharedPreferences? prefs;

  bool isPickLocation = false;

  CurrentLocationTile? _myCurrentTile;

  @override
  void initState() {
    super.initState();

    widget.presenter!.serviceMainView = this;

    if (widget.available_services == null) widget.available_services = [];

    if (widget.coming_soon_services == null) widget.coming_soon_services = [];

    hasSystemError = false;
    hasNetworkError = false;
    isLoading = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.available_services?.length == 0 &&
        widget.coming_soon_services?.length == 0) {
      widget.presenter?.fetchServiceCategoryFromLocation(
          StateContainer.of(context).location!);
    }
    widget.presenter?.fetchBilling();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
          centerTitle: true,
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
                              ? _buildNetworkErrorPage()
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
                        onTap: () {
                          if (StateContainer.of(context).loggingState == 0){
                            NotLoggedInPopUp(context);
                          }else{
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
                      )
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
