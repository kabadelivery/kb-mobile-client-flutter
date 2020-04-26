
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/resources/order_api_provider.dart';

class OrderFeedbackContract {

  void loadOrderDetailsForFeedback(CustomerModel customer, int orderId) {}
  void sendFeedback(CustomerModel customer, int orderId, int rating, String message){}
}

class OrderFeedbackView {

  void sendFeedbackError () {}
  void sendFeedbackSuccess() {}

  void systemError () {}
  void networkError () {}

  void showLoading(bool isLoading) {}

  void inflateOrderDetails(CommandModel commandModel) {}
}


/* login presenter */
class OrderFeedbackPresenter implements OrderFeedbackContract {

  bool isWorking = false;

  OrderFeedbackView _orderFeedbackView;

  OrderApiProvider provider;

  OrderFeedbackPresenter() {
    provider = new OrderApiProvider();
  }

  @override
  void sendFeedback(CustomerModel customer, int orderId, int rating, String message) {

  }

  @override
  Future<void> loadOrderDetailsForFeedback(CustomerModel customer, int orderId) async {

    _orderFeedbackView.showLoading(true);
    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      CommandModel commandModel = await provider.loadOrderFromId(customer, orderId);
      if (commandModel != null) {
        _orderFeedbackView.inflateOrderDetails(commandModel);
      } else {
        _orderFeedbackView.systemError();
      }
    } catch(_) {
      /* Food failure */
      print("error ${_}");
      if (_ == -2) {
        _orderFeedbackView.systemError();
      } else {
        _orderFeedbackView.networkError();
      }
      isWorking = false;
    }
    isWorking = false;
  }

}