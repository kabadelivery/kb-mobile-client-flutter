
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StateContainer extends StatefulWidget {

  final Widget child;
  int tabPosition;
  int balance;
  String kabaPoints;
  bool isBalanceLoading = false;
  bool hasUnreadMessage;
  bool hasGotNewMessageOnce;
  Position position;

  StateContainer({@required this.child, this.balance, this.hasGotNewMessageOnce, this.kabaPoints, this.hasUnreadMessage, this.tabPosition, this.position, this.isBalanceLoading = false});

  static StateContainerState of(BuildContext context) {
//    return (context.dependOnInheritedWidgetOfExactType<InheritedStateContainer>()).data;
    return (context.inheritFromWidgetOfExactType(InheritedStateContainer)
    as InheritedStateContainer)
        .data;
  }

  @override
  StateContainerState createState() => new StateContainerState();
}

class StateContainerState extends State<StateContainer> {

  int tabPosition;
  int balance;
  String kabaPoints;
  bool isBalanceLoading = false;
  Position location;
  bool hasUnreadMessage;
  bool hasGotNewMessageOnce;

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

  Future<void> updateBalanceLoadingState({isBalanceLoading}) async {
    if (isBalanceLoading != null) {
      setState(() {
        this.isBalanceLoading = isBalanceLoading;
      });
    }
  }

  Future<void> updateUnreadMessage({hasUnreadMessage}) async {
    if (hasUnreadMessage != null) {
      setState(() {
        this.hasUnreadMessage = hasUnreadMessage;
      });
      /* save it to shared preferences */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('hasUnreadMessage', hasUnreadMessage);
    } else {
      setState(() {
        this.hasUnreadMessage = false;
      });
      /* save it to shared preferences */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('hasUnreadMessage', false);
    }
  }

  Future<void> updateHasGotNewMessage({hasGotNewMessage}) async {
    if (hasGotNewMessage == true) {
        this.hasGotNewMessageOnce = true;
      /* save it to shared preferences */
    } else {
        this.hasGotNewMessageOnce = false;
    }
  }

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
    if (this.tabPosition == null)
      this.tabPosition = 0;
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

  Future<void> updateKabaPoints({String kabaPoints}) async {

    if (kabaPoints != null) {
      setState(() {
        this.kabaPoints = kabaPoints;
      });
      /* save it to shared preferences */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('kabaPoints', kabaPoints);
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
    data.hasGotNewMessageOnce = false;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}