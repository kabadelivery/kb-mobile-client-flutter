/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class DeleteAccountRefundContract {
    deleteAndRefund(CustomerModel customer, String first, String last, String phone_number, int requestId){}
}

class DeleteAccountRefundView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void deletionRefundSuccess() {}
}

/* login presenter */
class DeleteAccountRefundPresenter
    implements DeleteAccountRefundContract {

  bool isWorking = false;

  ClientPersonalApiProvider provider;

  DeleteAccountRefundView _deleteAccountRefundView;

  DeleteAccountRefundPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set addDeleteAccountRefundView(DeleteAccountRefundView value) {
    _deleteAccountRefundView = value;
  }

  @override
  Future<void> deleteAndRefund(CustomerModel customer, String first, String last, String phone_number, int requestId) async {

    if (isWorking)
      return;
    isWorking = true;
    _deleteAccountRefundView.showLoading(true);
    try {
      var data = await provider.deleteAndProcessRefund(customer, first, last, phone_number, requestId);
      // also get the restaurant entity here.
      _deleteAccountRefundView.showLoading(false);
      int error = data["error"]; // 0
      if (error == 0 && data["data"] == "ok") {
        _deleteAccountRefundView.deletionRefundSuccess();
      }  else {
        _deleteAccountRefundView.systemError();
      }
    } catch (_) {
      /* BestSeller failure */
      _deleteAccountRefundView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _deleteAccountRefundView.systemError();
      } else {
        _deleteAccountRefundView.networkError();
      }
    }
    isWorking = false;
  }





}