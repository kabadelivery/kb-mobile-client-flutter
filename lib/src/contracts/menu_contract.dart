
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/RestaurantSubMenuModel.dart';
import 'package:KABA/src/resources/menu_api_provider.dart';
import 'package:KABA/src/resources/order_api_provider.dart';

class MenuContract {

//  void login (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchMenuWithRestaurantId(int restaurantId) {}
  void fetchMenuWithFoodId (int foodId) {}
  fetchMenuWithMenuId(int menuId) {}
}

class MenuView {
  void showLoading(bool isLoading) {}
  /* void loginSuccess () {}
  void loginFailure (String message) {}*/
  void systemError () {}
  void networkError () {}
  void inflateMenu (RestaurantModel restaurant, List<RestaurantSubMenuModel> data) {}
  void highLightFood(int menuId, int foodId) {}
}


/* login presenter */
class MenuPresenter implements MenuContract {

  bool isWorking = false;

  MenuView _menuView;

  MenuApiProvider provider;

  MenuPresenter() {
    provider = new MenuApiProvider();
  }

  set menuView(MenuView value) {
    _menuView = value;
  }

  @override
  Future fetchMenuWithRestaurantId(int restaurantId) async {
    if (isWorking)
      return;
    isWorking = true;
    _menuView.showLoading(true);
    try {
      Map<String, dynamic> res = await provider.fetchRestaurantMenuList(restaurantId);
      // also get the restaurant entity here.
      _menuView.inflateMenu(res["restaurant"], res["menus"]);
    } catch (_) {
      /* login failure */
      print("error ${_}");
      if (_ == -2) {
        _menuView.systemError();
      } else {
        _menuView.networkError();
      }
      isWorking = false;
    }
  }



  Future<void> fetchMenuWithMenuId(int menuId) async {
    if (isWorking)
      return;
    isWorking = true;
    _menuView.showLoading(true);
    try {
      Map<String, dynamic> res = await provider.fetchRestaurantMenuListWithMenuId(menuId);
      // also get the restaurant entity here.
      _menuView.showLoading(false);
      _menuView.inflateMenu(res["restaurant"], res["menus"]);
    } catch (_) {
      /* login failure */
      _menuView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _menuView.systemError();
      } else {
        _menuView.networkError();
      }
      isWorking = false;
    }
  }

  @override
  Future<void> fetchMenuWithFoodId(int foodId) async {
    if (isWorking)
      return;
    isWorking = true;
    _menuView.showLoading(true);
    try {
      Map<String, dynamic> res = await provider.fetchRestaurantMenuListWithFoodId(foodId);
      int menuId = 0;
      // also get the restaurant entity here.
      _menuView.showLoading(false);
      RestaurantFoodModel food = res["food"];
      _menuView.highLightFood(int.parse(food.menu_id),foodId);
      _menuView.inflateMenu(res["restaurant"], res["menus"]);
    } catch (_) {
      /* login failure */
      _menuView.showLoading(false);
      print("error ${_}");
      if (_ == -2) {
        _menuView.systemError();
      } else {
        _menuView.networkError();
      }
      isWorking = false;
    }
  }

}