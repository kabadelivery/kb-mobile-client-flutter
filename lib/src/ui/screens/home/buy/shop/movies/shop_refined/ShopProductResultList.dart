import 'package:flutter/material.dart';

class ShopProductResultList extends StatelessWidget {
  // load data from outside and send it to this widget to show it
  var data;

  ShopProductResultList({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Product result list"));
  }

}
