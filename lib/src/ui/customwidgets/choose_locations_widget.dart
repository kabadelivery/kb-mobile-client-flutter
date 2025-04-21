import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/order_billing_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../models/DeliveryAddressModel.dart';
import '../../models/OrderBillConfiguration.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/products_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/CustomerUtils.dart';
import '../../utils/functions/OutOfAppOrder/AddressPicker.dart';
import '../../utils/functions/Utils.dart';
import '../../xrint.dart';
Widget ChooseShippingAddress(
    BuildContext context,
    WidgetRef ref,
    int type,
    GlobalKey poweredByKey,
    int shipping_address_type,int order_type
    ){
  return     InkWell(
      splashColor: Colors.white,
      child: Container(

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
                    onPressed: (){},
                    child: Icon(Icons.location_on,
                        size: 28, color:type==1?
                        KColors.mBlue:
                        Colors.green
                    ),
                  ),
                ]),
                SizedBox(width: 10),
             Text( order_type==0?  
                    "${AppLocalizations.of(context)!.translate(type==1?'choose_address_where_to_deliver':'choose_order_address')}"
               
              :order_type==6?
                    "${AppLocalizations.of(context)!.translate(type==1?'choose_address_where_to_deliver':'choose_address_where_to_fetch')}"
                  
              :
                    "${AppLocalizations.of(context)!.translate(type==1?'choose_address_where_to_deliver_package':'choose_address_where_to_fetch')}",
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
      color: Colors.grey[200],
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(Utils.capitalize(selectedAddress.name!),
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
                            Utils.capitalize(selectedAddress.description!),
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
    final locationState= ref.watch(locationStateProvider);
  final locationNotifier= ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final productState = ref.watch(productListProvider);
  final voucherState= ref.watch(voucherStateProvider);
  if (selectedAddress == null)
    return Container();
  else
    return Container(
      color: Colors.grey[200],
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(Utils.capitalize(selectedAddress.name!),
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
                            Utils.capitalize(selectedAddress.description!),
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
                  onTap: () async{
                    /* remove address */
                    locationNotifier.deleteOrderAddress(selectedAddress,false);
                    locationNotifier.setOrderAddressPicked(false);
                    ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
                    ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);
                    ref.read(outOfAppScreenStateProvier.notifier).setShowLoading(false);

                  if (ref.read(outOfAppScreenStateProvier).order_type != 5 && ref.read(outOfAppScreenStateProvier).order_type != 6) {
                          if(locationState.is_shipping_address_picked!){
                            await CustomerUtils.getCustomer().then((customer) async {
                              ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
                              // launch request for retrieving the delivery prices and so on.
                              //get billing
                              OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                              outOfAppNotifier.setIsBillBuilt(false);
                              outOfAppNotifier.setShowLoading(true);
                              try{
                                List<Map<String, dynamic>> formData = [];

                                for (int i = 0; i < productState.length; i++) {
                                  formData.add(
                                      { 'name': productState[i]['name'],
                                        'price': productState[i]['price'].toString(),
                                        'quantity': productState[i]['quantity'].toString(),
                                        'image': ""
                                      }
                                  );
                                }
                                try  {
                                  OrderBillConfiguration orderBillConfiguration =
                                  await api.computeBillingAction(
                                      customer!,
                                      [],
                                      formData,
                                      locationState.selectedShippingAddress!,
                                      voucherState.selectedVoucher!,
                                      false);
                                  ref
                                      .read(orderBillingStateProvider.notifier)
                                      .setOrderBillConfiguration(
                                      orderBillConfiguration);
                                  outOfAppNotifier.setIsBillBuilt(true);
                                  outOfAppNotifier.setShowLoading(false);
                                }catch(e){
                                  Fluttertoast.showToast(
                                      backgroundColor: Colors.black87,
                                      textColor: Colors.white,
                                      fontSize: 14,
                                      toastLength: Toast.LENGTH_LONG ,
                                      msg: "🚨 "+AppLocalizations.of(context)!.translate("impossible_to_load_bill")+" 🚨");
                                  outOfAppNotifier.setShowLoading(false);
                                  outOfAppNotifier.setIsBillBuilt(false);
                                }
                                xrint("setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
                              }catch(e){
                                xrint("ENRRRRRR $e");
                              }


                            });
                          }
                  }
                  }))
        ],
      ),
    );
}
