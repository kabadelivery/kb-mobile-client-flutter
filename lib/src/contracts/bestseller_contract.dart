
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
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

    /* fetch the one store in the local file first */

    if (isWorking)
      return;
    isWorking = true;


    CustomerUtils.getOldBestSellerPage().then((pageJson) async {

      _bestSellerView.showLoading(true);
      try {
        if (pageJson != null) {
          Iterable lo = mJsonDecode(pageJson)["data"];
          List<BestSellerModel> bestSellers = lo?.map((bs) => BestSellerModel.fromJson(bs))?.toList();
          /* send these to json */
          _bestSellerView.inflateBestSeller(bestSellers);
        } else {
          _bestSellerView.showLoading(true);
        }
      } catch(_){
        xrint(_);
      }

      try {
        String bsellers_json = await provider.fetchBestSellerList();
       // save best seller json
        // also get the restaurant entity here.
        Iterable lo = mJsonDecode(bsellers_json)["data"];
        List<BestSellerModel> bestSellers = lo?.map((bs) => BestSellerModel.fromJson(bs))?.toList();
        /* send these to json */
        CustomerUtils.saveBestSellerPage(bsellers_json);
        _bestSellerView.inflateBestSeller(bestSellers);
        isWorking = false;
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
    });
  }

}