import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:flutter/material.dart';

class BuyPage extends StatefulWidget {
  static var routeName = "/HomePage";

  var argument;

  var destination;

  CustomerModel customer;

  BuyPage({Key key, this.destination, this.argument}) : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

/* we show categories */

class _BuyPageState extends State<BuyPage> {
  @override
  Widget build(BuildContext context) {
    // load subdivisions from json or shared preferences,
    // and continue loading just in case there is some change...
    // apply the interesting loading of the other one
    return Scaffold(body: Center(child: MyLoadingProgressWidget()));
  }
}
