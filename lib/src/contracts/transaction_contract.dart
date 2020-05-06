
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/TransactionModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';

class TransactionContract {

//  void Transaction (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchTransaction(CustomerModel customer) {}
}

class TransactionView {
  void showLoading(bool isLoading) {}
  void showBalanceLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateTransaction(List<TransactionModel> transactions) {}
  void showBalance(String balance) {}
  void balanceSystemError() {}
}


/* Transaction presenter */
class TransactionPresenter implements TransactionContract {

  bool isWorking = false, isFetchBalanceWorking = false;

  TransactionView _transactionView;

  ClientPersonalApiProvider provider;

  TransactionPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set transactionView(TransactionView value) {
    _transactionView = value;
  }

  @override
  Future fetchTransaction(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _transactionView.showLoading(true);
    try {
      List<TransactionModel> bsellers = await provider.fetchTransactionsHistory(customer);
      // also get the restaurant entity here.
      _transactionView.inflateTransaction(bsellers);
    } catch (_) {
      /* Transaction failure */
      print("error ${_}");
      if (_ == -2) {
        _transactionView.systemError();
      } else {
        _transactionView.networkError();
      }
      isWorking = false;
    }
  }

  Future<void> checkBalance(CustomerModel customer) async {

    if (isFetchBalanceWorking)
      return;
    isFetchBalanceWorking = true;
    _transactionView.showBalanceLoading(true);
    try {
      String balance = await provider.checkBalance(customer);
      // also get the restaurant entity here.
      _transactionView.showBalance(balance);
      isFetchBalanceWorking = false;
    } catch (_) {
      /* Transaction failure */
      print("error ${_}");
      if (_ == -2) {
        _transactionView.balanceSystemError();
      } else {
        _transactionView.balanceSystemError();
      }
      isFetchBalanceWorking = false;
    }
  }
}