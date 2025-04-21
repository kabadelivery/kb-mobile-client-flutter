import '../../models/DeliveryAddressModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../xrint.dart';

class PickingAdressState {
   bool? is_shipping_address_picked;
   bool? is_order_address_picked;
   DeliveryAddressModel? selectedShippingAddress;
   List<DeliveryAddressModel>? selectedOrderAddress;

  PickingAdressState(
  {
      this.is_shipping_address_picked=false,
      this.is_order_address_picked=false,
      this.selectedShippingAddress=null,
      this.selectedOrderAddress=null
  }
      );

  PickingAdressState copyWith({
     bool? is_shipping_address_picked,
     bool? is_order_address_picked,
     DeliveryAddressModel? selectedShippingAddress,
     List<DeliveryAddressModel>? selectedOrderAddress,
}){
  return  PickingAdressState(
      is_shipping_address_picked : is_shipping_address_picked??this.is_shipping_address_picked,
      is_order_address_picked : is_shipping_address_picked??this.is_order_address_picked,
      selectedShippingAddress : selectedShippingAddress??this.selectedShippingAddress ,
      selectedOrderAddress : selectedOrderAddress??this.selectedOrderAddress,
  );
  }
}

class PickingAddressNotifier extends StateNotifier<PickingAdressState>{
  PickingAddressNotifier():super(PickingAdressState());
  setShippingAddressPicked(bool is_shipping_address_picked){
    state = state.copyWith(is_shipping_address_picked:is_shipping_address_picked);
  }
  setOrderAddressPicked(bool is_order_address_picked){
    state = state.copyWith(is_order_address_picked:is_order_address_picked);
  }
  pickShippingAddress(DeliveryAddressModel? selectedShippingAddress){
    state = state.copyWith(selectedShippingAddress:selectedShippingAddress);
  }
  pickOrderAddress(DeliveryAddressModel? order_address) {
    try {
      final currentAddresses = state.selectedOrderAddress ?? [];
      bool exists = currentAddresses.any((address) => address.id == order_address!.id);
      if (!exists) {
        state = state.copyWith(
          is_order_address_picked: true,
          selectedOrderAddress: [...currentAddresses, order_address!],
        );
        xrint("Order address added: ${state.selectedOrderAddress}");
      }
    } catch (e) {
      xrint('Error adding order_address: $e');
    }
  }
  deleteOrderAddress(DeliveryAddressModel? order_address, bool is_order_address_picked) {
    try {
    
      state = state.copyWith(
        selectedOrderAddress: [],
        is_order_address_picked:false
      );
      xrint("Order address removed: ${state.selectedOrderAddress}");
    } catch (e) {
      xrint('Error removing order_address: $e'); 
    }
  }

  void reset(){
    state = state.copyWith(
      is_order_address_picked: false,
      is_shipping_address_picked:false ,
      selectedOrderAddress: null,
      selectedShippingAddress: null
    );
  }

  void resetOrderAddress() {
    state = state.copyWith(
      selectedOrderAddress: null,
      is_order_address_picked: false
    );
  }
  void resetShippingAddress() {
    state = state.copyWith(
      selectedShippingAddress: null,
      is_shipping_address_picked: false
    );
  }


}

final locationStateProvider = StateNotifierProvider.autoDispose<PickingAddressNotifier,PickingAdressState>((ref){
  return PickingAddressNotifier();
});