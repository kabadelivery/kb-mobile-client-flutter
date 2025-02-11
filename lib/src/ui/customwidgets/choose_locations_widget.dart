import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../localizations/AppLocalizations.dart';
import '../../utils/_static_data/KTheme.dart';
import 'BouncingWidget.dart';

Widget ChooseShippingAddress(BuildContext context,int type){
  return     InkWell(
      splashColor: Colors.white,
      child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius:
              BorderRadius.all(Radius.circular(5)),
              color: type==1?
              KColors.mBlue.withAlpha(30):
              Colors.green.withAlpha(60)
          ),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  BouncingWidget(
                    duration: Duration(milliseconds: 400),
                    scaleFactor: 2,
                    child: Icon(Icons.location_on,
                        size: 28, color:type==1?
                        KColors.mBlue:
                        Colors.green
                    ),
                  ),
                ]),
                SizedBox(width: 10),
                Text(
                    "${AppLocalizations.of(context).translate(type==1?'choose_delivery_address':'choose_order_address')}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color:type==1?
                        KColors.mBlue:
                        Colors.green
                    ))
              ])),
      onTap: () {
     //   _pickDeliveryAddress();
      });
}