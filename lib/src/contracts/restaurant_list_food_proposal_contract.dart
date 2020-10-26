
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class RestaurantFoodProposalContract {

//  void RestaurantFoodProposal (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchRestaurantFoodProposalFromTag(String tag) async {}
}

class RestaurantFoodProposalView {
  void searchMenuShowLoading(bool isLoading) {}
  void searchMenuSystemError () {}
  void searchMenuNetworkError () {}
  void inflateFoodsProposal(List<RestaurantFoodModel> foods) {}
}


/* RestaurantFoodProposal presenter */
class RestaurantFoodProposalPresenter implements RestaurantFoodProposalContract {

  bool isWorking = false;

  RestaurantFoodProposalView _restaurantFoodProposalView;

  RestaurantApiProvider provider;

  RestaurantFoodProposalPresenter() {
    provider = new RestaurantApiProvider();
  }

  set restaurantFoodProposalView(RestaurantFoodProposalView value) {
    _restaurantFoodProposalView = value;
  }

  @override
  Future fetchRestaurantFoodProposalFromTag(String tag) async {
    if (isWorking)
      return;
    isWorking = true;
    _restaurantFoodProposalView.searchMenuShowLoading(true);
    try {
      List<RestaurantFoodModel> foods = await provider.fetchRestaurantFoodProposalFromTag(tag);
      _restaurantFoodProposalView.searchMenuShowLoading(false);
      _restaurantFoodProposalView.inflateFoodsProposal(foods);
    } catch (_) {
      /* RestaurantFoodProposal failure */
      _restaurantFoodProposalView.searchMenuShowLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _restaurantFoodProposalView.searchMenuSystemError();
      } else {
        _restaurantFoodProposalView.searchMenuNetworkError();
      }
    }
    isWorking = false;
  }

}