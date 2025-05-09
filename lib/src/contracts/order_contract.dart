
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/DeliveryTimeFrameModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/xrint.dart';

class OrderConfirmationContract {

//  void login (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
  void checkOpeningStateOf(CustomerModel customer, ShopModel restaurant) {}
  Future<void> payAtDelivery(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, VoucherModel voucher, bool useKabaPoint) {}
  void computeBilling (ShopModel restaurant, CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address, VoucherModel voucher, bool useKabaPoint){}
  Future<void> payNow(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, VoucherModel voucher, bool useKabaPoint){}
  Future<void> payPreorder(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, String start, String end){}
}

class OrderConfirmationView {

  void systemError () {}
  void networkError () {}
  void logoutTimeOutSuccess() {}
  void launchOrderResponse(int errorCode) {}
  void systemOpeningStateError() {}
  void networkOpeningStateError() {}
  void isRestaurantOpenConfigLoading(bool isLoading) {}
  void inflateBillingConfiguration1(OrderBillConfiguration configuration) {}
  void inflateBillingConfiguration2(OrderBillConfiguration configuration) {}
  void showLoading(bool isLoading) {}

  void isPurchasing(bool isPurchasing) {}
  void sorryDemoAccountAlert() {}
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
  Future computeBilling(ShopModel restaurantModel, CustomerModel customer, Map<ShopProductModel, int> foods,
      DeliveryAddressModel address, VoucherModel voucher, bool useKabaPoint) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      OrderBillConfiguration orderBillConfiguration = await provider.computeBillingAction(customer, restaurantModel, foods, address, voucher, useKabaPoint);
      _orderConfirmationView.showLoading(false);
      _orderConfirmationView.inflateBillingConfiguration2(orderBillConfiguration);
      isWorking = false;
    } catch (_) {
      /* login failure */
      xrint("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemOpeningStateError();
      } else {
        _orderConfirmationView.networkOpeningStateError();
      }
      isWorking = false;
    }
  }

  set orderConfirmationView(OrderConfirmationView value) {
    _orderConfirmationView = value;
  }


  @override
  Future<void> payAtDelivery(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, VoucherModel voucher, bool useKabaPoint) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      int error = await provider.launchOrder(true, customer, foods, selectedAddress, mCode, infos, voucher, useKabaPoint);
      _orderConfirmationView.launchOrderResponse(error);
    } catch (_) {
      /* login failure */
      xrint("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      _orderConfirmationView.launchOrderResponse(-1);
    }
    isWorking = false;
  }

  Future<void> payNow(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, VoucherModel voucher, bool useKabaPoint) async {

    if (isWorking)
      return;
    isWorking = true;
    try {
      _orderConfirmationView.isPurchasing(true);
      int error = await provider.launchOrder(false, customer, foods, selectedAddress, mCode, infos, voucher, useKabaPoint);
      _orderConfirmationView.launchOrderResponse(error);
    } catch (_) {
      /* login failure */
      xrint("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      _orderConfirmationView.launchOrderResponse(-1);
    }
    isWorking = false;
  }

  Future<void> payPreorder(CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos, String start, String end) async {


    if (isWorking)
      return;
    isWorking = true;
    try {
//      _orderConfirmationView.isPurchasing(true);
      int error = await provider.launchPreorderOrder(customer, foods, selectedAddress, mCode, infos, start, end);
      _orderConfirmationView.launchOrderResponse(error);
    } catch (_) {
      /* login failure */
      xrint("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemError();
      } else {
        _orderConfirmationView.networkError();
      }
      _orderConfirmationView.launchOrderResponse(-1);
    }
    isWorking = false;
  }

  Future<void> checkOpeningStateOf(CustomerModel customer, ShopModel restaurant) async {

    if (isWorking)
      return;
    isWorking = true;

    _orderConfirmationView.isRestaurantOpenConfigLoading(true);
    try {
      String response = await provider.checkOpeningStateOfRestaurant(customer, restaurant);
      // send back the resultat obc
      xrint(response);
      OrderBillConfiguration configuration;

      int open_type  =0;
      int can_preorder = 0;
      String discount = "0";
      String working_hour = "0";
      String reason = "0";

      open_type = json.decode(response)["data"]["open_type"];
      working_hour = json.decode(response)["data"]["working_hour"];
      reason = json.decode(response)["data"]["reason"];
      can_preorder = json.decode(response)["data"]["preorder"]["can_preorder"];
      discount = json.decode(response)["data"]["preorder"]["discount"];

//open_type = 0;
//can_preorder = 0;

      Iterable lo = json.decode(response)["data"]["preorder"]["hours"];
      List<DeliveryTimeFrameModel> deliveryFrames = lo?.map((df) => DeliveryTimeFrameModel.fromJson(df))?.toList();

      //    open_type = 0;
      //    can_preorder = 0;

      configuration = OrderBillConfiguration(working_hour: working_hour, open_type: open_type, reason: reason, can_preorder:  can_preorder, discount: discount, deliveryFrames: deliveryFrames, isBillBuilt: false);
      _orderConfirmationView.isRestaurantOpenConfigLoading(false);
      _orderConfirmationView.inflateBillingConfiguration1(configuration);
    } catch (_) {
      /* login failure */
      _orderConfirmationView.isRestaurantOpenConfigLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _orderConfirmationView.systemOpeningStateError();
      } else {
        _orderConfirmationView.networkOpeningStateError();
      }
    }
    isWorking = false;
  }

}