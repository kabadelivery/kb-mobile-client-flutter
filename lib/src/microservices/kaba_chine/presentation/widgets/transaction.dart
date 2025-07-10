import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';

Widget Transaction({required BuildContext context, required Map<String,dynamic> transaction}){
  Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5.0,
          spreadRadius: 1.0,
          offset: Offset(0, 2), // changes position of shadow
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Container(
          width: size.width,
          height: 40,
          decoration: BoxDecoration(
            color: KabaChineColors.info.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Icon(
                FontAwesomeIcons.exchange,
                color:  KabaChineColors.info,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Paiement ${transaction["id"].toString().length>15?transaction["id"].toString().substring(0,15)+"...":transaction["id"]}",
                style: TextStyle(
                  color: KabaChineColors.info,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ]
      ),
    ),
  );
}