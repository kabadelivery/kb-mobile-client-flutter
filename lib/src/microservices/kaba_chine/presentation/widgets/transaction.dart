import 'package:KABA/src/microservices/kaba_chine/functions/getStatusInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';

import '../../data/order/payment_model.dart';
Widget Transaction({required BuildContext context, required PaymentModel transaction}){
  Size size = MediaQuery.of(context).size;
  final info = getPaymentStatusInfo(context,"${transaction.paymentStatus}");

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
                "${AppLocalizations.of(context)!.translate('payment')}"+" ${transaction.id.toString().length>15?transaction.id.toString().substring(0,15)+"...":transaction.id}",
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
           Text("${transaction.amount} ${transaction.currency}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87))
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
                  color: transaction.paymentMethod=="FLOOZ"?Color(0xff064aa4)
                      :transaction.paymentMethod.toString()=="TMONEY"?Color(0xffffb700)
                      :KabaChineColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("${transaction.paymentMethod}",style: TextStyle(fontWeight: FontWeight.bold,
                  color: transaction.paymentMethod=="FLOOZ"?Colors.white:
                  transaction.paymentMethod.toString()=="TMONEY"?Color(
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
                Text("${AppLocalizations.of(context)!.translate('did_on')}")
              ],
            ),
            Text("${transaction.createdAt.toString().split(' ')[0]} à ${transaction.createdAt.toString().split(' ')[1].split('.')[0]}",style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black87))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.2),
                border: info.actionRequired==null?null: Border.all(
                  color: info.color,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text(info.text,
                      style: TextStyle(
                          color: info.color,
                          fontSize: 12,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            )
          ],
        ),
      ]
      ),
    ),
  );
}