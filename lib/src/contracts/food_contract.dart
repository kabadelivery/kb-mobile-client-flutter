
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/resources/menu_api_provider.dart';

class FoodContract {

  void fetchFoodById(int foodId) {}
}

class FoodView {
  void showLoading(bool isLoading) {}
  void systemError () {}
  void networkError () {}
  void inflateFood(RestaurantFoodModel foods) {}
}


/* Food presenter */
class FoodPresenter implements FoodContract {

  bool isWorking = false;

  FoodView _foodView;

  MenuApiProvider provider;

  FoodPresenter() {
    provider = new MenuApiProvider();
  }

  set foodView(FoodView value) {
    _foodView = value;
  }

  @override
  Future fetchFoodById(int foodId) async {
    if (isWorking)
      return;
    isWorking = true;
    _foodView.showLoading(true);
    try {
      RestaurantFoodModel foodModel = await provider.fetchFoodDetailsWithId(foodId);
      // also get the restaurant entity here.
      _foodView.inflateFood(foodModel);
    } catch (_) {
      /* Food failure */
      print("error ${_}");
      if (_ == -2) {
        _foodView.systemError();
      } else {
        _foodView.networkError();
      }
      isWorking = false;
    }
  }

}