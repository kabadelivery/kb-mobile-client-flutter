
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';

class TopUpContract {

  void launchTopUp(CustomerModel customer, String phoneNumber, String balance, double fees) {}
  void launchPayDunya(CustomerModel customer, String balance, double fees) {}
  void fetchFees(CustomerModel customer) {}
  void fetchTopUpConfiguration(CustomerModel customer) {}
}

class TopUpView {
  void showLoading(bool isLoading) {}
  void showGetFeesLoading(bool isLoading) {}
  void topUpToWeb(String link) {}
  void topUpToPush() {}
  void systemError () {}
  void networkError () {}
  void updateFees(double fees_tmoney, double fees_flooz, double fees_bankcard) {}
}


/* TopUp presenter */
class TopUpPresenter implements TopUpContract {

  bool isWorking = false;

  TopUpView _topUpView;

  ClientPersonalApiProvider provider;

  TopUpPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set topUpView(TopUpView value) {
    _topUpView = value;
  }

  @override
  Future<void> launchTopUp(CustomerModel customer, String phoneNumber, String balance, double fees) async {

    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showLoading(true);
    try {
      dynamic res = await provider.launchTopUp(customer, phoneNumber, balance, fees);
      String link = mJsonDecode(res)["data"]["url"];
      int redirect = mJsonDecode(res)["data"]["redirect"];
      if (redirect == 0)
        _topUpView.topUpToPush();
      else
        _topUpView.topUpToWeb(link);
      isWorking = false;
    } catch (_) {
      xrint("error ${_}");
      if (_ == -2) {
        _topUpView.systemError();
      } else {
        _topUpView.networkError();
      }
      isWorking = false;
    }
  }

  @override
  Future<void> launchPayDunya(CustomerModel customer, String balance, double fees) async {

    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showLoading(true);
    try {
      dynamic res = await provider.launchPayDunya(customer, balance, fees);
      String link = mJsonDecode(res)["data"]["url"];
      int redirect = mJsonDecode(res)["data"]["redirect"];
      if (redirect == 0)
        _topUpView.topUpToPush();
      else
        _topUpView.topUpToWeb(link);
      isWorking = false;
    } catch (_) {
      xrint("error ${_}");
      if (_ == -2) {
        _topUpView.systemError();
      } else {
        _topUpView.networkError();
      }
      isWorking = false;
    }
  }


  @override
  Future<void> fetchFees(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showGetFeesLoading(true);
    try {
      var fees_obj = await provider.fetchFees(customer);
      _topUpView.showGetFeesLoading(false);
      double fees_flooz = double.parse("${fees_obj["fees_flooz"]}");
      double fees_tmoney = double.parse("${fees_obj["fees_tmoney"]}");
      double fees_bankcard = double.parse("${fees_obj["fees_bankcard"]}");
      _topUpView.showGetFeesLoading(false);
      _topUpView.updateFees(fees_tmoney, fees_flooz, fees_bankcard);
      isWorking = false;
    } catch (_) {
      _topUpView.showGetFeesLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _topUpView.systemError();
      } else {
        _topUpView.networkError();
      }
      isWorking = false;
    }
    _topUpView.showGetFeesLoading(false);
  }

  @override
  void fetchTopUpConfiguration(CustomerModel customer) {

  }


}

