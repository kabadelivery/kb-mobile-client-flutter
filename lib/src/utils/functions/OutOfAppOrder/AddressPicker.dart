import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../contracts/address_contract.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/CustomerModel.dart';
import '../../../models/DeliveryAddressModel.dart';
import '../../../models/OrderBillConfiguration.dart';
import '../../../resources/address_api_provider.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/voucher_state.dart';
import '../../../ui/customwidgets/billing_widget.dart';
import '../../../ui/screens/home/me/address/MyAddressesPage.dart';
import '../../../xrint.dart';
import '../../_static_data/AppConfig.dart';
import '../../recustomlib/place_picker_removed_nearbyplaces.dart';
import '../CustomerUtils.dart';
import 'package:geolocator/geolocator.dart';

import '../google_map_name.dart';

Future PickShippingAddress(BuildContext context, WidgetRef ref,
    GlobalKey poweredByKey, int address_type,bool is_actual_position) async {
  final locationState = ref.watch(locationStateProvider);
  final locationNotifier = ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
  final productState = ref.watch(productListProvider);
  final voucherState = ref.watch(voucherStateProvider);
  // ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
//  ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);
  List<DeliveryAddressModel> order_address = [];
  DeliveryAddressModel? shipping_address =null;
  /* jump and get it */
  if (context.mounted) {
    CustomerModel? customer = await CustomerUtils.getCustomer();
    Widget page = Container();
    if(is_actual_position){
      page =  MyAddressesPage(
          pick: true,
          presenter: AddressPresenter(AddressView()),
          address_type: 5 //address_type = 5 means  we only choose actual position
      );
    }
    else if(!is_actual_position && address_type==2){
      page =PlacePicker(AppConfig.GOOGLE_MAP_API_KEY,alreadyHasLocation: true,);
    }else{
     page = MyAddressesPage(
        pick: true,
        address_type: address_type,
        presenter: AddressPresenter(AddressView()),
      );
    }
    var results = await  Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        page,
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
    if(address_type==2 && !is_actual_position && results!=null){
      AddressApiProvider address_api = AddressApiProvider();
      String addresse_name = await getPlaceNameFromCoords(
          results.latitude,
          results.longitude
      );
       DeliveryAddressModel address = DeliveryAddressModel(
        name: addresse_name,
        location: "${"${results.latitude}:${results.longitude}"}",
        phone_number:customer.phone_number,
        description: "achat de produit",
         near: "addresse_name",
         user_id: customer.id.toString(),
         quartier:"addresse_name"
      );
      Map? addressRes = await address_api.updateOrCreateAddress(address, customer) as Map;
      order_address = [];
      order_address.add(addressRes!['address'] as DeliveryAddressModel);
      locationNotifier.pickOrderAddress(addressRes!['address']);
      locationNotifier.setOrderAddressPicked(true);
      if (locationState.is_shipping_address_picked!) {
        shipping_address = locationState.selectedShippingAddress!;
      }
     }else
    if (results != null && results.containsKey('selection')) {
      CherryToast.success(
        title: Text("Adresse de livraison choisi"),
      ).show(context);
      if (address_type == 1) {
        shipping_address = results['selection'];
        locationNotifier.pickShippingAddress(shipping_address);
        locationNotifier.setShippingAddressPicked(true);
        if (locationState.selectedOrderAddress!.isNotEmpty) {
          order_address = locationState.selectedOrderAddress!;
        }
      }
      if (address_type == 2) {
        order_address = []; //change later for multiple address
        order_address.add(results['selection'] as DeliveryAddressModel);
        locationNotifier.pickOrderAddress(results['selection']);
        locationNotifier.setOrderAddressPicked(true);
        if (locationState.is_shipping_address_picked!) {
          shipping_address = locationState.selectedShippingAddress!;
        }
      }

      /* update / refresh this page */
      await CustomerUtils.getCustomer().then((customer) async {
        ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
        // launch request for retrieving the delivery prices and so on.
        //get billing
        OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
        if (outOfAppScreenState.order_type == 5 ||
            outOfAppScreenState.order_type == 6) {
          if (shipping_address != null && order_address!=[]) {
            outOfAppNotifier.setIsBillBuilt(false);
            outOfAppNotifier.setShowLoading(true);

            if (outOfAppScreenState.order_type == 6) {
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
        } else {
          if (shipping_address != null) {
            outOfAppNotifier.setIsBillBuilt(false);
            outOfAppNotifier.setShowLoading(true);
          }
        }

        try {
          List<Map<String, dynamic>> formData = [];

          for (int i = 0; i < productState.length; i++) {
            formData.add({
              'name': productState[i]['name'],
              'price': productState[i]['price'].toString(),
              'quantity': productState[i]['quantity'].toString(),
              'image': ""
            });
          }
          if (outOfAppScreenState.order_type == 5 ||
              outOfAppScreenState.order_type == 6) {
            if (shipping_address != null && order_address.isNotEmpty) {
              try {
                OrderBillConfiguration orderBillConfiguration =
                    await api.computeBillingAction(
                        customer,
                        order_address,
                        formData,
                        shipping_address,
                        voucherState.selectedVoucher,
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
              } catch (e) {
                Fluttertoast.showToast(
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 14,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "🚨 " +
                        AppLocalizations.of(context)
                            !.translate("impossible_to_load_bill") +
                        " 🚨");
                outOfAppNotifier.setShowLoading(false);
                outOfAppNotifier.setIsBillBuilt(false);
                xrint("ERROR 2 impossible_to_load_bill $e");
              }
              xrint(
                  "setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
            }
          } else {
            if (shipping_address != null) {
              try {
                OrderBillConfiguration orderBillConfiguration =
                    await api.computeBillingAction(
                        customer,
                        order_address,
                        formData,
                        shipping_address,
                        voucherState.selectedVoucher,
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
              } catch (e) {
                xrint("ERROR 1 impossible_to_load_bill $e");
                Fluttertoast.showToast(
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 14,
                    toastLength: Toast.LENGTH_LONG,
                    msg: "🚨 " +
                        AppLocalizations.of(context)
                            !.translate("impossible_to_load_bill") +
                        " 🚨");
                outOfAppNotifier.setShowLoading(false);
                outOfAppNotifier.setIsBillBuilt(false);
              }
              xrint("setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
            }
          }
        } catch (e) {
          xrint("ERROR 3 impossible_to_load_bill $e");
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
