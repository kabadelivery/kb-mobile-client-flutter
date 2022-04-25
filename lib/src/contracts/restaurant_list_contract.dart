
import 'dart:async';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantListContract {

//  void RestaurantList (String password, String phoneCode){}
//  Map<RestaurantFoodModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address){}
  void fetchRestaurantList(CustomerModel customer, Position position, [bool silently = false]) async {}
}

class RestaurantListView {

  void systemError () {}
  void networkError () {}
  void loadRestaurantListLoading(bool isLoading) {}
  void inflateRestaurants(List<RestaurantModel> restaurants) {}
}


/* RestaurantList presenter */
class RestaurantListPresenter implements RestaurantListContract {

  bool isWorking = false;

  RestaurantListView _restaurantListView;

  RestaurantApiProvider provider;

  RestaurantListPresenter() {
    provider = new RestaurantApiProvider();
  }

  set restaurantListView(RestaurantListView value) {
    _restaurantListView = value;
  }

  @override
  Future<void> fetchRestaurantList(CustomerModel customer, Position position,
      [bool silently = false]) async {
    if (isWorking)
      return;
    isWorking = true;
    if (!silently)
      _restaurantListView.loadRestaurantListLoading(true);
    try {
      List<RestaurantModel> restaurants = await provider.fetchRestaurantList(
          customer, position);
      _restaurantListView.loadRestaurantListLoading(false);


      // "location": "6.196422: 1.201180",
      restaurants = await compute(sortOutRestaurantList,
          {"restaurants": restaurants, "position": position});

      // order list
      // restaurants = restaurants..sort((restA, restB) => _getDifferenceMeandRestaurant());
      // compare distance between i and the restaurant
      _restaurantListView.inflateRestaurants(restaurants);
    } catch (_) {
      /* RestaurantList failure */
      _restaurantListView.loadRestaurantListLoading(false);
      xrint("error ${_}");
      if (_ == -2) {
        _restaurantListView.systemError();
      } else {
        _restaurantListView.networkError();
      }
    }
    isWorking = false;
  }

// @override
// Future fetchRestaurantListFromTag(String tag) async {
//   if (isWorking)
//     return;
//   isWorking = true;
//   _restaurantListView.searchMenuShowLoading(true);
//   try {
//     List<RestaurantFoodModel> foods = await provider.fetchRestaurantListFromTag(tag);
//     _restaurantListView.searchMenuShowLoading(false);
//     _restaurantListView.inflateFoodsProposal(foods);
//   } catch (_) {
//     /* RestaurantList failure */
//     _restaurantListView.searchMenuShowLoading(false);
//     xrint("error ${_}");
//     if (_ == -2) {
//       _restaurantListView.searchMenuSystemError();
//     } else {
//       _restaurantListView.searchMenuNetworkError();
//     }
//   }
//   isWorking = false;
// }
}

FutureOr<List<RestaurantModel>> sortOutRestaurantList(Map<String, Object> data) {

  List<RestaurantModel> tmp = data["restaurants"];
  Position tmpPosition = data["position"];

  if (tmpPosition != null) {
    for (int s = 0; s < tmp.length; s++) {
      // restaurants[s].distanceBetweenMeandRestaurant = Utils.locationDistance(position, restaurants[s]);
      tmp[s].distance = Utils.locationDistance(tmpPosition, tmp[s]).toString();
      tmp[s].delivery_pricing = "~_~";
    }
    // do the sort_out using the distances as well
   /* tmp =*/ tmp.sort((restA, restB) => (
   restA.id == 79 || restA.id == 80 ? -10000 : // try to put these 2 restaurants above
       double.parse(restA.distance)*1000 - double.parse(restB.distance)*1000
    ).toInt()
    );
  }
  return tmp;
}