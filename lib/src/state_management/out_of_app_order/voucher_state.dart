import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/VoucherModel.dart';

class VoucherState {
  VoucherModel selectedVoucher;
  VoucherModel oldSelectedVoucher;

  VoucherState({this.selectedVoucher = null, this.oldSelectedVoucher = null});

  VoucherState copyWith({
    VoucherModel selectedVoucher,
    VoucherModel oldSelectedVoucher,
}){
    return VoucherState(
        selectedVoucher:selectedVoucher??this.selectedVoucher,
      oldSelectedVoucher:selectedVoucher??this.oldSelectedVoucher,
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
  void reset(){
    state = state.copyWith(selectedVoucher: null);
    state = state.copyWith(oldSelectedVoucher: null);
  }
}
final voucherStateProvider = StateNotifierProvider<VoucherStateNotifier,VoucherState>((ref) {
  return VoucherStateNotifier();
});