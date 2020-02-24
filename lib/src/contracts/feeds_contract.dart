
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/FeedModel.dart';
import 'package:kaba_flutter/src/resources/feed_provider.dart';
import 'package:kaba_flutter/src/resources/menu_api_provider.dart';

class FeedContract {

//  void Feed (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchFeed(CustomerModel customer) {}
}

class FeedView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateFeed(List<FeedModel> feeds) {}
}


/* Feed presenter */
class FeedPresenter implements FeedContract {

  bool isWorking = false;

  FeedView _feedView;

  FeedApiProvider provider;

  FeedPresenter() {
    provider = new FeedApiProvider();
  }

  set feedView(FeedView value) {
    _feedView = value;
  }

  @override
  Future fetchFeed(CustomerModel customer) async {
    if (isWorking)
      return;
    isWorking = true;
    _feedView.showLoading(true);
    try {
      List<FeedModel> feeds = await provider.fetchFeedList(customer);
      // also get the restaurant entity here.
      _feedView.inflateFeed(feeds);
    } catch (_) {
      /* Feed failure */
      print("error ${_}");
      if (_ == -2) {
        _feedView.systemError();
      } else {
        _feedView.networkError();
      }
      isWorking = false;
    }
  }

}