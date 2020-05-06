import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


// ignore: must_be_immutable
class MessagePage extends StatelessWidget {

  String message;

  MessagePage({
    Key key, this.message
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: (Column(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(message)])
      ),
    );
  }



}