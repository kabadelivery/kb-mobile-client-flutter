import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_state.dart';
import 'order_billing_state.dart';
import 'out_of_app_order_screen_state.dart';

resetAll(WidgetRef ref) {
  // Location state resets
  final locationNotifier = ref.read(locationStateProvider.notifier);
  locationNotifier.setShippingAddressPicked(false);
  locationNotifier.setOrderAddressPicked(false);
  locationNotifier.pickShippingAddress(null);
  locationNotifier.deleteOrderAddress(null, false);

  // Order billing resets
  final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
  orderBillingNotifier.setOrderBillConfiguration(null);
  orderBillingNotifier.setCustomer(null);

  // Screen state resets
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  outOfAppNotifier.setShowLoading(false);
  outOfAppNotifier.setIsBillBuilt(false);
  outOfAppNotifier.setIsPayAtDeliveryLoading(false);
  outOfAppNotifier.setOrderType(0);

  // Products reset
  final productNotifier = ref.read(productListProvider.notifier);
  productNotifier.clearProducts();

  // Voucher resets
  final voucherNotifier = ref.read(voucherStateProvider.notifier);
  voucherNotifier.setVoucher(null);
  voucherNotifier.setOldVoucher(null);
  voucherNotifier.setUsePoint(false);
} 