import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../contracts/vouchers_contract.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/OrderBillConfiguration.dart';
import '../../../models/VoucherModel.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/products_state.dart';
import '../../../ui/screens/home/me/vouchers/MyVouchersPage.dart';
import '../../../xrint.dart';
import '../CustomerUtils.dart';

Future<VoucherModel> SelectVoucher(BuildContext context, WidgetRef ref,
    bool has_voucher, VoucherModel voucher) async {
  /* just like we pick and address, we pick a voucher. */

  /* we go on the package list for vouchers, and we make a request to show those that are adapted for the foods
    * selected and the current restaurant.
    *
    * RESULT MAY BE:
    *
    * - result may be only vouchers,
    *
    * */

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
            restaurantId: -1,
            foods: [33]),
      ),
    );
  } else {
    results = new Map();
    results["voucher"] = voucher;
  }

  if (results != null && results.containsKey('voucher')) {
    return results['voucher'];
  }
}

Future<OrderBillConfiguration> getBillingForVoucher(
    BuildContext context, WidgetRef ref, VoucherModel voucher) async {
  final locationState = ref.watch(locationStateProvider);
  final voucherState = ref.watch(voucherStateProvider);
  final locationNotifier = ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final productState = ref.watch(productListProvider);
  try {
    ref.read(voucherStateProvider.notifier).setVoucher(voucher);
    CustomerModel customer = ref.watch(orderBillingStateProvider).customer;
    ref.read(orderBillingStateProvider.notifier).setCustomer(customer);
    List<Map<String, dynamic>> formData = [];

    for (int i = 0; i < productState.length; i++) {
      formData.add({
        'name': productState[i]['name'],
        'price': productState[i]['price'].toString(),
        'quantity': productState[i]['quantity'].toString(),
        'image': ""
      });
    }

    OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
    outOfAppNotifier.setIsBillBuilt(false);
    outOfAppNotifier.setShowLoading(true);

    try {
      OrderBillConfiguration orderBillConfiguration =
          await api.computeBillingAction(
              customer,
              locationState.selectedOrderAddress,
              formData,
              locationState.selectedShippingAddress,
              voucher,
              false);
      return orderBillConfiguration;
    } catch (e) {
      Fluttertoast.showToast(
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 14,
          toastLength: Toast.LENGTH_LONG,
          msg: "🚨 " +
              AppLocalizations.of(context)
                  .translate("impossible_to_load_bill") +
              " 🚨");
      outOfAppNotifier.setShowLoading(false);
      outOfAppNotifier.setIsBillBuilt(false);
      return null;
    }
  } catch (e) {
    xrint("ERROR : $e");
    return null;
  }
}
