import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../localizations/AppLocalizations.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/_static_data/Vectors.dart';
void showOutOfRangePopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Text(
                  AppLocalizations.of(context)!
                      .translate('out_of_delivery_range'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 120,
                child: SvgPicture.asset(
                  VectorsData.out_of_range,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          ),
        ),
      );
    },
  );
}

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
    Row(mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: KColors.primaryColor,
          borderRadius: BorderRadius.circular(10),

        ),
        child: const Icon(
          Icons.receipt_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
      SizedBox(width: 10),
      Text(
          "${AppLocalizations.of(context)!.translate('invoice_bill')}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
    ]),
    SizedBox(height: 10),
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
              "${AppLocalizations.of(context)!.translate('order_amount')}",
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 14)),
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
                      fontWeight: FontWeight.bold, fontSize: 14)),
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
                  fontWeight: FontWeight.normal, fontSize: 14)),
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
                      fontSize: 14)),
              SizedBox(width: 5),
              /* montant livraison promotion */
              Text(
                  _orderBillConfiguration.shipping_pricing! >
                      _orderBillConfiguration
                          .promotion_shipping_pricing!
                      ? "${_orderBillConfiguration?.promotion_shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}"
                      : "${_orderBillConfiguration?.shipping_pricing} ${AppLocalizations.of(context)!.translate('currency')}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
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
                      fontWeight: FontWeight.bold, fontSize: 14)),

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

                fontSize: 14,
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