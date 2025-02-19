
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/resources/commands_api_provider.dart';
import 'package:KABA/src/resources/order_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class DailyOrderContract {

  void loadDailyOrders(CustomerModel customerModel) {}
//  void login (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void checkOpeningStateOf(CustomerModel customer, ShopModel restaurant) {}
}

class DailyOrderView {

  void systemError () {}
  void networkError () {}
  void showLoading(bool isLoading) {}
  void inflateOrder(List<CommandModel> commands) {}
}


/* login presenter */
class DailyOrderPresenter implements DailyOrderContract {

  bool isWorking = false;

  DailyOrderView _dailyOrderView;

  CommandsApiProvider provider;

  DailyOrderPresenter() {
    provider = new CommandsApiProvider();
  }

  set dailyOrderView(DailyOrderView value) {
    _dailyOrderView = value;
  }

  @override
  Future<void> loadDailyOrders(CustomerModel customer,
      {bool is_out_of_app_order = false}) async {

    if (isWorking)
      return;
    isWorking = true;
    _dailyOrderView.showLoading(true);
    try {
      List<CommandModel> commands = await provider.fetchDailyOrders(customer,is_out_of_app_order: is_out_of_app_order);
      // also get the restaurant entity here.
      _dailyOrderView.showLoading(false);
      _dailyOrderView.inflateOrder(commands);
    } catch (_,stackTrace) {
      /* BestSeller failure */
      _dailyOrderView.showLoading(false);
      xrint("error ${_}");
      print("StackTrace: $stackTrace");
      if (_ == -2) {
        _dailyOrderView.systemError();
      } else {
        _dailyOrderView.networkError();
      }
    }
    isWorking = false;

  }

  

}