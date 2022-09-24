import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/ProductWithShopDetailsWidget.dart';
import 'package:KABA/src/ui/customwidgets/SearchSwitchWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShopListWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// import 'package:android_intent/android_intent.dart';

class ShopListPageRefined extends StatefulWidget {
  Position location;

  RestaurantFoodProposalPresenter foodProposalPresenter;

  RestaurantListPresenter restaurantListPresenter;

  bool hasGps = false;

  PageStorageKey key;

  BuildContext context;

  CustomerModel customer;

  List<ShopModel> restaurantList = null;

  int samePositionCount = 0;

  String type;

  static var routeName = "/ShopListPageRefined";

  List<ShopModel> finalRestaurantList;

  ShopListPageRefined(
      {this.key,
      this.context,
      this.location,
      this.foodProposalPresenter,
      this.restaurantListPresenter,
      this.type})
      : super(key: key);

  @override
  _ShopListPageRefinedState createState() => _ShopListPageRefinedState();
}

class _ShopListPageRefinedState extends State<ShopListPageRefined>
    with AutomaticKeepAliveClientMixin<ShopListPageRefined>
    implements RestaurantFoodProposalView, RestaurantListView {
  var _filterEditController = TextEditingController();

  // List<ShopModel> data;
  List<ShopModel> visibleItems;

  bool _searchMode = false;
  bool _searchAutoFocus = false;

  int searchTypePosition = 1;

  bool searchMenuHasSystemError = false, searchMenuHasNetworkError = false;
  bool isSearchingMenus = false;

  List<ShopProductModel> foodProposals = null;

  String _filterDropdownValue;

  // GlobalKey firstItemKey = GlobalKey(debugLabel: Utils.getAlphaNumericString());

  ScrollController _searchListScrollController = ScrollController();
  ScrollController _restaurantListScrollController = ScrollController();
  SharedPreferences prefs;

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  // String last_update_timeout;

  int MAX_MINUTES_FOR_AUTO_RELOAD = 5;

  bool justInflatedFoodProposal = false;

  bool _isBottomLoading = false;

  int PAGE_SIZE = 20;

  String searchKey = "";
  String previousSearchKey = "";

  @override
  void initState() {
    _restaurantListScrollController.addListener(_onScroll);
    super.initState();
//    _filterDropdownValue = "${AppLocalizations.of(context).translate('cheap_to_exp')}";
    widget.foodProposalPresenter.restaurantFoodProposalView = this;
    widget.restaurantListPresenter.restaurantListView = this;

    _filterEditController.addListener(_filterEditContent);

    _focus.addListener(_onFocusChange);

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // timeout stuff
      // last_update_timeout = getTimeOutLastTime();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool has_subscribed = false;
      try {
        prefs.getBool('has_subscribed');
      } catch (_) {
        has_subscribed = false;
      }
      if (has_subscribed == false) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        _firebaseMessaging
            .subscribeToTopic(ServerConfig.TOPIC)
            .whenComplete(() => {prefs.setBool('has_subscribed', true)});
      }

      if (mounted) {
        // _getLastKnowLocation();

        if (widget.hasGps == false &&
            StateContainer?.of(context)?.location != null) {
          // if (StateContainer
          //     ?.of(context)
          //     ?.location == null) {
          //   widget.restaurantListPresenter.fetchShopList(widget.customer, null);
          // } else
          xrint("init -- 1");
          widget.restaurantListPresenter.fetchShopList(widget.customer,
              widget.type, StateContainer.of(context).location);
        } else {
          if (widget.hasGps &&
              (widget.restaurantList != null &&
                  widget.restaurantList.length > 0 &&
                  widget.restaurantList[0].distance != null &&
                  "".compareTo(widget.restaurantList[0].distance) != 0)) {
            xrint("init -- 2");
            return; // no need to fetch automatically
          } else {
            if (StateContainer?.of(context)?.location == null) {
              xrint("init -- 3");
              widget.restaurantListPresenter
                  .fetchShopList(widget.customer, widget.type, null);
            } else {
              xrint("init -- 4");
              widget.restaurantListPresenter.fetchShopList(widget.customer,
                  widget.type, StateContainer?.of(context)?.location);
            }
          }
        }
      }
    });
  }

  FocusNode _focus = FocusNode();

  @override
  void dispose() {
    // restaurantBloc.dispose();
    mainTimer.cancel();
    _filterEditController.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool autoFocusDone = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // should happen once only
    if (widget.type == "all" && !autoFocusDone) {
      _searchMode = true;
      _searchAutoFocus = true;
      autoFocusDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 0,
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                if (_searchMode) {
                  setState(() {
                    _searchAutoFocus = false;
                    _searchMode = false;
                  });
                } else
                  Navigator.pop(context);
              }),
          centerTitle: true,
          actions: [
            _searchMode || isLoading
                ? Container(
                    width: 60,
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _searchAutoFocus = true;
                        _searchMode = true;
                      });
                    },
                    icon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.white,
                    ))
          ],
          title: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            layoutBuilder: (currentChild, _) => currentChild,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(1.2, 0), end: Offset(0, 0))
                        .animate(animation),
                child: child,
              );
            },
            child: _searchMode
                ? Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            height: 35,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white.withAlpha(100)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        // do staff
                                        _searchMode = true;
                                      } else {
                                        // out search mode
                                        _searchMode = false;
                                      }
                                    },
                                    child: TextField(
                                        autofocus: _searchAutoFocus,
                                        controller: _filterEditController,
                                        onSubmitted: (val) {
                                          _searchAction(pressButton: true);
                                          xrint("on submitted");
                                        },
                                        onChanged: (val) {
                                          if (_searchAutoFocus)
                                            setState(() {
                                              _searchAutoFocus = false;
                                            });
                                          xrint("on onChanged");
                                          xrint("${val.toString()}");
                                          EasyDebounce.debounce(
                                              'search-input-debouncer',
                                              Duration(milliseconds: 700),
                                              () => {_searchAction()});
                                        },
                                        style: TextStyle(
                                            color: KColors.new_black,
                                            fontSize: 14),
                                        textInputAction: TextInputAction.search,
                                        decoration: InputDecoration.collapsed(
                                            hintText:
                                                "${AppLocalizations.of(context).translate('find_menu_or_restaurant')}",
                                            hintStyle: TextStyle(
                                                fontSize: 14,
                                                color: KColors.new_black
                                                    .withAlpha(150))),
                                        enabled: true),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _clearFocus();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 5, right: 5, bottom: 3, top: 3),
                                    child: Center(
                                      child: Icon(Icons.close,
                                          size: 20, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        /*  AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: searchTypePosition == 2
                              ? InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(5),
                                            bottomRight: Radius.circular(5)),
                                        color: KColors.primaryColor),
                                    // margin: EdgeInsets.only(top: 2),
                                    padding: EdgeInsets.only(
                                        top: 9, bottom: 9, right: 10, left: 10),
                                    child: Icon(Icons.search,
                                        color: Colors.white, size: 30),
                                  ),
                                  onTap: () {
                                    onSearchButtonTap();
                                  })
                              : Container(),
                        )*/
                      ],
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          Utils.capitalize(getCategoryTitle(context)[0]
                              //    "${AppLocalizations.of(context).translate('search')}"
                              ),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Container(
              child: isLoading
                  ? Center(child: MyLoadingProgressWidget())
                  : (hasNetworkError
                      ? _buildNetworkErrorPage()
                      : hasSystemError
                          ? _buildSysErrorPage()
                          : _buildRestaurantList(widget.restaurantList))),
        ));

    /* return Scaffold(
        backgroundColor: Colors.white,
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child:  StreamBuilder(
                stream: restaurantBloc.restaurantList,
                builder: (context, AsyncSnapshot<List<ShopModel>> snapshot) {
                  if (snapshot.hasData) {
                    return _buildRestaurantList(snapshot.data);
                  } else if (pageError) {
                    return ErrorPage(message:"${AppLocalizations.of(context).translate('network_error')}", onClickAction: (){
                      setState(() {
                        restaurantBloc.fetchShopList(customer: widget.customer, position: StateContainer.of(context).location);
                      });
                    });
                  }
                  return Center(child: Container(margin: EdgeInsets.only(top:20),child: MyLoadingProgressWidget()));
                })));*/
  }

  Map pageRestaurants = Map<int, dynamic>();

  _buildRestaurantList(List<ShopModel> d) {
    if (d == null) return;
    /* check if the previous had the distance */
    /* distance of restaurant - client */
/*    if (data?.length == null || data?.length == 0) {
      this.data = d;
    } else {
      if (data[0]?.distance == null || data[0]?.distance == "") {
        this.data = d;
      }
    }*/

    // filter restaurant into a map
    d.forEach((restaurant) {
      pageRestaurants[restaurant.id] = restaurant;
    });

    // category / 1001 / shop
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            SearchSwitchWidget(searchTypePosition, _choice, _filterFunction,
                _scrollToTopFunction, widget?.type),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
//                  SizedBox(height: 40)
                ]..add(
                        /* according to the search position, show a different page. */
                        searchTypePosition == 1
                            ? (!_searchMode
                                ? Container(
                                    color: Colors.white,
                                    height: MediaQuery.of(context).size.height -
                                        150,
//                              padding: EdgeInsets.only(bottom:230),
                                    child: widget.restaurantList?.length ==
                                                null ||
                                            widget.restaurantList?.length == 0
                                        ? Container(
                                            child: Center(
                                                child:
                                                    Column(children: <Widget>[
                                            SizedBox(height: 20),
                                            Icon(Icons.shopping_cart_sharp,
                                                color: Colors.grey),
                                            SizedBox(height: 10),
                                            Text(
                                                "${AppLocalizations.of(context).translate('no_content_to_show')}")
                                          ])))
                                        : RefreshIndicator(
                                            onRefresh: () async {
                                              if (StateContainer?.of(context)
                                                      ?.location ==
                                                  null) {
                                                widget.restaurantListPresenter
                                                    .fetchShopList(
                                                        widget.customer,
                                                        widget.type,
                                                        null);
                                              } else
                                                widget.restaurantListPresenter
                                                    .fetchShopList(
                                                        widget.customer,
                                                        widget.type,
                                                        StateContainer.of(
                                                                context)
                                                            .location);
                                            },
                                            color: Colors.purple,
                                            child: Scrollbar(
                                              isAlwaysShown: true,
                                              controller:
                                                  _restaurantListScrollController,
                                              child: ListView.builder(
                                                controller:
                                                    _restaurantListScrollController,
                                                itemCount:
                                                    visibleItems?.length != null
                                                        ? visibleItems.length +
                                                            1
                                                        : 0,
                                                itemBuilder:
                                                    (context, position) {
                                                  if (position ==
                                                      visibleItems?.length) {
                                                    if (hasMoreData()) {
                                                      return Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 100,
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator()));
                                                    } else {
                                                      return Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          height: 100,
                                                          child: Center(
                                                              child: Text(
                                                            "${AppLocalizations.of(context).translate("the_end")}",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                color: KColors
                                                                    .new_black),
                                                          )));
                                                    }
                                                  } else {
                                                    return ShopListWidget(
                                                        shopModel: visibleItems[
                                                            position]);
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                  )
                                : _showSearchPage())
                            : Container(
                                margin: EdgeInsets.only(top: 10),
                                child: isSearchingMenus
                                    ? Center(child: MyLoadingProgressWidget())
                                    : (searchMenuHasNetworkError
                                        ? _buildSearchMenuNetworkErrorPage()
                                        : searchMenuHasSystemError
                                            ? _buildSearchMenuSysErrorPage()
                                            : _buildSearchedFoodList())))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSearchButtonTap() {
    if (searchTypePosition == 2) {
      if (_filterEditController.text?.trim()?.length != null &&
          _filterEditController.text?.trim()?.length >= 3)
        widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
            widget.type, _filterEditController.text);
      else
        mDialog(
            "${AppLocalizations.of(context).translate('search_too_short')}");
    }
  }

  _choice(int selected) {
    setState(() {
      this.searchTypePosition = selected;
    });
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
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
                          svgIcons,
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
                          "${AppLocalizations.of(context).translate('refuse')}",
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
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  /*_checkLocationActivated () async {
//    return;
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${AppLocalizations.of(context).translate('cant_get_location')}"),
              content: Text("${AppLocalizations.of(context).translate('please_enable_gps')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text('${AppLocalizations.of(context).translate('ok')}'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }*/

  StreamSubscription<Position> positionStream;
  Position tmpLocation;

  Future _getLastKnowLocation() async {
    /* show a dialog describing that we are going to need to use permissions
    * //
    * */

    SharedPreferences.getInstance().then((value) async {
      prefs = value;

      String _has_accepted_gps = prefs.getString("_has_accepted_gps");
      /* no need to commit */
      /* expiration date in 3months */

      if (_has_accepted_gps != "ok") {
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate('request')}"
                      .toUpperCase(),
                  style: TextStyle(color: KColors.primaryColor)),
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
                              image: new AssetImage(ImageAssets.address),
                            ))),
                    SizedBox(height: 10),
                    Text(
                        "${AppLocalizations.of(context).translate('location_explanation_pricing')}",
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('refuse')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                      "${AppLocalizations.of(context).translate('accept')}"),
                  onPressed: () {
                    /* */
                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("_has_accepted_gps", "ok");
                    // call get location again...
                    _getLastKnowLocation();
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        // permission has been accepted
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          /*  ---- */
          // await Geolocator.openAppSettings();
          /* ---- */
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context).translate('permission_')}"
                        .toUpperCase(),
                    style: TextStyle(color: KColors.primaryColor)),
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
                                image: new AssetImage(ImageAssets.address),
                              ))),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context).translate('request_location_permission')}",
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('accept')}"),
                    onPressed: () async {
                      /* */
                      await Geolocator.openAppSettings();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
          /* ---- */
        } else if (permission == LocationPermission.denied) {
          /* ---- */
          // Geolocator.requestPermission();
          /* ---- */
          return showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    "${AppLocalizations.of(context).translate('permission_')}"
                        .toUpperCase(),
                    style: TextStyle(color: KColors.primaryColor)),
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
                                image: new AssetImage(ImageAssets.address),
                              ))),
                      SizedBox(height: 10),
                      Text(
                          "${AppLocalizations.of(context).translate('request_location_permission')}",
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                        "${AppLocalizations.of(context).translate('accept')}"),
                    onPressed: () async {
                      /* */
                      Geolocator.requestPermission();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
          /* ---- */
        } else {
          // location is enabled
          bool isLocationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          if (!isLocationServiceEnabled) {
            /*  ---- */
            // await Geolocator.openLocationSettings();
            /* ---- */
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      "${AppLocalizations.of(context).translate('permission_')}"
                          .toUpperCase(),
                      style: TextStyle(color: KColors.primaryColor)),
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
                                  image: new AssetImage(
                                      ImageAssets.location_permission),
                                ))),
                        SizedBox(height: 10),
                        Text(
                            "${AppLocalizations.of(context).translate('request_location_activation_permission')}",
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                          "${AppLocalizations.of(context).translate('refuse')}"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                          "${AppLocalizations.of(context).translate('accept')}"),
                      onPressed: () async {
                        /* */
                        await Geolocator.openLocationSettings();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
            /* ---- */
          } else {
            positionStream =
                Geolocator.getPositionStream().listen((Position position) {
              /* compare current and old position */
              if (position?.latitude != null &&
                  tmpLocation?.latitude != null &&
                  (position.latitude * 100).round() ==
                      (tmpLocation.latitude * 100).round() &&
                  (position.longitude * 100).round() ==
                      (tmpLocation.longitude * 100).round()) {
                widget.samePositionCount++;
                // return;
              } else {
                widget.samePositionCount = 0;
                tmpLocation = StateContainer.of(widget.context).location;
                if (position != null && mounted) {
                  widget.hasGps = true;
                  StateContainer.of(context).updateLocation(location: position);
                  widget.restaurantListPresenter.fetchShopList(widget.customer,
                      widget.type, StateContainer.of(context).location);
                }
              }
              if (widget.samePositionCount >= 3 || widget.hasGps)
                positionStream?.cancel();
            });
          }
        }
      }
    });
  }

  _buildSearchMenuNetworkErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
              widget.type, _filterEditController.text);
        });
  }

  _buildSearchMenuSysErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
              widget.type, _filterEditController.text);
        });
  }

  _buildSearchedFoodList() {
    if (foodProposals == null)
      return Container(
          child: Center(
              child: Column(children: <Widget>[
        SizedBox(height: 20),
        Icon(Icons.search, color: Colors.grey),
        SizedBox(height: 10),
        Text("${AppLocalizations.of(context).translate('please_search_item')}")
      ])));

    if (foodProposals?.length == 0) {
      return Container(
          margin: EdgeInsets.all(20),
          child: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                SizedBox(height: 20),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                    "${AppLocalizations.of(context).translate('sorry_cant_find_item')}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12))
              ])));
    }

    var filteredResult =
        _filteredFoodProposal(_filterDropdownValue, foodProposals);

    if (justInflatedFoodProposal) {
      // firstItemKey = new GlobalKey(debugLabel: Utils.getAlphaNumericString());
      //
      _scrollToTop();
      justInflatedFoodProposal = false;
    }

    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height - 150,
//      padding: EdgeInsets.only(bottom:230),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _searchListScrollController,
        child: ListView.builder(
          addAutomaticKeepAlives: true,
          controller: _searchListScrollController,
          itemCount:
              filteredResult?.length != null ? filteredResult.length + 1 : 0,
          itemBuilder: (context, index) {
            if (index == filteredResult?.length) return Container(height: 300);
            return ProductWithShopDetailsWidget(
                // key: index == 0 ? firstItemKey : null,
                food: filteredResult[index]);
          },
        ),
      ),
    );
  }

  List<ShopModel> _filterEditContent() {
    // check if has focus
    setState(() {});
    /* launching request to look for food, but at the same moment, we need to cancel previous links. */
  }

  remove_filteredData(List<ShopModel> data) {
    /* we just filter based on the string that is entered */
    String content = _filterEditController.text;
    List<ShopModel> d = List();

    for (var restaurant in data) {
      String sentence =
          removeAccentFromString("${restaurant.name}".toLowerCase());
      String sentence1 = removeAccentFromString(content.trim()).toLowerCase();

//      xrint("filtered string ${sentence} => ${sentence1}");
      if (sentence.contains(sentence1)) {
        d.add(restaurant);
      }
    }
    return d;
  }

  String removeAccentFromString(String sentence) {
    String sentence1 = sentence
        .replaceAll(new RegExp(r'é'), "e")
        .replaceAll(new RegExp(r'è'), "e")
        .replaceAll(new RegExp(r'ê'), "e")
        .replaceAll(new RegExp(r'ë'), "e")
        .replaceAll(new RegExp(r'ē'), "e")
        .replaceAll(new RegExp(r'ė'), "e")
        .replaceAll(new RegExp(r'ę'), "e")
        .replaceAll(new RegExp(r'à'), "a")
        .replaceAll(new RegExp(r'á'), "a")
        .replaceAll(new RegExp(r'â'), "a")
        .replaceAll(new RegExp(r'ä'), "a")
        .replaceAll(new RegExp(r'æ'), "a")
        .replaceAll(new RegExp(r'ã'), "a")
        .replaceAll(new RegExp(r'ā'), "a")
        .replaceAll(new RegExp(r'ô'), "o")
        .replaceAll(new RegExp(r'ö'), "o")
        .replaceAll(new RegExp(r'ò'), "o")
        .replaceAll(new RegExp(r'ó'), "o")
        .replaceAll(new RegExp(r'œ'), "o")
        .replaceAll(new RegExp(r'ø'), "o")
        .replaceAll(new RegExp(r'ō'), "o")
        .replaceAll(new RegExp(r'õ'), "o")
        .replaceAll(new RegExp(r'î'), "i")
        .replaceAll(new RegExp(r'ï'), "i")
        .replaceAll(new RegExp(r'í'), "i")
        .replaceAll(new RegExp(r'ī'), "i")
        .replaceAll(new RegExp(r'į'), "i")
        .replaceAll(new RegExp(r'ì'), "i")
        .replaceAll(new RegExp(r'û'), "u")
        .replaceAll(new RegExp(r'ü'), "u")
        .replaceAll(new RegExp(r'ù'), "u")
        .replaceAll(new RegExp(r'ú'), "u")
        .replaceAll(new RegExp(r'ū'), "u")

        //

        .replaceAll(new RegExp(r'É'), "e")
        .replaceAll(new RegExp(r'È'), "e")
        .replaceAll(new RegExp(r'Ê'), "e")
        .replaceAll(new RegExp(r'Ë'), "e")
        .replaceAll(new RegExp(r'Ē'), "e")
        .replaceAll(new RegExp(r'Ė'), "e")
        .replaceAll(new RegExp(r'Ę'), "e")
        .replaceAll(new RegExp(r'À'), "a")
        .replaceAll(new RegExp(r'Á'), "a")
        .replaceAll(new RegExp(r'Â'), "a")
        .replaceAll(new RegExp(r'Ä'), "a")
        .replaceAll(new RegExp(r'AÆ'), "a")
        .replaceAll(new RegExp(r'Ã'), "a")
        .replaceAll(new RegExp(r'Å'), "a")
        .replaceAll(new RegExp(r'Ā'), "a")
        .replaceAll(new RegExp(r'Ô'), "o")
        .replaceAll(new RegExp(r'Ö'), "o")
        .replaceAll(new RegExp(r'Ò'), "o")
        .replaceAll(new RegExp(r'Ó'), "o")
        .replaceAll(new RegExp(r'Œ'), "o")
        .replaceAll(new RegExp(r'Ø'), "o")
        .replaceAll(new RegExp(r'Ō'), "o")
        .replaceAll(new RegExp(r'Õ'), "o")
        .replaceAll(new RegExp(r'Î'), "i")
        .replaceAll(new RegExp(r'Ï'), "i")
        .replaceAll(new RegExp(r'Í'), "i")
        .replaceAll(new RegExp(r'Ī'), "i")
        .replaceAll(new RegExp(r'Į'), "i")
        .replaceAll(new RegExp(r'Ì'), "i")
        .replaceAll(new RegExp(r'Û'), "u")
        .replaceAll(new RegExp(r'Ü'), "u")
        .replaceAll(new RegExp(r'Ù'), "u")
        .replaceAll(new RegExp(r'Ú'), "u")
        .replaceAll(new RegExp(r'Ū'), "u")
        .replaceAll(new RegExp(r"'"), "")
        .replaceAll(new RegExp(r" "), "");

    return sentence1;
  }

  void _clearFocus({bool close = false}) {
    setState(() {
      _filterEditController.text = "";
      _searchMode = close;
    });
    _filterEditController.clear();
    _searchAction();
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _showSearchPage() {
    if (visibleItems?.length == 0)
      return Container(
          child: Center(
              child: Column(children: <Widget>[
        SizedBox(height: 20),
        Icon(Icons.shopping_cart_sharp, color: Colors.grey),
        SizedBox(height: 10),
        Text("${AppLocalizations.of(context).translate('no_content_to_show')}")
      ])));

    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height - 150,
      // padding: EdgeInsets.only(bottom: 230),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _restaurantListScrollController,
        child: ListView.builder(
          controller: _restaurantListScrollController,
          itemCount: visibleItems?.length != null ? visibleItems.length + 1 : 0,
          itemBuilder: (context, position) {
            if (position == visibleItems?.length) {
              if (hasMoreData()) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()));
              } else {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Center(
                        child: Text(
                      "${AppLocalizations.of(context).translate("the_end")}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: KColors.new_black),
                    )));
              }
            } else {
              return ShopListWidget(shopModel: visibleItems[position]);
            }
          },
        ),
        /*     child: ListView.builder(
          addAutomaticKeepAlives: true,
          controller: _restaurantListScrollController,
          itemCount: visibleItems.length + 1,
          itemBuilder: (context, index) {
            if (index == visibleItems?.length) return Container(height: 300);
            return ShopListWidget(shopModel: visibleItems[index]);
          },
        ),*/
      ),
    );
  }

  List<ShopProductModel> inflateFoodProposalWorker(
      List<ShopProductModel> foods) {
    for (var i = 0; i < foods?.length; i++) {
      if (foods[i]?.restaurant_entity?.id != null &&
          pageRestaurants[foods[i]?.restaurant_entity?.id] != null) {
        // we get the restaurant and we switch it.
        foods[i].restaurant_entity =
            pageRestaurants[foods[i]?.restaurant_entity?.id];
      }
    }
    return foods;
  }

  @override
  void inflateFoodsProposal(List<ShopProductModel> foods) {
    setState(() {
      this.foodProposals = inflateFoodProposalWorker(foods);
      this.justInflatedFoodProposal = true;
    });
  }

  @override
  void searchMenuNetworkError() {
    setState(() {
      searchMenuHasNetworkError = true;
    });
  }

  @override
  void searchMenuSystemError() {
    setState(() {
      searchMenuHasSystemError = true;
    });
  }

  @override
  void searchMenuShowLoading(bool isLoading) {
    setState(() {
      if (isLoading == true) {
        this.searchMenuHasNetworkError = false;
        this.searchMenuHasSystemError = false;
      }
      this.isSearchingMenus = isLoading;
    });
  }

  _filteredFoodProposal(
      String filterDropdownValue, List<ShopProductModel> foodProposals) {
    if (filterDropdownValue ==
        ("${AppLocalizations.of(context).translate('cheap_to_exp')}")) {
      // cheap to exp
      List<ShopProductModel> fd = foodProposals;
      try {
        /*fd.sort(
            (fd1, fd2) => int.parse(fd1.price).compareTo(int.parse(fd2.price)));*/
        fd.sort((ShopProductModel fd1, ShopProductModel fd2) {
          try {
            return int.parse(fd1.price).compareTo(int.parse(fd2.price));
          } catch (e) {
            print(fd1.toString() + fd2.toString());
            return 0;
          }
        });
      } catch (_) {
        xrint("error here - cheap_to_exp");
      }
      return fd;
    }

    if (filterDropdownValue ==
        ("${AppLocalizations.of(context).translate('exp_to_cheap')}")) {
      // cheap to exp
      List<ShopProductModel> fd = foodProposals;
      try {
        fd.sort((ShopProductModel fd1, ShopProductModel fd2) {
          try {
            return int.parse(fd2.price).compareTo(int.parse(fd1.price));
          } catch (e) {
            print(fd1.toString() + fd2.toString());
            return 0;
          }
        });
      } catch (_) {
        xrint("error here - exp_to_cheap");
      }
      return fd;
    }

    if (filterDropdownValue ==
        ("${AppLocalizations.of(context).translate('farest')}")) {
      // farest
      List<ShopProductModel> fd = foodProposals;
      if (fd != null &&
          fd.length > 0 &&
          fd[0]?.restaurant_entity?.delivery_pricing != null)
        try {
          /*   fd.sort((fd1, fd2) =>
              int.parse(fd2.restaurant_entity?.delivery_pricing).compareTo(
                  int.parse(fd1.restaurant_entity?.delivery_pricing)));*/

          fd.sort((ShopProductModel fd1, ShopProductModel fd2) {
            try {
              return int.parse(fd2.restaurant_entity?.delivery_pricing)
                  .compareTo(
                      int.parse(fd1.restaurant_entity?.delivery_pricing));
            } catch (e) {
              print(fd1.toString() + fd2.toString());
              return 0;
            }
          });
        } catch (_) {
          xrint("error here - farest");
        }
      return fd;
    }

    if (filterDropdownValue ==
        ("${AppLocalizations.of(context).translate('nearest')}")) {
      // nearest
      List<ShopProductModel> fd = foodProposals;
      if (fd != null &&
          fd.length > 0 &&
          fd[0]?.restaurant_entity?.delivery_pricing != null)
        try {
          fd.sort((ShopProductModel fd1, ShopProductModel fd2) {
            try {
              return int.parse(fd1.restaurant_entity?.delivery_pricing)
                  .compareTo(
                      int.parse(fd2.restaurant_entity?.delivery_pricing));
            } catch (e) {
              print(fd1.toString() + fd2.toString());
              return 0;
            }
          });
        } catch (_) {
          xrint("error here - nearest");
        }

      return fd;
    }

    return foodProposals;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void inflateRestaurants(List<ShopModel> restaurants) {
    PAGE_SIZE = 20;
    setState(() {
      widget.finalRestaurantList = restaurants;
      widget.restaurantList = restaurants;
      _setLastTimeRestaurantListRequestToNow();
      visibleItems = (widget?.restaurantList?.length != null &&
              widget?.restaurantList?.length > PAGE_SIZE
          ? widget.restaurantList.sublist(0, PAGE_SIZE)
          : widget.restaurantList);
    });
    restartTimer();
  }

  @override
  void loadRestaurantListLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) super.setState(fn);
  }

  @override
  void networkError([bool silently]) {
    // if (!silently && widget.restaurantList?.length != null && widget.restaurantList.length>0)
    if (!silently || widget?.restaurantList?.length == 0)
      setState(() {
        hasNetworkError = true;
      });
  }

  @override
  void systemError([bool silently]) {
    if (!silently || widget?.restaurantList?.length == 0)
      setState(() {
        hasSystemError = true;
      });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.restaurantListPresenter.fetchShopList(widget.customer,
              widget.type, StateContainer.of(context).location);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.restaurantListPresenter.fetchShopList(widget.customer,
              widget.type, StateContainer.of(context).location);
        });
  }

  Timer mainTimer;

  void restartTimer() {
    if (mainTimer != null) mainTimer.cancel();

    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (ModalRoute.of(context)?.settings?.name == null ||
          !("/HomePage".compareTo(ModalRoute.of(context)?.settings?.name) ==
                  0 &&
              ModalRoute.of(context).isCurrent)) {
        // check if time is ok
        return;
      }

      int POTENTIAL_EXECUTION_TIME = 3;
      int diff = (DateTime.now().millisecondsSinceEpoch -
              StateContainer.of(context)
                  .last_time_get_restaurant_list_timeout) ~/
          1000;

      // convert different in minute seconds
      int min = (diff + POTENTIAL_EXECUTION_TIME) ~/ 60;

      if (min >= MAX_MINUTES_FOR_AUTO_RELOAD ||
          (widget.hasGps == false &&
              (StateContainer.of(context).location != null)))
        widget.restaurantListPresenter.fetchShopList(widget.customer,
            widget.type, StateContainer.of(context).location, true);

      if (!widget.hasGps)
        widget.hasGps = (StateContainer.of(context).location != null);
    });
  }

  _filterFunction(String newValue) {
    setState(() {
      _filterDropdownValue = newValue;
    });
    _scrollToTop();
  }

  _scrollToTopFunction() {
    _restaurantListScrollController.animateTo(
        _restaurantListScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn);
  }

  Future<int> _setLastTimeRestaurantListRequestToNow() async {
    StateContainer.of(context).last_time_get_restaurant_list_timeout =
        DateTime.now().millisecondsSinceEpoch;
  }

  getTimeOutLastTime() {
    if (StateContainer.of(context).last_time_get_restaurant_list_timeout == 0) {
      return "";
    } else {
      // time different since last time update
      int diff = (DateTime.now().millisecondsSinceEpoch -
              StateContainer.of(context)
                  .last_time_get_restaurant_list_timeout) ~/
          1000;
      // convert different in minute seconds
      int min = diff ~/ 60;
      int sec = diff % 60;
      return "${min < 10 ? "0" : ""}${min}:${sec < 10 ? "0" : ""}${sec}";
    }
  }

  void _scrollToTop() {
    Future.delayed(Duration(milliseconds: 300), () {
      // Scrollable.ensureVisible(firstItemKey.currentContext);
      _searchListScrollController.animateTo(
          _searchListScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn);
    });
  }

  getCategoryTitle(BuildContext context) {
    var tmp = [
      AppLocalizations.of(context).translate('service_shop_type_name'),
      AppLocalizations.of(context).translate('service_shop_type_product')
    ];

    switch (widget?.type) {
      case "food": // food
        tmp = [
          AppLocalizations.of(context)
              .translate('service_restaurant_type_name'),
          AppLocalizations.of(context)
              .translate('service_restaurant_type_product')
        ];
        break;
      case "drink": // drinks
        tmp = [
          AppLocalizations.of(context).translate('service_drink_type_name'),
          AppLocalizations.of(context).translate('service_drink_type_product')
        ];
        break;
      case "flower": // flowers
        tmp = [
          AppLocalizations.of(context).translate('service_flower_type_name'),
          AppLocalizations.of(context).translate('service_flower_type_product')
        ];
        break;
        /*   case "supermarket": // flowers
        tmp = [
          AppLocalizations.of(context).translate('service_flower_type_name'),
          AppLocalizations.of(context).translate('service_flower_type_product')
        ];*/
        break;
      //   case 1005: // movies
      //     category_name_code = "service_category_movies";
      //     break;
      //   case 1006: // package delivery
      //     category_name_code = "service_category_package_delivery";
      //     break;
      case "shop": // shopping
        tmp = [
          AppLocalizations.of(context).translate('service_shop_type_name'),
          AppLocalizations.of(context).translate('service_shop_type_product')
        ];
        break;
      case "drugstore": // shopping
        tmp = [
          AppLocalizations.of(context).translate('service_drugstore_type_name'),
          AppLocalizations.of(context)
              .translate('service_drugstore_type_product')
        ];
        break;
      case "book": // shopping
        tmp = [
          AppLocalizations.of(context).translate('service_book_type_name'),
          AppLocalizations.of(context).translate('service_book_type_product')
        ];
        break;
      case "ticket": // ticket
        tmp = [
          AppLocalizations.of(context).translate('service_ticket_type_name'),
          AppLocalizations.of(context).translate('service_ticket_product_name')
        ];
        break;
      case "grocery": // ticket
        tmp = [
          AppLocalizations.of(context).translate('service_grocery_type_name'),
          AppLocalizations.of(context).translate('service_grocery_product_name')
        ];
        break;
      case "drugstore": // ticket
        tmp = [
          AppLocalizations.of(context).translate('service_drugstore_type_name'),
          AppLocalizations.of(context)
              .translate('service_drugstore_product_name')
        ];
        break;
    }
    return tmp;
  }

  void _searchAction({bool pressButton = false}) {
    if (searchTypePosition == 2) {
      if (_filterEditController.text?.trim()?.length != null &&
          _filterEditController.text?.trim()?.length >= 2)
        widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
            widget.type, _filterEditController.text);
      else {
        if (pressButton)
          mDialog(
              "${AppLocalizations.of(context).translate('search_too_short')}");
      }
    } else {
      // send the filter request to
      if (previousSearchKey == _filterEditController.text) return;
      searchKey = _filterEditController.text?.trim();
      widget.restaurantListPresenter
          .filterShopList(widget.finalRestaurantList, searchKey);
    }
  }

  // huile, tourteau, lait de soja
  // rendre la zone dynamique / appirter des industries qui poront absober
  // pour eviter l'exportation de matière brute
  // zone industrielle estm la plus sure en electricite en afrique
  // electricitee dediee/ pas droit à l'erreur
  // 180.000 tonnes actuelles
  // 160.000 tonnes de cajou
  // 70.000 tonnes soja / an

  void _onFocusChange() {
    xrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  void inflateFilteredRestaurants(List<ShopModel> shops, String sKey) {
    PAGE_SIZE = 20;
    previousSearchKey = sKey;
    setState(() {
      widget.restaurantList = shops;
      visibleItems = (widget?.restaurantList?.length != null &&
              widget.restaurantList?.length > PAGE_SIZE
          ? widget.restaurantList.sublist(0, PAGE_SIZE)
          : widget.restaurantList);
    });
  }

  _onScroll() {
    if (_restaurantListScrollController.offset >=
            _restaurantListScrollController.position.maxScrollExtent &&
        !_restaurantListScrollController.position.outOfRange) {
      if (hasMoreData()) {
        setState(() {
          _isBottomLoading = true;
        });
        loadMore();
      } else {
        setState(() {
          _isBottomLoading = false;
        });
      }
    }
  }

  bool hasMoreData() {
    return visibleItems?.length < widget?.restaurantList?.length &&
        widget?.restaurantList?.length != null;
  }

  loadMore() async {
    await new Future.delayed(new Duration(milliseconds: 500));
    if (widget?.restaurantList?.length == null) {
      // empty list
    } else {
      if (visibleItems?.length == widget?.restaurantList?.length) {
        // end of the list
      } else {
        // append
        setState(() {
          visibleItems.addAll(widget.restaurantList.sublist(
              visibleItems.length,
              visibleItems.length + PAGE_SIZE >= widget.restaurantList.length
                  ? widget.restaurantList.length
                  : visibleItems.length + PAGE_SIZE));
        });
        PAGE_SIZE += 10;
      }
    }
    setState(() {
      _isBottomLoading = false;
    });
  }
}
