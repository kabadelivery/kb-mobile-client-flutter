import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/vouchers_contract.dart';
import '../../../models/OrderBillConfiguration.dart';
import '../../../models/VoucherModel.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/products_state.dart';
import '../../../ui/screens/home/me/vouchers/MyVouchersPage.dart';
import '../CustomerUtils.dart';

void SelectVoucher(BuildContext context,WidgetRef ref,bool has_voucher, VoucherModel voucher) async {
  /* just like we pick and address, we pick a voucher. */

  /* we go on the package list for vouchers, and we make a request to show those that are adapted for the foods
    * selected and the current restaurant.
    *
    * RESULT MAY BE:
    *
    * - result may be only vouchers,
    *
    * */
  final locationState= ref.watch(locationStateProvider);
  final voucherState= ref.watch(voucherStateProvider);
  final locationNotifier= ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final productState = ref.watch(productListProvider);
  Map results;
  if (!has_voucher) {
   ref.read(voucherStateProvider.notifier).setVoucher(null);
    /* jump and get it */
    results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyVouchersPage(
            pick: true,
            presenter: VoucherPresenter(),
            restaurantId:null,
            foods: null
        ),
      ),
    );
  } else {
    results = new Map();
    results["voucher"] = voucher;
  }

  if (results != null && results.containsKey('voucher')) {
      ref.read(voucherStateProvider.notifier).setVoucher(results['voucher']);

    if (locationState.selectedShippingAddress!= null) {

      CustomerUtils.getCustomer().then((customer)async {

        ref.read(orderBillingStateProvider.notifier).setCustomer(customer);


        OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
        outOfAppNotifier.setIsBillBuilt(false);
        outOfAppNotifier.setShowLoading(true);
        try{
          OrderBillConfiguration orderBillConfiguration= await api.computeBillingAction(
              customer,
              locationState.selectedOrderAddress,
              productState,
              locationState.selectedShippingAddress,
              voucherState.selectedVoucher,
              false);
          ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(orderBillConfiguration);
          outOfAppNotifier.setIsBillBuilt(true);
          outOfAppNotifier.setShowLoading(false);
          print("setIsBillBuilt ${ref.watch(outOfAppScreenStateProvier).isBillBuilt}");
        }catch(e){
          print("ENRRRRRR $e");
        }

      });
    }
  }
}
