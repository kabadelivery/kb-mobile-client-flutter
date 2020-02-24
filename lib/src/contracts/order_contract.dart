
import 'dart:convert';

import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/resources/order_api_provider.dart';

class OrderConfirmationContract {

//  void login (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  Future<void> payAtDelivery(CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos) {}
}

class OrderConfirmationView {
  /* void showLoading(bool isLoading) {}
  void loginSuccess () {}
  void loginFailure (String message) {}*/
  void systemError () {}
  void networkError () {}
  void logoutTimeOutSuccess() {}
  void inflateBillingConfiguration (OrderBillConfiguration configuration) {}

  void launchOrderSuccess(bool isSuccessful) {}
}


/* login presenter */
class OrderConfirmationPresenter implements OrderConfirmationContract {

  bool isWorking = false;

  OrderConfirmationView _orderConfirmationView;

  OrderApiProvider provider;

  OrderConfirmationPresenter() {
    provider = new OrderApiProvider();
  }

  @override
  Future computeBilling(CustomerModel customer, Map<RestaurantFoodModel, int> foods,
      DeliveryAddressModel address) async {
    if (isWorking)
      return;
    isWorking = true;
    try {
      OrderBillConfiguration orderBillConfiguration = await provider.computeBillingAction(customer, foods, address);
      _orderConfirmationView.inflateBillingConfiguration(orderBillConfiguration);
      isWorking = false;
    } catch (_) {
      /* login failure */
      print("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      isWorking = false;
    }
  }

  set orderConfirmationView(OrderConfirmationView value) {
    _orderConfirmationView = value;
  }

  Future<void> payAtDelivery(CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      bool res = await provider.launchOrder(true, customer, foods, selectedAddress, mCode, infos);
    _orderConfirmationView.launchOrderSuccess(res);
    } catch (_) {
      /* login failure */
      print("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      _orderConfirmationView.launchOrderSuccess(false);
      isWorking = false;
    }
  }

  Future<void> payNow(CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      bool res = await provider.launchOrder(false, customer, foods, selectedAddress, mCode, infos);
      _orderConfirmationView.launchOrderSuccess(res);
    } catch (_) {
      /* login failure */
      print("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      _orderConfirmationView.launchOrderSuccess(false);
      isWorking = false;
    }
  }

}