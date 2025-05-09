/* login contract */
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsViewerContract {

  void loadRestaurantFromId (int restaurantId/*, int DESTINATION*/){}
  void loadFoodFromId (int foodId) {}
}

class AdsViewerView {
  void showLoading(bool isLoading) {}

  void updateRestaurantForDetails(ShopModel ShopModel) {}
  void updateRestaurantForMenu(ShopModel ShopModel) {}
  void updateFood(ShopProductModel foodModel) {}

  void requestFailure (String message) {}
}


/* ads presenter */
class AdsViewerPresenter implements AdsViewerContract {

  bool isWorking = false;

  RestaurantApiProvider provider;

  AdsViewerView _adsViewerView;

  AdsViewerPresenter () {
    provider = new RestaurantApiProvider();
  }

  set adsViewerView(AdsViewerView value) {
    _adsViewerView = value;
  }

  @override
  Future<void> loadRestaurantFromId(int restaurantId, /*int DESTINATIONcan be details or menu*/) async {

    _adsViewerView.showLoading(true);
    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      ShopModel shopModel = await provider.loadRestaurantFromId(restaurantId/*, DESTINATION*/);
      if (ShopModel != null) {
//       if (DESTINATION == 1)
        _adsViewerView.updateRestaurantForDetails(shopModel);
//       else if (DESTINATION == 2) {
//         _adsViewerView.updateRestaurantForMenu(ShopModel);
//       }
      }
    } catch(_) {
      _adsViewerView.requestFailure("request failure");
    }
    isWorking = false;
  }

  @override
  Future<void> loadFoodFromId(int foodId) async {

    _adsViewerView.showLoading(true);
    /* make network request, create a lib that makes network request. */
    if (isWorking)
      return;
    isWorking = true;
    try {
      ShopProductModel foodModel = await provider.loadFoodFromId(foodId);
      if (foodModel != null)
        _adsViewerView.updateFood(foodModel);
    } catch(_) {
      _adsViewerView.requestFailure("request failure");
    }
    isWorking = false;
  }

}