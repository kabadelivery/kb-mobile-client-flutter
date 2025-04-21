
import 'package:KABA/src/models/CustomerCareChatMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/customerchat_provider.dart';
import 'package:KABA/src/xrint.dart';

class CustomerCareChatContract {

//  void CustomerCareChat (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchCustomerCareChat(CustomerModel customer) {}
  void sendMessageToCustomerCareChat (CustomerModel customer, String message) {}
}

class CustomerCareChatView {
  void showLoading(bool isLoading) {}
  void sendMessageLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void sendMessagesystemError() {}
  void sendMessagenetworkError() {}
  void inflateCustomerCareChat(List<CustomerCareChatMessageModel> CustomerCareChats) {}
  void chatSuccessfullySent(String message) {}
}


/* CustomerCareChat presenter */
class CustomerCareChatPresenter implements CustomerCareChatContract {

  bool isWorking = false;

  CustomerCareChatView _customerCareChatView;

  late CustomerCareChatApiProvider provider;

  CustomerCareChatPresenter(this._customerCareChatView) {
    provider = new CustomerCareChatApiProvider();
  }

  set customerCareChatView(CustomerCareChatView value) {
    _customerCareChatView = value;
  }

  @override
  Future fetchCustomerCareChat(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _customerCareChatView.showLoading(true);
    try {
      List<CustomerCareChatMessageModel>? CustomerCareChats = (await provider.fetchCustomerChatList(customer)) as List<CustomerCareChatMessageModel>?;
      // also get the restaurant entity here.
      _customerCareChatView.showLoading(false);
      _customerCareChatView.inflateCustomerCareChat(CustomerCareChats!);
    } catch (_) {
      /* CustomerCareChat failure */
      xrint("error ${_}");
      if (_ == -2) {
        _customerCareChatView.systemError();
      } else {
        _customerCareChatView.networkError();
      }
    }
    isWorking = false;
  }

  @override
  Future<void> sendMessageToCustomerCareChat(CustomerModel customer, String message) async {
    if (isWorking)
      return;
    isWorking = true;
    _customerCareChatView.sendMessageLoading(true);
    try {
      int errorCode = await provider.sendMessageToCCare(customer, message);
      // also get the restaurant entity here.
      _customerCareChatView.sendMessageLoading(false);
      if (errorCode == 0)
        _customerCareChatView.chatSuccessfullySent(message);
      else
        _customerCareChatView.sendMessagesystemError();

    } catch (_) {
      /* CustomerCareChat failure */
      _customerCareChatView.sendMessageLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _customerCareChatView.sendMessagesystemError();
      } else {
        _customerCareChatView.sendMessagenetworkError();
      }
    }
    isWorking = false;
  }

}