
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/resources/feed_provider.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class FeedContract {

//  void Feed (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
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
      xrint("error ${_}");
      if (_ == -2) {
        _feedView.systemError();
      } else {
        _feedView.networkError();
      }
      isWorking = false;
    }
  }

}