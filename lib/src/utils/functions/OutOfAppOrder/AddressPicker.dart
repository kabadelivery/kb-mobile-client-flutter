import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../contracts/address_contract.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/DeliveryAddressModel.dart';
import '../../../models/OrderBillConfiguration.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/voucher_state.dart';
import '../../../ui/screens/home/me/address/MyAddressesPage.dart';
import '../CustomerUtils.dart';
import 'package:geolocator/geolocator.dart';

Future PickShippingAddress(BuildContext context,WidgetRef ref,GlobalKey poweredByKey,int address_type) async {
  final locationState= ref.watch(locationStateProvider);
  final locationNotifier= ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
  final productState = ref.watch(productListProvider);
  final voucherState= ref.watch(voucherStateProvider);
 // ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
//  ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);
  List<DeliveryAddressModel> order_address=null;
  DeliveryAddressModel shipping_address=null;
  /* jump and get it */
  if(context.mounted){
  Map results = await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          MyAddressesPage(pick: true, presenter: AddressPresenter(),address_type: address_type),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation =
        CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
            position: tween.animate(curvedAnimation), child: child);
      }));

  if (results != null && results.containsKey('selection')) {
    if(address_type==1){
      shipping_address = results['selection'];
      locationNotifier.pickShippingAddress(shipping_address);
      locationNotifier.setShippingAddressPicked(true);
      if(locationState.is_order_address_picked){
        order_address = locationState.selectedOrderAddress;
      }
    }else if(address_type==2){
      order_address = []; //change later for multiple address
      order_address.add(results['selection'] as DeliveryAddressModel);
      locationNotifier.pickOrderAddress(results['selection']);
       locationNotifier.setOrderAddressPicked(true);
      if(locationState.is_shipping_address_picked){
        shipping_address = locationState.selectedShippingAddress;
      }
    }

      /* update / refresh this page */
    await CustomerUtils.getCustomer().then((customer) async {
     ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
      // launch request for retrieving the delivery prices and so on.
      //get billing
        OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
         if (outOfAppScreenState.order_type == 5 || outOfAppScreenState.order_type == 6) {
            if (shipping_address!=null&&order_address.isNotEmpty)
            {
              outOfAppNotifier.setIsBillBuilt(false);
              outOfAppNotifier.setShowLoading(true);

              if(outOfAppScreenState.order_type==6){
                var product = {
                  "name": "Récupération de colis",
                  "price": 0,
                  "quantity": 1,
                  "image": ""
                };
                productState.clear();
                productState.add(product);
              }
           }

        }else{
          if(shipping_address!=null){
            outOfAppNotifier.setIsBillBuilt(false);
            outOfAppNotifier.setShowLoading(true);
          }
        }

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
          if (outOfAppScreenState.order_type == 5 || outOfAppScreenState.order_type == 6) {
            if (shipping_address!=null && order_address.isNotEmpty) {
             try{
               OrderBillConfiguration orderBillConfiguration = await api.computeBillingAction(
                   customer,
                   order_address,
                   formData,
                   shipping_address,
                   voucherState.selectedVoucher,
                   false);
               ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(orderBillConfiguration);
               outOfAppNotifier.setIsBillBuilt(true);
               outOfAppNotifier.setShowLoading(false);
             }catch(e){
               Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context).translate("impossible_to_load_bill")+" 🚨");
                outOfAppNotifier.setShowLoading(false);
                outOfAppNotifier.setIsBillBuilt(false);
             }
              print("setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
            }
          } else {

            if(shipping_address!=null){

           try{
             OrderBillConfiguration orderBillConfiguration = await api.computeBillingAction(
                 customer,
                 order_address,
                 formData,
                 shipping_address,
                 voucherState.selectedVoucher,
                 false);
             ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(orderBillConfiguration);
             outOfAppNotifier.setIsBillBuilt(true);
             outOfAppNotifier.setShowLoading(false);

           }catch(e){
             Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context).translate("impossible_to_load_bill")+" 🚨");
              outOfAppNotifier.setShowLoading(false);
              outOfAppNotifier.setIsBillBuilt(false);
           }
            print("setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
          }
        }
        }catch(e){
          print("ENRRRRRR $e");
        }


    });
  }
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}
