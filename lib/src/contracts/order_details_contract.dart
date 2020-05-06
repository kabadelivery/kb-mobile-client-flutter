
import 'dart:convert';

import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/OrderItemModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/resources/order_api_provider.dart';

class OrderDetailsContract {

  void fetchOrderDetailsWithId(CustomerModel customerModel,int commandId){}

}

class OrderDetailsView {


  void systemError () {}
  void networkError () {}
  void logoutTimeOutSuccess() {}
  void showLoading(bool isLoading){}
  void inflateOrderDetails (CommandModel orderItemModel) {}
}


/* login presenter */
class OrderDetailsPresenter implements OrderDetailsContract {

  bool isWorking = false;

  OrderDetailsView _orderDetailsView;

  OrderApiProvider provider;

  OrderDetailsPresenter() {
    provider = new OrderApiProvider();
  }

  set orderDetailsView(OrderDetailsView value) {
    _orderDetailsView = value;
  }

  @override
  Future<void> fetchOrderDetailsWithId(CustomerModel customerModel, int orderId) async {

    _orderDetailsView.showLoading(true);
    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      CommandModel commandModel = await provider.loadOrderFromId(customerModel, orderId);
      if (commandModel != null) {
        _orderDetailsView.inflateOrderDetails(commandModel);
      } else {
        _orderDetailsView.systemError();
      }
    } catch(_) {
      /* Food failure */
      print("error ${_}");
      if (_ == -2) {
        _orderDetailsView.systemError();
      } else {
        _orderDetailsView.networkError();
      }
      isWorking = false;
    }
    isWorking = false;

  }


}