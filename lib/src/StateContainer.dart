import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateContainer extends StatefulWidget {
  final Widget child;
  int last_time_get_daily_order = 0;
  int last_time_get_restaurant_list_timeout = 0;
  int tabPosition;
  CustomerModel customer;
  int balance;
  int loggingState;
  String kabaPoints;
  bool isBalanceLoading = false;
  bool hasUnreadMessage;
  bool hasAskedLocation = false;
  bool hasGotNewMessageOnce;
  Position position;
  static const double ANDROID_APP_SIZE = 50;

  StateContainer(
      {@required this.child,
      this.balance,
      this.loggingState,
      this.hasGotNewMessageOnce,
      this.kabaPoints,
        this.customer,
      this.hasAskedLocation,
      this.hasUnreadMessage,
      this.tabPosition,
      this.position,
      this.isBalanceLoading = false,
      this.last_time_get_daily_order});

  static BuildContext mContext;

  static StateContainerState of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedStateContainer>();
    return widget.data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}

class StateContainerState extends State<StateContainer> {
  int last_time_get_daily_order = 0;
  int last_time_get_restaurant_list_timeout = 0;
  int tabPosition = 0;
  int balance;
  int loggingState;
  CustomerModel customer;
  // String kabaPoints;
  bool isBalanceLoading = false;
  Position location;
  Placemark placemark;
  // DeliveryAddressModel selectedAddress;
  bool hasUnreadMessage = false;
  bool hasAskedLocation = false;

  // firebase
  FirebaseAnalytics analytics;
  FirebaseAnalyticsObserver observer;
  Map service_message = {"message": "", "show": 0};

  int lastLocationPickingDate = 0;
  int lastTimeLinkMatchAction = 0;

  Map<String, String> myBillingArray = null;

  bool is_offline = false;

  bool location_asked = false;

  Future<void> updateBalance({balance}) async {
    if (balance != null) {
      setState(() {
        this.balance = balance;
      });
      /* save it to shared preferences */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('balance', balance);
    }
  }

  Future<void> updateAnalytics({analytics}) async {
    if (analytics != null) {
      setState(() {
        this.analytics = analytics;
      });
    }
  }

  Future<void> updateLoggingState({state}) async {
    if (state != null) {
      setState(() {
        this.loggingState = state;
      });
      /* save it to shared preferences */
    }
  }

  Future<void> updateBalanceLoadingState({isBalanceLoading}) async {
    if (isBalanceLoading != null) {
      setState(() {
        this.isBalanceLoading = isBalanceLoading;
      });
    }
  }

/*  Future<void> updateUnreadMessage({hasUnreadMessage}) async {
    this.hasUnreadMessage = hasUnreadMessage;
    // if (hasUnreadMessage != null) {
    //   setState(() {
    //     this.hasUnreadMessage = hasUnreadMessage;
    //   });
    //   /* save it to shared preferences */
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setBool('hasUnreadMessage', hasUnreadMessage);
    // } else {
    //   setState(() {
    //     this.hasUnreadMessage = false;
    //   });
    //   /* save it to shared preferences */
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setBool('hasUnreadMessage', false);
    // }
  }*/



  Future<void> updateLocation({location}) async {
    if (location != null) {
      setState(() {
        this.location = location;
      });
      /* save it to shared preferences */
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      prefs.setInt('position', position);
    }
  }

  Future<void> updateTabPosition({tabPosition}) async {
    if (tabPosition != null) {
      setState(() {
        this.tabPosition = tabPosition;
      });
      /* save it to shared preferences */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('tabPosition', tabPosition);
    }
  }

  Future<void> retrieveBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.balance = prefs.getInt('balance');
    if (this.tabPosition == null) this.tabPosition = 0;
  }

  Future<void> retrieveUnreadMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.hasUnreadMessage == true && prefs.getBool('hasUnreadMessage');
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

/* Future<void> updateKabaPoints({String kabaPoints}) async {

    if (kabaPoints != null) {
      setState(() {
        this.kabaPoints = kabaPoints;
      });
      */ /* save it to shared preferences */ /*
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('kabaPoints', kabaPoints);
    }
  }*/

  Future<void> updateObserver({FirebaseAnalyticsObserver observer}) {
    if (observer != null) {
      setState(() {
        this.observer = observer;
      });
    }
  }
}

class InheritedStateContainer extends InheritedWidget {
  final StateContainerState data;

  InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child) {
    data.retrieveBalance();
    data.retrieveUnreadMessage();
   /* data.hasUnreadMessage = false;*/
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
