
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/xrint.dart';

class BestSellerContract {

//  void BestSeller (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchBestSeller() {}
}

class BestSellerView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateBestSeller(List<BestSellerModel> bSellers) {}
}


/* BestSeller presenter */
class BestSellerPresenter implements BestSellerContract {

  bool isWorking = false;

  BestSellerView _bestSellerView;

  MenuApiProvider provider;

  BestSellerPresenter() {
    provider = new MenuApiProvider();
  }

  set bestSellerView(BestSellerView value) {
    _bestSellerView = value;
  }

  @override
  Future fetchBestSeller() async {
    if (isWorking)
      return;
    isWorking = true;
    _bestSellerView.showLoading(true);
    try {
      List<BestSellerModel> bsellers = await provider.fetchBestSellerList();
      // also get the restaurant entity here.
      _bestSellerView.inflateBestSeller(bsellers);
    } catch (_) {
      /* BestSeller failure */
      xrint("error ${_}");
      if (_ == -2) {
        _bestSellerView.systemError();
      } else {
        _bestSellerView.networkError();
      }
      isWorking = false;
    }
  }

}