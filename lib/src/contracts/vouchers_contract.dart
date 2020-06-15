/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';

class VoucherContract {

  void loadVoucherList (CustomerModel customer){}
}

class VoucherView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateVouchers(List<VoucherModel> vouchers) {}
}

/* login presenter */
class VoucherPresenter implements VoucherContract {

  bool isWorking = false;

  VoucherApiProvider provider;

  VoucherView _voucherView;

  VoucherPresenter () {
    provider = new VoucherApiProvider();
  }

  set voucherView(VoucherView value) {
    _voucherView = value;
  }

  @override
  Future<void> loadVoucherList(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _voucherView.showLoading(true);
    try {
      List<VoucherModel> deliverVouchers = await provider.loadVouchers(customer);
      // also get the restaurant entity here.
      _voucherView.showLoading(false);
      _voucherView.inflateVouchers(deliverVouchers);
    } catch (_) {
      /* BestSeller failure */
      _voucherView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _voucherView.systemError();
      } else {
        _voucherView.networkError();
      }
    }
    isWorking = false;
  }

}
