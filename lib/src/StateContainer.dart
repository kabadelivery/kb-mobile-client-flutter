
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StateContainer extends StatefulWidget {

  final Widget child;
  int tabPosition;
  int balance;
  Position position;

  StateContainer({@required this.child, this.balance, this.tabPosition, this.position});

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
  Position location;

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


  @override
  Widget build(BuildContext context) {
    return InheritedStateContainer(
      data: this,
      child: widget.child,
    );
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
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}