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
import '../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../state_management/out_of_app_order/products_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/CustomerUtils.dart';
import '../../utils/functions/OutOfAppOrder/AddressPicker.dart';
import '../../utils/functions/Utils.dart';
import '../../xrint.dart';
import 'additionnal_info_widget.dart';
import 'billing_widget.dart';
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
              border: Border.all(
                  color: type==1?
                  KColors.mBlue.withAlpha(30):
                  Colors.green.withAlpha(60),
                  width: 1),
              borderRadius:
              BorderRadius.all(Radius.circular(15)),
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
       await PickShippingAddress(context,ref,poweredByKey,shipping_address_type,false);
      });
}
//ConsumerState<OutOfAppOrderPage>
Widget PurchaseAddress(BuildContext context,
    WidgetRef ref,
    int type,
    GlobalKey poweredByKey,
    int shipping_address_type,int order_type)
{
  final locationState = ref.watch(locationStateProvider);
  final locationNotifier = ref.read(locationStateProvider.notifier);
  final additionnalInfoState = ref.watch(additionnalInfoProvider);
  return Container(
    width: 350,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: .5),
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 18,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header row: icon + texts + switch
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .translate('purchase_address'), // "Adresse d'achat"
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('select_gps_address'), // "Sélectionner une adresse GPS"
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.05,
              child: Switch(
                value: locationState.selectedOrderAddress!.isNotEmpty,
                onChanged: (v) async {
                  if (v == true) {
                    await PickShippingAddress(
                        context, ref, poweredByKey, shipping_address_type, false);
                    locationState.is_order_address_picked!;
                  } else {
                    locationNotifier.pickOrderAddress(null);
                    locationState.is_order_address_picked = false;
                  }
                },
                activeColor: Colors.white,
                activeTrackColor: KColors.primaryColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),

        locationState.selectedOrderAddress!.isNotEmpty
            ? Column(
          children: [
            const SizedBox(height: 18),
            BuildOrderAddress(context, ref, locationState.selectedOrderAddress!.last),
          ],
        )
            : Container(),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context)!
              .translate('enter_address_manually'), // "Saisir l'adresse manuellement"
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        AdditionnalInfo(context, ref, 2, additionnalInfoState.additionnal_address_info),
      ],
    ),
  );

}
Widget ShippingAddress(BuildContext context,
    WidgetRef ref,
    int type,
    GlobalKey poweredByKey,
    int shipping_address_type,int order_type)
{
  final locationState = ref.watch(locationStateProvider);
  bool isLocationPicked=  false;
  try{
    isLocationPicked=(locationState.selectedShippingAddress!.name=="Choose your actual position"||
        locationState.selectedShippingAddress!.name=="Choisir votre position actuelle"||
        locationState.selectedShippingAddress!.name=="选择实际位置");
  }catch(e){
    isLocationPicked=false;
  }
  return Container(
    width: 350,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 18,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header row: icon + texts
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .translate('delivery_address'), // "Adresse de livraison"
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('delivery_address_subtitle'), // "L'endroit où le colis doit être livré"
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              onPressed: () async {
                await PickShippingAddress(
                    context, ref, poweredByKey, shipping_address_type, true);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: KColors.primaryColor, width: .5)),
              color: isLocationPicked ? KColors.primaryColor : Colors.white,
              elevation: 0,
              padding: EdgeInsets.all(4),
              minWidth: 100,
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                      color: isLocationPicked ? Colors.white : KColors.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('current_position'), // "Position actuelle"
                    style: TextStyle(
                        color: isLocationPicked ? Colors.white : KColors.primaryColor,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            MaterialButton(
              onPressed: () async {
                await PickShippingAddress(
                    context, ref, poweredByKey, shipping_address_type, false);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: KColors.primaryColor, width: .5),
              ),
              color: locationState.selectedShippingAddress != null && !isLocationPicked
                  ? KColors.primaryColor
                  : Colors.white,
              elevation: 0,
              padding: EdgeInsets.all(4),
              minWidth: 100,
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: locationState.selectedShippingAddress != null && !isLocationPicked
                        ? Colors.white
                        : KColors.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('saved_addresses'), // "Adresse enregistrées"
                    style: TextStyle(
                        color: locationState.selectedShippingAddress != null && !isLocationPicked
                            ? Colors.white
                            : KColors.primaryColor,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        locationState.is_shipping_address_picked != null &&
            locationState.selectedShippingAddress != null &&
            !isLocationPicked
            ? Column(
          children: [
            const SizedBox(height: 18),
            BuildShippingAddress(
                context, ref, locationState.selectedShippingAddress!)
          ],
        )
            : Container(),
      ],
    ),
  );

}


Widget  BuildShippingAddress(BuildContext context,WidgetRef ref,DeliveryAddressModel selectedAddress) {
  final locationState= ref.watch(locationStateProvider);
  final locationNotifier= ref.read(locationStateProvider.notifier);

  if (selectedAddress == null)
    return Container();
  else
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
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
              top: 0,
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
                    locationState.is_shipping_address_picked=(null);
                    locationState.selectedShippingAddress=(null);
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
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
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
              top: 0,
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
                                  if(orderBillConfiguration.shipping_pricing==0){
                                    showOutOfRangePopup(context);
                                    outOfAppNotifier.setIsBillBuilt(false);
                                    outOfAppNotifier.setShowLoading(false);
                                  }else{
                                    ref.read(orderBillingStateProvider.notifier)
                                        .setOrderBillConfiguration(orderBillConfiguration);
                                    outOfAppNotifier.setIsBillBuilt(true);
                                    outOfAppNotifier.setShowLoading(false);
                                  }
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
