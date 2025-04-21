import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../localizations/AppLocalizations.dart';
import '../../utils/_static_data/KTheme.dart';

Widget ShowBilling(BuildContext context,OrderBillConfiguration _orderBillConfiguration){
  return Column(children: <Widget>[
    (_orderBillConfiguration.remise! > 0
        ? Container(
        height: 40.0,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
          /*
          *   image: new DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                    Utils.inflateLink(  NetworkImages.kaba_promotion_gif)
                )
            )*/
        )
    )
        : Container()),
    Container(),
    /* content */
    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text(
          "${AppLocalizations.of(context)!.translate('invoice_bill')}",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
    ]),
    SizedBox(height: 10),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('order_amount')}",
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 12)),
          /* check if there is promotion on Commande */
          Row(
            children: <Widget>[
              /* montant commande normal */
              Text(
                  _orderBillConfiguration.command_pricing! >
                      _orderBillConfiguration.promotion_pricing!
                      ? "(${_orderBillConfiguration?.command_pricing})"
                      : "",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 12)),
              SizedBox(width: 5),
              /* montant commande promotion */
              Text(
                  _orderBillConfiguration.command_pricing! >
                      _orderBillConfiguration.promotion_pricing!
                      ? "${_orderBillConfiguration?.promotion_pricing} ${AppLocalizations.of(context)!.translate('currency')}"
                      : "${_orderBillConfiguration?.command_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ]),
    SizedBox(height: 10),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('delivery_amount')}",
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 12)),
          /* check if there is promotion on Livraison */
          Row(
            children: <Widget>[
              /* montant livraison normal */
              Text(
                  _orderBillConfiguration.shipping_pricing! >
                      _orderBillConfiguration
                          .promotion_shipping_pricing!
                      ? "(${_orderBillConfiguration?.shipping_pricing})"
                      : "",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 12)),
              SizedBox(width: 5),
              /* montant livraison promotion */
              Text(
                  _orderBillConfiguration.shipping_pricing! >
                      _orderBillConfiguration
                          .promotion_shipping_pricing!
                      ? "${_orderBillConfiguration?.promotion_shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}"
                      : "${_orderBillConfiguration?.shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ]),
    SizedBox(height: 10),
    //additional_fees
    _orderBillConfiguration?.additional_fees_total_price!=0||_orderBillConfiguration?.additional_fees_total_price!=null?
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('additional_fees')}",
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 12)),
          /* check if there is promotion on Livraison */
          Row(
            children: <Widget>[
              /* montant livraison promotion */
              Text(
                  "${_orderBillConfiguration.additional_fees_total_price} ${AppLocalizations.of(context)!.translate('currency')}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),

            ],
          )
        ])
        :Container(),
    SizedBox(height: 10),
    Container(
      decoration:BoxDecoration(
          color:Color(0x54B6B6B6),
          borderRadius:BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            "${AppLocalizations.of(context)!.translate('additional_fees_description')}",
            style: TextStyle(

                fontSize: 12,
                color: Colors.black)),
      ),

    ),
    SizedBox(height: 10),
    _orderBillConfiguration.remise! > 0
        ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('discount')}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
          /* montrer le discount s'il y'a lieu */
          Text("-${_orderBillConfiguration?.remise}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: CommandStateColor.delivered)),
        ])
        : Container(),
    SizedBox(height: 10),
    Center(
        child: Container(
            width: MediaQuery.of(context).size.width - 10,
            color: Colors.grey.shade300,
            height: 1)),
    SizedBox(height: 10),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('net_price')}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          /* montant total a payer */
          Text(
              "${_orderBillConfiguration?.total_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: KColors.primaryColor,
                  fontSize: 14)),
        ]),
  ]);
}