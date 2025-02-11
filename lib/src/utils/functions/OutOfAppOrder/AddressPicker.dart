import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/address_contract.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../ui/screens/home/me/address/MyAddressesPage.dart';
import '../CustomerUtils.dart';

Future _pickShippingAddress(BuildContext context,WidgetRef ref,GlobalKey poweredByKey) async {
  final locationState= ref.watch(locationStateProvider);
  final locationNotifier= ref.read(locationStateProvider.notifier);
  final productState = ref.watch(productListProvider);
  ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
  ref.read(outOfAppScreenStateProvier.notifier).setIsBillBuilt(false);

  /* jump and get it */
  if(context.mounted){
  Map results = await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          MyAddressesPage(pick: true, presenter: AddressPresenter()),
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
    locationNotifier.pickShippingAddress(results['selection']);
    locationNotifier.setShippingAddressPicked(true);
      /* update / refresh this page */
    CustomerUtils.getCustomer().then((customer) {
     ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
      // launch request for retrieving the delivery prices and so on.
      //get billing

      if(locationState.is_order_address_picked==true){
        OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();

        api.computeBillingAction(
            customer,
            locationState.selectedOrderAddress,
            productState,
            locationState.selectedShippingAddress,
            null,
            false);
      }
      else{

      }
     ref.read(outOfAppScreenStateProvier.notifier).setShowLoading(true);
      Future.delayed(Duration(seconds: 1), () {
        Scrollable.ensureVisible(poweredByKey.currentContext);
      });
    });
  }
  }
}
