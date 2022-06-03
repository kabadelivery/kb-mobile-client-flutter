import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/customwidgets/FoodWithRestaurantDetailsWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// import 'package:android_intent/android_intent.dart';


class RestaurantListPage extends StatefulWidget {

  Position location;

  RestaurantFoodProposalPresenter foodProposalPresenter;
  RestaurantListPresenter restaurantListPresenter;

  bool hasGps = false;

  PageStorageKey key;

  BuildContext context;

  CustomerModel customer;

  List<RestaurantModel> restaurantList = null;

  int samePositionCount = 0;

  RestaurantListPage({this.key, this.context, this.location, this.foodProposalPresenter, this.restaurantListPresenter}) : super(key: key);

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();

}

class _RestaurantListPageState extends State<RestaurantListPage> with AutomaticKeepAliveClientMixin<RestaurantListPage> implements RestaurantFoodProposalView, RestaurantListView  {

  var _filterEditController = TextEditingController();

  List<RestaurantModel> data;

  bool _searchMode = false;

  Color filter_unactive_button_color = KColors.primaryColor, filter_active_button_color = Colors.white,
      filter_unactive_text_color = Colors.white, filter_active_text_color = KColors.primaryColor;

  int searchTypePosition = 1;

  bool searchMenuHasSystemError = false, searchMenuHasNetworkError = false;
  bool isSearchingMenus = false;

  List<RestaurantFoodModel> foodProposals = null;

  String _filterDropdownValue;

  GlobalKey firstItemKey = GlobalKey(debugLabel: Utils.getAlphaNumericString());

  ScrollController _searchListScrollController = ScrollController();
  ScrollController _restaurantListScrollController = ScrollController();
  SharedPreferences prefs;


  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  // String last_update_timeout;

  int MAX_MINUTES_FOR_AUTO_RELOAD = 5;

  bool justInflatedFoodProposal = false;

  @override
  void initState() {
    super.initState();

//    _filterDropdownValue = "${AppLocalizations.of(context).translate('cheap_to_exp')}";
    widget.foodProposalPresenter.restaurantFoodProposalView = this;
    widget.restaurantListPresenter.restaurantListView = this;

    _filterEditController.addListener(_filterEditContent);

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      // timeout stuff
      // last_update_timeout = getTimeOutLastTime();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool has_subscribed = false;
      try {
        prefs.getBool('has_subscribed');
      } catch(_) {
        has_subscribed = false;
      }
      if (has_subscribed == false) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
        _firebaseMessaging.subscribeToTopic(ServerConfig.TOPIC).whenComplete(() => {
          prefs.setBool('has_subscribed', true)
        });
      }

      if (mounted) {
        _getLastKnowLocation();

        if (widget.hasGps == false && StateContainer?.of(context)?.location != null) {
          // if (StateContainer
          //     ?.of(context)
          //     ?.location == null) {
          //   widget.restaurantListPresenter.fetchRestaurantList(widget.customer, null);
          // } else
          xrint("init -- 1");
          widget.restaurantListPresenter.fetchRestaurantList(
              widget.customer, StateContainer
              .of(context)
              .location);
        } else  {
          if (widget.hasGps && (widget.restaurantList != null && widget.restaurantList.length > 0 &&
              widget.restaurantList[0].distance != null && "".compareTo(widget.restaurantList[0].distance) != 0)) {
            xrint("init -- 2");
            return; // no need to fetch automatically
          } else {
            if (StateContainer
                ?.of(context)
                ?.location == null) {
              xrint("init -- 3");
              widget.restaurantListPresenter.fetchRestaurantList(widget.customer, null);
            } else {
              xrint("init -- 4");
              widget.restaurantListPresenter.fetchRestaurantList(
                  widget.customer, StateContainer
                  ?.of(context)
                  ?.location);
            }
          }
        }
      }
    });


    // firebase -- for restaurants
    // closed for a specific reason !
    // FirebaseDatabase database;
    // database = FirebaseDatabase.instance;
    // DatabaseReference ref = FirebaseDatabase.instance.ref("app-version");
    // ref.onValue.listen((event) {
    //   mDialog("${event.snapshot.value}");
    // });

    // for the version of kaba, we can put it once the app opens !
  }

  @override
  void dispose() {
    // restaurantBloc.dispose();
    mainTimer.cancel();
    _filterEditController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child:  Container(
              child: isLoading ? Center(child:MyLoadingProgressWidget()) : (
                  hasNetworkError ? _buildNetworkErrorPage() :
                  hasSystemError ? _buildSysErrorPage():
                  _buildRestaurantList(widget.restaurantList
                  )
              )
          ),
        ));

    /* return Scaffold(
        backgroundColor: Colors.white,
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child:  StreamBuilder(
                stream: restaurantBloc.restaurantList,
                builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
                  if (snapshot.hasData) {
                    return _buildRestaurantList(snapshot.data);
                  } else if (pageError) {
                    return ErrorPage(message:"${AppLocalizations.of(context).translate('network_error')}", onClickAction: (){
                      setState(() {
                        restaurantBloc.fetchRestaurantList(customer: widget.customer, position: StateContainer.of(context).location);
                      });
                    });
                  }
                  return Center(child: Container(margin: EdgeInsets.only(top:20),child: MyLoadingProgressWidget()));
                })));*/
  }

  Map pageRestaurants = Map<int, dynamic>();

  _buildRestaurantList(List<RestaurantModel> d) {

    if (d == null)
      return;
    /* check if the previous had the distance */
    /* distance of restaurant - client */
    if (data?.length == null || data?.length == 0) {
      this.data = d;
    } else {
      if (data[0]?.distance == null || data[0]?.distance == "") {
        this.data = d;
      }
    }

    // filter restaurant into a map
    d.forEach((restaurant) {
      pageRestaurants[restaurant.id] = restaurant;
    });

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        //    leading: null,
        backgroundColor: Colors.grey.shade100,
        title: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
//            border: new Border.all(color: Colors.white),
              color: Colors.white
          ),
          padding: EdgeInsets.only(left:8, right: 8),
          margin: EdgeInsets.only(top:8, bottom:8),
          child:Row(
            children: <Widget>[
              Expanded(
                child: Focus( onFocusChange: (hasFocus) {
                  if(hasFocus) {
                    // do staff
                    _searchMode = true;
                  } else {
                    // out search mode
//                    mToast("Out search mode");
                    _searchMode = false;
                  }
                },
                  child: TextField(controller: _filterEditController, onSubmitted: (val) {
                    if (searchTypePosition == 2) {
                      if (_filterEditController.text?.trim()?.length != null && _filterEditController.text?.trim()?.length >= 1)
                        widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
                            _filterEditController.text);
                      else
                        mDialog("${AppLocalizations.of(context).translate('search_too_short')}");
                    }
                  }, style: TextStyle(color: Colors.black, fontSize: 16), textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('find_menu_or_restaurant')}", hintStyle: TextStyle(fontSize: 15, color:Colors.grey)), enabled: true),
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.close, color: Colors.grey), onPressed: () {
                    _clearFocus();
                  }),
                  searchTypePosition == 2 ? IconButton(icon: Icon(Icons.search, color: KColors.primaryYellowColor), onPressed: () {
                    if (searchTypePosition == 2) {
                      if (_filterEditController.text?.trim()?.length != null && _filterEditController.text?.trim()?.length >= 3)
                        widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(
                            _filterEditController.text);
                      else
                        mDialog("${AppLocalizations.of(context).translate('search_too_short')}");
                    }
                  }) : Container(),
                ],
              )
            ],
          ),
        ),
      ),
      body:  AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          // margin: EdgeInsets.only(bottom: 58),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(height:10),
              Container(padding: EdgeInsets.only(left:20,right:20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedContainer(
                      decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_unactive_button_color : this.filter_unactive_button_color, borderRadius: BorderRadius.all(const  Radius.circular(40.0)),
                        border: new Border.all(color: searchTypePosition == 2 ? this.filter_unactive_button_color : this.filter_unactive_button_color, width: 1),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(onTap: () => _choice(1),child: Container(padding: EdgeInsets.all(10), child: Text("${AppLocalizations.of(context).translate('search_restaurant')}", style: TextStyle(fontSize: 10, color: searchTypePosition == 1 ? this.filter_active_text_color:this.filter_unactive_text_color)),  decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_active_button_color :  this.filter_unactive_button_color,borderRadius: new BorderRadius.circular(30.0)))),
                            SizedBox(width: 5),
                            InkWell(onTap: () => _choice(2),child: Container(padding: EdgeInsets.all(10), child: Text("${AppLocalizations.of(context).translate('search_food')}", style: TextStyle(fontSize: 10, color: searchTypePosition == 1 ? this.filter_unactive_text_color : this.filter_active_text_color)),   decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_unactive_button_color : this.filter_active_button_color,borderRadius: new BorderRadius.circular(30.0)))),
                          ]), duration: Duration(milliseconds: 3000),
                    ),
                    searchTypePosition == 1 ? Container(
                      child:  showCountDownButton(),
                    ) :
                    DropdownButton<String>(
                      value: _filterDropdownValue,
                      hint: Text("${AppLocalizations.of(context).translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor)),
                      /*Container(decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(5),
                          child: Text("${AppLocalizations.of(context).translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor))),
                      */
                      icon: Icon(FontAwesomeIcons.filter, color: KColors.primaryColor, size: 24,),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: KColors.primaryColor),
                      underline: Container(
//                      height: 2,
//                      color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _filterDropdownValue = newValue;
                        });
                      },
                      items: <String>['${AppLocalizations.of(context).translate('cheap_to_exp')}', '${AppLocalizations.of(context).translate('exp_to_cheap')}', '${AppLocalizations.of(context).translate('nearest')}', '${AppLocalizations.of(context).translate('farest')}']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              SizedBox(height:15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      children: <Widget>[
//                  SizedBox(height: 40)
                      ]
                        ..add(
                          /* according to the search position, show a different page. */
                            searchTypePosition == 1 ? (
                                !_searchMode ?
                                Container(color: Colors.white,
                                  height: MediaQuery.of(context).size.height,
//                              padding: EdgeInsets.only(bottom:230),
                                  child: RefreshIndicator(
                                    onRefresh: () async {
                                      if (StateContainer
                                          ?.of(context)
                                          ?.location == null) {
                                        widget.restaurantListPresenter.fetchRestaurantList(widget.customer, null);
                                      } else
                                        widget.restaurantListPresenter.fetchRestaurantList(widget.customer, StateContainer.of(context).location);
                                    },
                                    color: Colors.purple,
                                    child: Scrollbar(
                                      isAlwaysShown: true,
                                      controller: _restaurantListScrollController,
                                      child: ListView.builder(
                                        controller: _restaurantListScrollController,
                                        itemCount:  data?.length != null ? data.length + 1 : 0,
                                        itemBuilder: (context, index) {
                                          if (index == data?.length)
                                            return Container(height:100);
                                          return RestaurantListWidget(restaurantModel: data[index]);
                                        },
                                      ),
                                    ),
                                  ),
                                )
                                    : _showSearchPage()) :
                            Container(margin: EdgeInsets.only(top:20),
                                child: isSearchingMenus ? Center(child:MyLoadingProgressWidget()) :
                                (searchMenuHasNetworkError ? _buildSearchMenuNetworkErrorPage() :
                                searchMenuHasSystemError ? _buildSearchMenuSysErrorPage():
                                _buildSearchedFoodList())
                            )

                        )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        svgIcons,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
        );
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
              title:  Text("${AppLocalizations.of(context).translate('request')}".toUpperCase(),
                  style: TextStyle(color: KColors.primaryColor)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    /* add an image*/
                    // location_permission
                    Container(
                        height:100, width: 100,
                        decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: new AssetImage(ImageAssets.address),
                            )
                        )
                    ),
                    SizedBox(height:10),
                    Text("${AppLocalizations.of(context).translate('location_explanation_pricing')}", textAlign: TextAlign.center)
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("${AppLocalizations.of(context).translate('refuse')}"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("${AppLocalizations.of(context).translate('accept')}"),
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
                title:  Text("${AppLocalizations.of(context).translate('permission_')}".toUpperCase(), style: TextStyle(color: KColors.primaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height:100, width: 100,
                          decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new AssetImage(ImageAssets.address),
                              )
                          )
                      ),
                      SizedBox(height:10),
                      Text("${AppLocalizations.of(context).translate('request_location_permission')}", textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("${AppLocalizations.of(context).translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("${AppLocalizations.of(context).translate('accept')}"),
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
                title:  Text("${AppLocalizations.of(context).translate('permission_')}".toUpperCase(), style: TextStyle(color: KColors.primaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      /* add an image*/
                      // location_permission
                      Container(
                          height:100, width: 100,
                          decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: new AssetImage(ImageAssets.address),
                              )
                          )
                      ),
                      SizedBox(height:10),
                      Text("${AppLocalizations.of(context).translate('request_location_permission')}", textAlign: TextAlign.center)
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("${AppLocalizations.of(context).translate('refuse')}"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("${AppLocalizations.of(context).translate('accept')}"),
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
          bool isLocationServiceEnabled  = await Geolocator.isLocationServiceEnabled();
          if (!isLocationServiceEnabled) {
            /*  ---- */
            // await Geolocator.openLocationSettings();
            /* ---- */
            return showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title:  Text("${AppLocalizations.of(context).translate('permission_')}".toUpperCase(), style: TextStyle(color: KColors.primaryColor)),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        /* add an image*/
                        // location_permission
                        Container(
                            height:100, width: 100,
                            decoration: BoxDecoration(
//                      border: new Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: new AssetImage(ImageAssets.location_permission),
                                )
                            )
                        ),
                        SizedBox(height:10),
                        Text("${AppLocalizations.of(context).translate('request_location_activation_permission')}", textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text("${AppLocalizations.of(context).translate('refuse')}"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("${AppLocalizations.of(context).translate('accept')}"),
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
            positionStream = Geolocator.getPositionStream().listen(
                    (Position position) {
                  tmpLocation = StateContainer.of(widget.context).location;
                  if (position?.latitude != null && tmpLocation?.latitude != null &&
                      (position.latitude*10000).round() == (tmpLocation.latitude*10000).round() &&
                      (position.longitude*10000).round() == (tmpLocation.longitude*10000).round()) {
                    widget.samePositionCount++;
                    if (widget.samePositionCount >= 3 && widget.hasGps)
                      positionStream.cancel();
                    return;
                  }
                  widget.samePositionCount = 0;
                  if (position != null && mounted) {
                    StateContainer.of(context).updateLocation(location: position);
                    // widget.restaurantListPresenter.fetchRestaurantList(widget.customer, StateContainer.of(context).location);
                  }
                });
          }
        }
      }
    });
  }

  _buildSearchMenuNetworkErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(message:"${AppLocalizations.of(context).translate('network_error')}", onClickAction: (){
      widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
    });
  }

  _buildSearchMenuSysErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(message:"${AppLocalizations.of(context).translate('system_error')}", onClickAction: (){
      widget.foodProposalPresenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
    });
  }

  _buildSearchedFoodList() {
    if (foodProposals == null)
      return Container(child: Center(
          child: Column(children: <Widget>[
            SizedBox(height:20),
            Icon(Icons.restaurant, color: Colors.grey),
            SizedBox(height:10),
            Text("${AppLocalizations.of(context).translate('please_search_food')}")
          ])
      ));

    if (foodProposals?.length == 0) {
      return Container(child: Center(
          child: Column(children: <Widget>[
            SizedBox(height:20),
            Icon(Icons.restaurant, color: Colors.grey),
            SizedBox(height:10),
            Text("${AppLocalizations.of(context).translate('sorry_cant_find_food')}")
          ])
      ));
    }

    /* generating food proposals lazily */
    /*  return Column(children: <Widget>[]
      ..addAll(List<Widget>.generate(foodProposals?.length, (int index) {
        return FoodWithRestaurantDetailsWidget(food: foodProposals[index]);
      }).toList()));*/
    var filteredResult =  _filteredFoodProposal(_filterDropdownValue, foodProposals);

    if (justInflatedFoodProposal) {
      firstItemKey = new GlobalKey(debugLabel: Utils.getAlphaNumericString());
      //
      Future.delayed(Duration(milliseconds: 300), () {
        // Scrollable.ensureVisible(firstItemKey.currentContext);
          _searchListScrollController.animateTo(
              _searchListScrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn);
      });
      justInflatedFoodProposal = false;
    }

    return Container(color: Colors.white,
      height: MediaQuery.of(context).size.height,
//      padding: EdgeInsets.only(bottom:230),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _searchListScrollController,
        child: ListView.builder(
          controller: _searchListScrollController,
          itemCount: filteredResult?.length != null ? filteredResult.length + 1 : 0,
          itemBuilder: (context, index) {
            if (index == filteredResult?.length)
              return Container(height:300);
            return FoodWithRestaurantDetailsWidget(key: index == 0 ? firstItemKey : null, food: filteredResult[index]);
          },
        ),
      ),
    );
  }

  List<RestaurantModel> _filterEditContent() {
    setState(() {});
    /* launching request to look for food, but at the same moment, we need to cancel previous links. */
  }

  _filteredData(List<RestaurantModel> data) {
    String content = _filterEditController.text;
    List<RestaurantModel> d = List();

    for (var restaurant in data) {

      String sentence = removeAccentFromString("${restaurant.name}".toLowerCase());
      String sentence1 = removeAccentFromString(content.trim()).toLowerCase();

//      xrint("filtered string ${sentence} => ${sentence1}");
      if (sentence.contains(sentence1)) {
        d.add(restaurant);
      }
    }
    return d;
  }

  String removeAccentFromString(String sentence) {

    String  sentence1 =
    sentence
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
        .replaceAll(new RegExp(r" "), "")
    ;

    return sentence1;
  }

  void _clearFocus() {
    _filterEditController.clear();
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _showSearchPage() {
    /* show first few restaurants with a show more button, */
    /*  return <Widget>[]
      ..addAll(List<Widget>.generate(_filteredData(data).length, (int index) {
        return RestaurantListWidget(restaurantModel: _filteredData(data)[index]);
      }).toList())*/
    ;
    return Container(color: Colors.white,
      height: MediaQuery
          .of(context)
          .size
          .height,
      padding: EdgeInsets.only(bottom: 230),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _restaurantListScrollController,
        child: ListView.builder(
          controller: _restaurantListScrollController,
          itemCount: _filteredData(data).length,
          itemBuilder: (context, index) {
            return RestaurantListWidget(
                restaurantModel: _filteredData(data)[index]);
          },
        ),
      ),
    );
  }

  List<RestaurantFoodModel> inflateFoodProposalWorker (List<RestaurantFoodModel> foods) {
    for (var i = 0; i < foods?.length; i++) {
      if (foods[i]?.restaurant_entity?.id != null &&  pageRestaurants[foods[i]?.restaurant_entity?.id] != null) {
        // we get the restaurant and we switch it.
        foods[i].restaurant_entity =  pageRestaurants[foods[i]?.restaurant_entity?.id];
      }
    }
    return foods;
  }

  @override
  void inflateFoodsProposal(List<RestaurantFoodModel> foods) {
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

  _filteredFoodProposal(String filterDropdownValue, List<RestaurantFoodModel> foodProposals) {

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('cheap_to_exp')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      try {
        fd.sort((fd1, fd2) => int.parse(fd1.price).compareTo(int.parse(fd2.price)));
      } catch(_) {
        xrint ("error here - cheap_to_exp");
      }
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('exp_to_cheap')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      try {
        fd.sort((fd1, fd2) =>
            int.parse(fd2.price).compareTo(int.parse(fd1.price)));
      } catch(_) {
        xrint ("error here - exp_to_cheap");
      }
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('farest')}")) {
      // farest
      List<RestaurantFoodModel> fd = foodProposals;
      if (fd != null && fd.length > 0 && fd[0]?.restaurant_entity?.delivery_pricing != null)
        try {
          fd.sort((fd1, fd2) => int.parse(fd2.restaurant_entity?.delivery_pricing).compareTo(int.parse(fd1.restaurant_entity?.delivery_pricing)));
        } catch (_){
          xrint ("error here - farest");
        }
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('nearest')}")) {
      // nearest
      List<RestaurantFoodModel> fd = foodProposals;
      if (fd != null && fd.length > 0 && fd[0]?.restaurant_entity?.delivery_pricing != null)
        try {
          fd.sort((fd1, fd2) =>
              int.parse(fd1?.restaurant_entity?.delivery_pricing).compareTo(
                  int.parse(fd2?.restaurant_entity?.delivery_pricing)));
        } catch (_){
          xrint ("error here - nearest");
        }
      return fd;
    }

    return foodProposals;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void inflateRestaurants(List<RestaurantModel> restaurants) {
    setState(() {
      widget.restaurantList = restaurants;
      _setLastTimeRestaurantListRequestToNow();
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
    if (mounted)
      super.setState(fn);
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
    return ErrorPage(message:"${AppLocalizations.of(context).translate('system_error')}", onClickAction: (){
      widget.restaurantListPresenter.fetchRestaurantList(widget.customer, StateContainer.of(context).location);
    });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){
      widget.restaurantListPresenter.fetchRestaurantList(widget.customer, StateContainer.of(context).location);
    });
  }

  showCountDownButton() {
    return Container();
    // return nothing
    /*  return Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
      InkWell(onTap: ()=> {widget.restaurantListPresenter.fetchRestaurantList(widget.customer, StateContainer.of(context).location)/*widget.presenter.loadDailyOrders(widget.customer)*/},
        child: Container(
          width: 65,
          height: 35,
          decoration: BoxDecoration(
            color: KColors.primaryColorSemiTransparentADDTOBASKETBUTTON,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.refresh,
                  color: KColors.primaryColor,size: 20),
              // count down here
              Text("${last_update_timeout}".toUpperCase(), style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12))
            ],
          ),
        ),
      ),
      SizedBox(width: 10),
    ]); */
  }

  Timer mainTimer;



  void restartTimer() {
    if (mainTimer != null)
      mainTimer.cancel();
    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {

      xrint("restaurantlist this page is --> " + ModalRoute.of(context)?.settings?.name);
      xrint("restaurantlist is_current is --> ${ModalRoute.of(context)?.isCurrent}");

      if (ModalRoute.of(context)?.settings?.name == null || !("/HomePage".compareTo(ModalRoute.of(context)?.settings?.name) == 0 &&
          ModalRoute.of(context).isCurrent)) {
        // check if time is ok
        xrint("restaurantlist NO exec timer ");
        return;
      }
      xrint("restaurantlist exec timer ");

      setState(() {
        // last_update_timeout = getTimeOutLastTime(); // disabled
      });

      int POTENTIAL_EXECUTION_TIME = 3;
      int diff = (DateTime.now().millisecondsSinceEpoch - StateContainer.of(context).last_time_get_restaurant_list_timeout)~/1000;
      // convert different in minute seconds
      int min = (diff+ POTENTIAL_EXECUTION_TIME)~/60;

      if (min >= MAX_MINUTES_FOR_AUTO_RELOAD ||
          (widget.hasGps == false && (StateContainer
              .of(context)
              .location != null)))
        widget.restaurantListPresenter.fetchRestaurantList(
            widget.customer, StateContainer
            .of(context)
            .location, true);

      if (!widget.hasGps)
        widget.hasGps = (StateContainer.of(context).location != null);
    });
  }

  Future<int> _setLastTimeRestaurantListRequestToNow() async {
    StateContainer.of(context).last_time_get_restaurant_list_timeout = DateTime.now().millisecondsSinceEpoch;
  }

  getTimeOutLastTime() {
    if (StateContainer.of(context).last_time_get_restaurant_list_timeout == 0){
      return "";
    } else {
      // time different since last time update
      int diff = (DateTime.now().millisecondsSinceEpoch - StateContainer.of(context).last_time_get_restaurant_list_timeout)~/1000;
      // convert different in minute seconds
      int min = diff~/60;
      int sec = diff%60;
      return "${min < 10 ? "0": ""}${min}:${sec < 10 ? "0": ""}${sec}";
    }
  }
}
