
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';

class TopUpContract {

  void launchTopUp(CustomerModel customer, String phoneNumber, String balance, int fees) {}
  void fetchFees(CustomerModel customer) {}
  void fetchTopUpConfiguration(CustomerModel customer) {}
}

class TopUpView {
  void showLoading(bool isLoading) {}
  void showGetFeesLoading(bool isLoading) {}
  void topUpToWeb(String link) {}
  void systemError () {}
  void networkError () {}
  void updateFees(int fees) {}
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
  Future<void> launchTopUp(CustomerModel customer, String phoneNumber, String balance, int fees) async {

    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showLoading(true);
    try {
      String link = await provider.launchTopUp(customer, phoneNumber, balance, fees);
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

  @override
  Future<void> fetchFees(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _topUpView.showGetFeesLoading(true);
    try {
      int fees = await provider.fetchFees(customer);
      _topUpView.updateFees(fees);
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
    _topUpView.showGetFeesLoading(false);
  }

  @override
  void fetchTopUpConfiguration(CustomerModel customer) {

  }


}

