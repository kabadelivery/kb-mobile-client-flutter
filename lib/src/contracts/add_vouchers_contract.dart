/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class AddVoucherContract {

  void subscribeVoucher (CustomerModel customer, String promoCode, {bool isQrCode = false}){}
  void subscribeVoucherForDamage (CustomerModel customer, int damage_id){}
}

class AddVoucherView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void subscribeSuccessfull(VoucherModel voucher) {}
  void subscribeSuccessError(int error) {}
}

/* login presenter */
class AddVoucherPresenter implements AddVoucherContract {

  bool isWorking = false;

  late VoucherApiProvider provider;

  AddVoucherView _voucherView;

  AddVoucherPresenter(this._voucherView) {
    provider = VoucherApiProvider();
  }

  set addVoucherView(AddVoucherView value) {
    _voucherView = value;
  }

  @override
  Future<void> subscribeVoucher(CustomerModel customer, String promoCode, {bool isQrCode = false}) async {

    if (isWorking)
      return;
    isWorking = true;
    _voucherView.showLoading(true);
    try {
      var mVoucher = await provider.subscribeVoucher(customer, promoCode, isQrCode: isQrCode);
      // also get the restaurant entity here.
      _voucherView.showLoading(false);
      if (mVoucher is VoucherModel && mVoucher?.id != null) {
        _voucherView.subscribeSuccessfull(mVoucher);
      } else {
       _voucherView.subscribeSuccessError(mVoucher);
      }
    } catch (_) {
      /* BestSeller failure */
      _voucherView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _voucherView.systemError();
      } else {
        _voucherView.networkError();
      }
    }
    isWorking = false;
  }

  @override
  Future<void> subscribeVoucherForDamage(CustomerModel customer, int damage_id) async {
    if (isWorking)
      return;
    isWorking = true;
    _voucherView.showLoading(true);
    try {
      var mVoucher = await provider.subscribeVoucherForDamage(customer, damage_id);
      // also get the restaurant entity here.
      _voucherView.showLoading(false);
      if (mVoucher is VoucherModel && mVoucher?.id != null) {
        _voucherView.subscribeSuccessfull(mVoucher);
      } else {
        _voucherView.subscribeSuccessError(mVoucher);
      }
    } catch (_) {
      /* BestSeller failure */
      _voucherView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _voucherView.systemError();
      } else {
        _voucherView.networkError();
      }
      if (damage_id != -1){
        _voucherView.subscribeSuccessError(-1);
      }
    }
    isWorking = false;
  }

}
