import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../models/OrderBillConfiguration.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/district_state.dart';
import '../../state_management/out_of_app_order/location_state.dart';
import '../../state_management/out_of_app_order/order_billing_state.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/functions/CustomerUtils.dart';

class DistrictSelectionWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtState = ref.watch(districtProvider);
    final districtNotifier = ref.read(districtProvider.notifier);
    final locationState = ref.watch(locationStateProvider);
    final locationNotifier = ref.read(locationStateProvider.notifier);
    final outofAppState = ref.watch(outOfAppScreenStateProvier);
    final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    final voucherState = ref.watch(voucherStateProvider);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
    print("DistrictSelection : ${districtState.selectedDistrict??"empty"}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: districtNotifier.filterDistricts,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.translate("search_district"),
            fillColor: Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none
            ),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 16),
        districtState.isLoading
            ? Center(child: CircularProgressIndicator())
            : DropdownButton<String>(
          isExpanded: true,
          hint: Text(districtState.SelectedDistrictName.isEmpty
              ? "Select District"
              : districtState.SelectedDistrictName),
          value: districtState.SelectedDistrictName.isNotEmpty
              ? districtState.SelectedDistrictName
              : null,
          items: districtState.districts!.map((item) {
            return DropdownMenuItem<String>(
              value: item["name"],
              child: Text(item["name"]),
            );
          }).toList(),
          onChanged: (value)async  {
            districtNotifier.setSelectedDistrictName(value ?? "");
            Map<String, dynamic> selectedDistrict = districtState.districts!.firstWhere((element) => element["name"] == value);
            districtNotifier.setSelectedDistrict(selectedDistrict);
            List<Map<String, dynamic>> formData = [];
            DeliveryAddressModel  address=   DeliveryAddressModel(
              id: selectedDistrict["address_id"],
              name: selectedDistrict["name"],
              description: selectedDistrict["description"],
            );
            DeliveryAddressModel shipping_address=locationState.selectedShippingAddress!;
            List<DeliveryAddressModel> order_address=locationState.selectedOrderAddress!;

            if(outofAppState.order_type==5){
              locationNotifier.pickShippingAddress(address);
              formData.add(
                  { 'name': "Livraison de colis",
                    'price': outofAppState.package_amount,
                    'quantity': 1,
                    'image': ""
                  }
              );
              shipping_address=address;
              locationNotifier.setShippingAddressPicked(true);
            }else if(outofAppState.order_type==6){
              locationNotifier.pickOrderAddress(address);
                formData.add(
                    { 'name': "Récupération de colis",
                      'price': 0,
                      'quantity': 1,
                      'image': ""
                    }
                );
                order_address=[address];
                locationNotifier.setOrderAddressPicked(true);
            }

            if (shipping_address!=null && order_address.isNotEmpty) {
              outOfAppNotifier.setIsBillBuilt(false);
              outOfAppNotifier.setShowLoading(true);
                try{
                  OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                  CustomerModel? customer = await CustomerUtils.getCustomer();
                  OrderBillConfiguration orderBillConfiguration = await api.computeBillingAction(
                      customer!,
                      order_address,
                      formData,
                      shipping_address,
                      voucherState.selectedVoucher!,
                      false);
                  orderBillingNotifier.setOrderBillConfiguration(orderBillConfiguration);
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
            }
            },
        ),
      ],
    );
  }
}
