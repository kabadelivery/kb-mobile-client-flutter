
import 'dart:convert';

import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/OrderItemModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/xrint.dart';

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

  late OrderApiProvider provider;

  OrderDetailsPresenter(this._orderDetailsView) {
    provider = new OrderApiProvider();
  }

  set orderDetailsView(OrderDetailsView value) {
    _orderDetailsView = value;
  }

  @override
  Future<void> fetchOrderDetailsWithId(CustomerModel customerModel, int orderId,{bool is_out_of_app_order=false}) async {

    _orderDetailsView.showLoading(true);
    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      CommandModel commandModel = await provider.loadOrderFromId(customerModel, orderId,is_out_of_app_order:is_out_of_app_order);
      _orderDetailsView.showLoading(false);
      if (commandModel != null) {
        _orderDetailsView.inflateOrderDetails(commandModel);
      } else {
        _orderDetailsView.systemError();
      }
    } catch(_,stackTrace) {
      /* Food failure */
      _orderDetailsView.showLoading(false);
      xrint("error ${_}");
     
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