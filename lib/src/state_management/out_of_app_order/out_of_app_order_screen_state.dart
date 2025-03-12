import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutOfAppScreenState{
  bool showLoading;
  bool isBillBuilt;
  bool isPayAtDeliveryLoading;
  int order_type;
  String phone_number;
  String package_amount;
  OutOfAppScreenState({
    this.showLoading = false,
    this.isBillBuilt = false,
    this.isPayAtDeliveryLoading=false,
    this.order_type=0,
    this.phone_number = '',
    this.package_amount = '',
    });
  OutOfAppScreenState copyWith({
    bool showLoading,
    bool isBillBuilt,
    bool isPayAtDeliveryLoading,
    int order_type,
    String phone_number,
    String package_amount,
  }){
    return OutOfAppScreenState(
      showLoading: showLoading ?? this.showLoading,
      isBillBuilt: isBillBuilt ?? this.isBillBuilt,
      isPayAtDeliveryLoading:isPayAtDeliveryLoading??this.isPayAtDeliveryLoading,
      order_type:order_type??this.order_type,
      phone_number: phone_number ?? this.phone_number,
    );
  }
}

class OutOfAppScreenStateNotifier extends StateNotifier<OutOfAppScreenState>{
  OutOfAppScreenStateNotifier():super(OutOfAppScreenState());

  void setShowLoading(bool showLoading){
    state = state.copyWith(showLoading:showLoading);
  }
  void setIsBillBuilt(bool isBillBuilt){
    state = state.copyWith(isBillBuilt:isBillBuilt);
  }
  void setIsPayAtDeliveryLoading(bool isPayAtDeliveryLoading){
    state = state.copyWith(isPayAtDeliveryLoading:isPayAtDeliveryLoading);
  }
  void setOrderType(int order_type){
    state = state.copyWith(order_type:order_type);
  }
  void setPhoneNumber(String phone_number) {
    state = state.copyWith(phone_number: phone_number);
  }
  void setPackageAmount(String package_amount) {
    state = state.copyWith(package_amount: package_amount);
  } 
  void reset(){
    state = state.copyWith(
      showLoading: false,
        isBillBuilt:false,
        isPayAtDeliveryLoading:false,
        order_type:0,
        phone_number: '',
        package_amount: '',
    );
  }
}

final outOfAppScreenStateProvier = StateNotifierProvider.autoDispose<OutOfAppScreenStateNotifier,OutOfAppScreenState>((ref){
  return OutOfAppScreenStateNotifier();
});