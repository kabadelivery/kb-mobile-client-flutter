import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/order_billing_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localizations/AppLocalizations.dart';
import '../../models/DeliveryAddressModel.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/OutOfAppOrder/AddressPicker.dart';
import '../../utils/functions/Utils.dart';
import 'BouncingWidget.dart';

Widget ChooseShippingAddress(
    BuildContext context,
    WidgetRef ref,
    int type,
    GlobalKey poweredByKey,
    int shipping_address_type
    ){
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
      onTap: () async{
       await PickShippingAddress(context,ref,poweredByKey,shipping_address_type);
      });
}

Widget  BuildShippingAddress(BuildContext context,WidgetRef ref,DeliveryAddressModel selectedAddress) {
  if (selectedAddress == null)
    return Container();
  else
    return Container(
      color: KColors.new_gray,
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(Utils.capitalize(selectedAddress.name),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: KColors.new_black,
                            fontSize: 14))),
                SizedBox(height: 5),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Text(
                            Utils.capitalize(selectedAddress.description),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style:
                            TextStyle(fontSize: 12, color: Colors.grey))),
                  ]),
                )
              ]),
          Positioned(
              top: 5,
              right: 0,
              child: InkWell(
                  child: Container(
                      child: Icon(Icons.delete_forever,
                          size: 20, color: KColors.primaryColor),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      padding: EdgeInsets.all(8)),
                  onTap: () {
                    /* remove address */
                    ref.read(locationStateProvider.notifier).pickShippingAddress(null);
                    ref.read(locationStateProvider.notifier).setShippingAddressPicked(false);
                    ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
                    ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);
                    ref.read(outOfAppScreenStateProvier.notifier).setShowLoading(false);
                  }))
        ],
      ),
    );
}
Widget  BuildOrderAddress(BuildContext context,WidgetRef ref,DeliveryAddressModel selectedAddress) {
  if (selectedAddress == null)
    return Container();
  else
    return Container(
      color: KColors.new_gray,
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(Utils.capitalize(selectedAddress.name),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: KColors.new_black,
                            fontSize: 14))),
                SizedBox(height: 5),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Text(
                            Utils.capitalize(selectedAddress.description),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style:
                            TextStyle(fontSize: 12, color: Colors.grey))),
                  ]),
                )
              ]),
          Positioned(
              top: 5,
              right: 0,
              child: InkWell(
                  child: Container(
                      child: Icon(Icons.delete_forever,
                          size: 20, color: KColors.primaryColor),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      padding: EdgeInsets.all(8)),
                  onTap: () {
                    /* remove address */
                    ref.read(locationStateProvider.notifier).deleteOrderAddress(selectedAddress,false);
                    ref.read(locationStateProvider.notifier).setOrderAddressPicked(false);
                    ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
                    ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);
                    ref.read(outOfAppScreenStateProvier.notifier).setShowLoading(false);
                  }))
        ],
      ),
    );
}
