import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


// ignore: must_be_immutable
class ErrorPage extends StatelessWidget {

  static const TYPE_NO_NETWORK = -20;
  static const TYPE_SYSTEM_BROKEN = -21;

  int type = TYPE_SYSTEM_BROKEN;

  var onClickAction;

  ErrorPage({
    Key key,
    this.type,
    this.onClickAction,
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: (
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /* text / image
                    * button */
                Text("Sorry, the network is having an issue."),
                SizedBox(height:10),
                MaterialButton(padding: EdgeInsets.only(top: 10,bottom: 10), child:Text("TRY AGAIN",
                    style: TextStyle(color: Colors.white)),
                    onPressed: onClickAction, color: KColors.primaryColor)
              ])
      ),
    );
  }



}