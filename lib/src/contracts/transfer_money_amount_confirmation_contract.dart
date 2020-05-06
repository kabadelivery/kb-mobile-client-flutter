
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';

class TransferMoneyAmountConfirmationContract {

//  void launchTopUp(CustomerModel customer, String phoneNumber, String balance) {}
  void  launchTransferMoneyAction(CustomerModel mySelf, int receiverId, String transactionPassword, String amount) {}
}

class TransferMoneyAmountConfirmationView {
  void systemError () {}
  void showLoading(bool isLoading) {}
  void networkError () {}
  void transactionError(CustomerModel customer){}
  void transactionSuccessful(CustomerModel moneyReceiver, String amount, String balance){}
  void balanceInsufficient() {}
  void passwordWrong() {}
}


/* TopUp presenter */
class TransferMoneyAmountConfirmationPresenter implements TransferMoneyAmountConfirmationContract {

  bool isWorking = false;

  TransferMoneyAmountConfirmationView _transferMoneyAmountConfirmationView;

  ClientPersonalApiProvider provider;

  TransferMoneyAmountConfirmationPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set transferMoneyAmountConfirmationView(TransferMoneyAmountConfirmationView value) {
    _transferMoneyAmountConfirmationView = value;
  }

  @override
  Future<void> launchTransferMoneyAction(CustomerModel mySelf, int receiverId, String transactionPassword, String amount) async {

    if (isWorking)
      return;
    isWorking = true;
    _transferMoneyAmountConfirmationView.showLoading(true);
    try {
      Map res = await provider.launchTransferMoneyAction(mySelf, receiverId, transactionPassword, amount);

      CustomerModel customer = res["customer"];
      int errorCode = res["errorCode"];
      int statut = res["statut"];
      String _amount = "${res["amount"]}";
      String balance = "${res["balance"]}";

      // get new solde and update it.

      _transferMoneyAmountConfirmationView.showLoading(false);

      switch(errorCode){
        case 0:
          if (statut == 1) {
            // success
            _transferMoneyAmountConfirmationView.transactionSuccessful(customer, _amount, balance);
          } else if (statut == -100) {
            // password wrong
            _transferMoneyAmountConfirmationView.passwordWrong();
          } else {
            _transferMoneyAmountConfirmationView.systemError();
          }
          break;
        case 300:
            // balance insuffiscient
          _transferMoneyAmountConfirmationView.balanceInsufficient();
          break;
        case -1:
            // password wrong
          _transferMoneyAmountConfirmationView.passwordWrong();
          break;
        default:
          // error with message
          _transferMoneyAmountConfirmationView.systemError();
          break;
      }
      isWorking = false;
    } catch (_) {
      print("error ${_}");
      if (_ == -2) {
        _transferMoneyAmountConfirmationView.systemError();
      } else {
        _transferMoneyAmountConfirmationView.networkError();
      }
      isWorking = false;
    }
    isWorking = false;
  }

}

