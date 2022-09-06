/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/chat_voucher_provider.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class ChatVoucherContract {
  void fetchVoucherDetails(CustomerModel customer, String voucher_code) {}
}

class ChatVoucherView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void inflateVoucher(VoucherModel voucher) {}
}

/* login presenter */
class ChatVoucherPresenter implements ChatVoucherContract {
  bool isWorking = false;

  ChatVoucherProvider provider;

  ChatVoucherView _voucherView;

  ChatVoucherPresenter() {
    provider = new ChatVoucherProvider();
  }

  set chatVoucherView(ChatVoucherView value) {
    _voucherView = value;
  }

  @override
  Future<void> fetchVoucherDetails(
      CustomerModel customer, String voucher_code) async {
    if (isWorking) return;
    isWorking = true;
    _voucherView.showLoading(true);
    try {
      String mVoucher =
          await provider.fetchVoucherDetails(customer, voucher_code);

      _voucherView.showLoading(false);
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
