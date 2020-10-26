
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class TransferMoneyRequestContract {

//  void launchTopUp(CustomerModel customer, String phoneNumber, String balance) {}
  void launchTransferMoneyRequest(CustomerModel customer,String phoneNumber) {}
}

class TransferMoneyRequestView {
  void systemError () {}
  void showLoading(bool isLoading) {}
  void networkError () {}
  void continueTransaction(CustomerModel customer){}
}


/* TopUp presenter */
class TransferMoneyRequestPresenter implements TransferMoneyRequestContract {

  bool isWorking = false;

  TransferMoneyRequestView _transferMoneyRequestView;

  ClientPersonalApiProvider provider;

  TransferMoneyRequestPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set transferMoneyRequestView(TransferMoneyRequestView value) {
    _transferMoneyRequestView = value;
  }

  @override
  Future<void> launchTransferMoneyRequest(CustomerModel customer, String phoneNumber) async {
    if (isWorking)
      return;
    isWorking = true;
    _transferMoneyRequestView.showLoading(true);
    try {
      CustomerModel customerModel = await provider.launchTransferMoneyRequest(customer, phoneNumber);
      _transferMoneyRequestView.continueTransaction(customerModel);
      isWorking = false;
    } catch (_) {
      xrint("error ${_}");
      if (_ == -2) {
        _transferMoneyRequestView.systemError();
      } else {
        _transferMoneyRequestView.networkError();
      }
      isWorking = false;
    }
  }

}

