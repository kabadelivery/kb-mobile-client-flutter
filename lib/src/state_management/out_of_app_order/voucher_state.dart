import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/VoucherModel.dart';

class VoucherState {
  VoucherModel selectedVoucher;
  VoucherModel oldSelectedVoucher;
  bool usePoint ;
  VoucherState({this.selectedVoucher = null, this.oldSelectedVoucher = null,this.usePoint=false});

  VoucherState copyWith({
    VoucherModel selectedVoucher,
    VoucherModel oldSelectedVoucher,
    bool usePoint
}){
    return VoucherState(
        selectedVoucher:selectedVoucher??this.selectedVoucher,
      oldSelectedVoucher:selectedVoucher??this.oldSelectedVoucher,
        usePoint:usePoint??this.usePoint
    );
}
}
class VoucherStateNotifier extends StateNotifier<VoucherState>{
  VoucherStateNotifier():super(VoucherState());

  void setVoucher(VoucherModel voucher){
    state = state.copyWith(selectedVoucher: voucher);
  }
  void setOldVoucher(VoucherModel voucher){
    state = state.copyWith(oldSelectedVoucher: voucher);
  }
  void setUsePoint(bool usePoint){
    state = state.copyWith(usePoint:usePoint);
  }
  void reset(){
    state = state.copyWith(selectedVoucher: null);
    state = state.copyWith(oldSelectedVoucher: null);
    state = state.copyWith(usePoint:false);
  }
}
final voucherStateProvider = StateNotifierProvider<VoucherStateNotifier,VoucherState>((ref) {
  return VoucherStateNotifier();
});