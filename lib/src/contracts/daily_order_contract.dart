
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/resources/commands_api_provider.dart';
import 'package:KABA/src/resources/order_api_provider.dart';

class DailyOrderContract {

  void loadDailyOrders(CustomerModel customerModel) {}
//  void login (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void checkOpeningStateOf(CustomerModel customer, RestaurantModel restaurant) {}
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
  Future<void> loadDailyOrders(CustomerModel customer) async {

    if (isWorking)
      return;
    isWorking = true;
    _dailyOrderView.showLoading(true);
    try {
      List<CommandModel> commands = await provider.fetchDailyOrders(customer);
      // also get the restaurant entity here.
      _dailyOrderView.showLoading(false);
      _dailyOrderView.inflateOrder(commands);
    } catch (_) {
      /* BestSeller failure */
      _dailyOrderView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _dailyOrderView.systemError();
      } else {
        _dailyOrderView.networkError();
      }
    }
    isWorking = false;

  }

  

}