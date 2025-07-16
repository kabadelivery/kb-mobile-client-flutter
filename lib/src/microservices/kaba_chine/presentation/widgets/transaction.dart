import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
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
            color: KabaChineColors.border.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [

              SizedBox(
                width: 10,
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('payment')}"+" ${transaction["id"].toString().length>15?transaction["id"].toString().substring(0,15)+"...":transaction["id"]}",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.moneyBill,color: Colors.black54,size: 16),
                SizedBox(width: 5),
                Text("${AppLocalizations.of(context)!.translate('amount')}",)
              ],
            ),
           Text("${transaction["amount"]} ${transaction['currency']}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.moneyBillTransfer,color: Colors.black54,size: 16),
                SizedBox(width: 5),
                Text("${AppLocalizations.of(context)!.translate('transfer_by')}",)
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                decoration: BoxDecoration(
                  color: transaction['type_of_transaction']=="FLOOZ"?Color(0xff064aa4)
                      :transaction['type_of_transaction'].toString()=="MIXX BY YAS"?Color(0xffffb700)
                      :KabaChineColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("${transaction["type_of_transaction"]}",style: TextStyle(fontWeight: FontWeight.bold,
                  color: transaction['type_of_transaction']=="FLOOZ"?Colors.white:
                  transaction['type_of_transaction'].toString()=="MIXX BY YAS"?Color(
                      0xff063e88)
                    :KabaChineColors.primary,
                )))
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.calendar,color: Colors.black54,size: 16),
                SizedBox(width: 5),
                Text("Fais le",)
              ],
            ),
            Text("${transaction['created_date'].toString().split(' ')[0]} à ${transaction['created_date'].toString().split(' ')[1].split('.')[0]}",style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black87))
          ],
        ),
      ]
      ),
    ),
  );
}