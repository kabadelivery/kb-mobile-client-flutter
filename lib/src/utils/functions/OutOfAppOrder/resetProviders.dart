
import 'package:KABA/src/state_management/out_of_app_order/district_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/products_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/voucher_state.dart';
import '../../../state_management/out_of_app_order/additionnal_info_state.dart';

void resetProviders(WidgetRef ref){
  ref.invalidate(productListProvider);
  ref.invalidate(locationStateProvider);
  ref.invalidate(orderBillingStateProvider);
  ref.invalidate(voucherStateProvider);
  ref.invalidate(additionnalInfoProvider);
  ref.invalidate(outOfAppScreenStateProvier);
  ref.invalidate(districtProvider);
}

