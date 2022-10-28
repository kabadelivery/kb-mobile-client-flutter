/* login contract */
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/vouchers_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class DeleteAccountQuestioningContract {
  void postQuestioningResult(
      CustomerModel customer, List<String> reasons, String message) {}
}

class DeleteAccountQuestioningView {
  void showLoading(bool isLoading) {}

  void systemError() {}

  void networkError() {}

  void showProposedReparation(VoucherModel mVoucher, int fixId, int balance) {}
}

/* login presenter */
class DeleteAccountQuestioningPresenter
    implements DeleteAccountQuestioningContract {
  bool isWorking = false;

  ClientPersonalApiProvider provider;

  DeleteAccountQuestioningView _deleteAccountQuestioningView;

  DeleteAccountQuestioningPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set addDeleteAccountQuestioningView(DeleteAccountQuestioningView value) {
    _deleteAccountQuestioningView = value;
  }

  @override
  Future<void> postQuestioningResult(
      CustomerModel customer, List<String> reasons, String message) async {
    /* post reasons for it */
    if (isWorking) return;
    isWorking = true;
    _deleteAccountQuestioningView.showLoading(true);
    try {
      var res =
          await provider.postQuestioningResult(customer, reasons, message);
      VoucherModel mVoucher = VoucherModel.fromJson(res["data"]["voucher"]);
      // also get the restaurant entity here.
      _deleteAccountQuestioningView.showLoading(false);
      if (mVoucher?.subscription_code != null) {
        _deleteAccountQuestioningView.showProposedReparation(mVoucher, res["data"]["id"], res["data"]["balance"]);
      } else {
        _deleteAccountQuestioningView.systemError();
      }
    } catch (_) {
      /* BestSeller failure */
      _deleteAccountQuestioningView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _deleteAccountQuestioningView.systemError();
      } else {
        _deleteAccountQuestioningView.networkError();
      }
    }
    isWorking = false;
  }
}

/*

  @override
  Future<void> subscribeVoucher(CustomerModel customer, String promoCode, {bool isQrCode = false}) async {

    if (isWorking)
      return;
    isWorking = true;
    _deleteAccountQuestioningView.showLoading(true);
    try {
      var mVoucher = await provider.subscribeVoucher(customer, promoCode, isQrCode: isQrCode);
      // also get the restaurant entity here.
      _deleteAccountQuestioningView.showLoading(false);
      if (mVoucher is VoucherModel && mVoucher?.id != null) {
        _deleteAccountQuestioningView.subscribeSuccessfull(mVoucher);
      } else {
       _deleteAccountQuestioningView.subscribeSuccessError(mVoucher);
      }
    } catch (_) {
      */
/* BestSeller failure */ /*

      _deleteAccountQuestioningView.showLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _deleteAccountQuestioningView.systemError();
      } else {
        _deleteAccountQuestioningView.networkError();
      }
    }
    isWorking = false;
  }
*/
