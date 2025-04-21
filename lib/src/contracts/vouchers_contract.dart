/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class VoucherContract {

  void loadVoucherList ({CustomerModel? customer, bool pick=false}){}
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

  late VoucherApiProvider provider;

  VoucherView _voucherView;

  VoucherPresenter (this._voucherView) {
    provider = new VoucherApiProvider();
  }

  set voucherView(VoucherView value) {
    _voucherView = value;
  }

  @override
  Future<void> loadVoucherList({CustomerModel? customer, int restaurantId = -1, List<int>? foodsId, bool pick=false}) async {
    if (isWorking)
      return;
    isWorking = true;
    _voucherView.showLoading(true);
    try {
      List<VoucherModel> deliverVouchers = await provider.loadVouchers(customer:customer!, restaurantId: restaurantId, foodsId: foodsId!, pick:pick);
      // also get the restaurant entity here.
      _voucherView.showLoading(false);
      _voucherView.inflateVouchers(deliverVouchers);
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

}
