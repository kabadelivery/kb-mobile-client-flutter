
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/MoneyTransactionModel.dart';
import 'package:KABA/src/models/PointObjModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class TransactionContract {

//  void Transaction (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchPointTransaction(CustomerModel customer) {}
  void fetchMoneyTransaction(CustomerModel customer) {}
}

class TransactionView {
  void showMoneyLoading(bool isLoading) {}
  void showBalanceLoading(bool isLoading) {}
  void systemMoneyError () {}
  void networkMoneyError () {}
  void inflateMoneyTransaction(List<MoneyTransactionModel> moneyTransactions) {}
  void showBalance(String balance) {}
  void balanceSystemError() {}

  void showPointloading(bool isLoading) {}
  void systemPointError () {}
  void networkPointError ({int delay}) {}
  void updateKabaPoints(String kabaPoints) {}
  void inflatePointModelObj(PointObjModel data) {}
}


/* Transaction presenter */
class TransactionPresenter implements TransactionContract {

  bool isMoneyWorking = false, isPointWorking = false, isFetchBalanceWorking = false;

  TransactionView _transactionView;

  ClientPersonalApiProvider provider;

  TransactionPresenter() {
    provider = new ClientPersonalApiProvider();
  }

  set transactionView(TransactionView value) {
    _transactionView = value;
  }

  /*@override
  Future fetchTransaction(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _transactionView.showLoading(true);
    try {
      List<MoneyTransactionModel> moneyTransactions = await provider.fetchTransactionsHistory(customer);
      // also get the restaurant entity here.
      _transactionView.inflateMoneyTransaction(moneyTransactions);
    } catch (_) {
      *//* Transaction failure *//*
      xrint("error ${_}");
      if (_ == -2) {
        _transactionView.systemError();
      } else {
        _transactionView.networkError();
      }
      isWorking = false;
    }
  }*/

  Future<void> checkBalance(CustomerModel customer) async {

    if (isFetchBalanceWorking)
      return;
    isFetchBalanceWorking = true;
    _transactionView.showBalanceLoading(true);
    try {
      String balance = await provider.checkBalance(customer);
      // String kabaPoints = await provider.checkKabaPoints(customer);
      // _transactionView.updateKabaPoints(kabaPoints);

      // also get the restaurant entity here.
      _transactionView.showBalance(balance);
      isFetchBalanceWorking = false;

    } catch (_) {
      /* Transaction failure */
      xrint("error ${_}");
      if (_ == -2) {
        _transactionView.balanceSystemError();
      } else {
        _transactionView.balanceSystemError();
      }
      isFetchBalanceWorking = false;
    }
  }

  @override
  Future<void> fetchMoneyTransaction(CustomerModel customer) async {
    if (isMoneyWorking)
      return;
    isMoneyWorking = true;
    _transactionView.showMoneyLoading(true);
    try {
      List<MoneyTransactionModel> moneyTransactions = await provider.fetchMoneyTransactionsHistory(customer);
      // also get the restaurant entity here.
      _transactionView.inflateMoneyTransaction(moneyTransactions);
    } catch (_) {
      /* Transaction failure */
      xrint("error ${_}");
      if (_ == -2) {
        _transactionView.systemMoneyError();
      } else {
        _transactionView.networkMoneyError();
      }
    }
    isMoneyWorking = false;
  }

  @override
  Future<void> fetchPointTransaction(CustomerModel customer) async {
    if (isPointWorking)
      return;
    isPointWorking = true;
    _transactionView.showPointloading(true);
    try {
      PointObjModel pointObjModel = await provider.fetchPointTransactionsHistory(customer);
      // also get the restaurant entity here.
      _transactionView.inflatePointModelObj(pointObjModel);
    } catch (_) {
      /* Transaction failure */
      xrint("error ${_}");
      if (_ == -2) {
        _transactionView.systemPointError();
      } else {
        _transactionView.networkPointError(delay: 1);
      }
    }
    isPointWorking = false;
  }
}