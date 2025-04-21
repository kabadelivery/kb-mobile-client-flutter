
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class OrderFeedbackContract {

  void loadOrderDetailsForFeedback(CustomerModel customer, int orderId) {}
  void sendFeedback(CustomerModel customer, int orderId, int rating, String message){}
}

class OrderFeedbackView {

  void sendFeedbackError (int errorCode) {}
  void sendFeedbackSuccess() {}

  void systemError () {}
  void networkError () {}

  void showLoading(bool isLoading) {}

  void inflateOrderDetails(CommandModel commandModel) {}

  void sendFeedBackLoading(bool isSendingFeedback) {}
}


/* login presenter */
class OrderFeedbackPresenter implements OrderFeedbackContract {

  bool isWorking = false;

  OrderFeedbackView _orderFeedbackView;

  late OrderApiProvider provider;

  OrderFeedbackPresenter(this._orderFeedbackView) {
    provider = new OrderApiProvider();
  }

  @override
  Future<void> sendFeedback(CustomerModel customer, int orderId, int rating, String message) async {

    //
    _orderFeedbackView.sendFeedBackLoading(true);
    if (isWorking)
      return;
    isWorking = true;
    try {
      int errorCode = await provider.sendFeedback(customer, orderId, rating, message);
      _orderFeedbackView.sendFeedBackLoading(false);
      if (errorCode == 0) {
        _orderFeedbackView.sendFeedbackSuccess();
      } else {
        _orderFeedbackView.sendFeedbackError(errorCode);
      }
    } catch(_) {
      /* Food failure */
      _orderFeedbackView.sendFeedBackLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _orderFeedbackView.sendFeedbackError(-1);
      } else {
        _orderFeedbackView.sendFeedbackError(-1);
      }
      isWorking = false;
    }
    isWorking = false;
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
      _orderFeedbackView.showLoading(false);
      if (commandModel != null) {
        _orderFeedbackView.inflateOrderDetails(commandModel);
      } else {
        _orderFeedbackView.systemError();
      }
    } catch(_) {
      /* Food failure */
      xrint("error ${_}");
      if (_ == -2) {
        _orderFeedbackView.systemError();
      } else {
        _orderFeedbackView.networkError();
      }
      isWorking = false;
    }
    isWorking = false;
  }

  set orderFeedbackView(OrderFeedbackView value) {
    _orderFeedbackView = value;
  }

}