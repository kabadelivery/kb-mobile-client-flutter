import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutOfAppScreenState{
  bool showLoading;
  bool isBillBuilt;
 bool isPayAtDeliveryLoading;
  OutOfAppScreenState({
    this.showLoading = false,
    this.isBillBuilt = false,
  this.isPayAtDeliveryLoading=false
  });
  OutOfAppScreenState copyWith({
    bool showLoading,
    bool isBillBuilt,
    bool isPayAtDeliveryLoading
}){
    return OutOfAppScreenState(
      showLoading: showLoading ?? this.showLoading,
      isBillBuilt: isBillBuilt ?? this.isBillBuilt,
      isPayAtDeliveryLoading:isPayAtDeliveryLoading??this.isPayAtDeliveryLoading
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
  void reset(){
    state = state.copyWith(
      showLoading: false,
        isBillBuilt:false,
        isPayAtDeliveryLoading:false
    );
  }
}

final outOfAppScreenStateProvier = StateNotifierProvider.autoDispose<OutOfAppScreenStateNotifier,OutOfAppScreenState>((ref){
  return OutOfAppScreenStateNotifier();
});