import 'package:flutter/material.dart';

class ShopFilteredList extends StatelessWidget {
  // load data from outside and send it to this widget to show it
  var data;

  ShopFilteredList({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Filtered list"));
  }
}
