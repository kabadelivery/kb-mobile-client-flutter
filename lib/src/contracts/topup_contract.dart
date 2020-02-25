
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/resources/menu_api_provider.dart';

class TopUpContract {

  void launchTopUp(CustomerModel customer, String phoneNumber, String balance) {}
}

class TopUpView {
  void showLoading(bool isLoading) {}
  void topUpToWeb(String link) {}
  void systemError () {}
  void networkError () {}
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
  Future<void> launchTopUp(CustomerModel customer, String phoneNumber, String balance) async {

    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showLoading(true);
    try {
      String link = await provider.launchTopUp(customer, phoneNumber, balance);
      _topUpView.topUpToWeb(link);
      isWorking = false;
    } catch (_) {
      print("error ${_}");
      if (_ == -2) {
        _topUpView.systemError();
      } else {
        _topUpView.networkError();
      }
      isWorking = false;
    }
  }
}

