import 'dart:async';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantListContract {
//  void RestaurantList (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchRestaurantList(CustomerModel customer, String type, Position position,
      [bool silently = false]) async {}
}

class RestaurantListView {
  void systemError([bool silently]) {}

  void networkError([bool silently]) {}

  void loadRestaurantListLoading(bool isLoading) {}

  void inflateRestaurants(List<ShopModel> restaurants) {}
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
  Future<void> fetchRestaurantList(CustomerModel customer, String type, Position position,
      [bool silently = false]) async {
    if (isWorking && position == null) return;
    isWorking = true;
    if (!silently) _restaurantListView.loadRestaurantListLoading(true);
    try {
      dynamic data = await provider.fetchRestaurantList(customer, type, position);

      // "location": "6.196422: 1.201180",
      List<ShopModel> restaurants = await compute(sortOutRestaurantList, {
        "data": data,
        "position": position,
        "is_email_account": customer == null || customer?.username == null
            ? false
            : (customer.username.contains("@") ? true : false)
      });

      xrint(restaurants);

      _restaurantListView.loadRestaurantListLoading(false);

      // order list
      // restaurants = restaurants..sort((restA, restB) => _getDifferenceMeandRestaurant());
      // compare distance between i and the restaurant
      _restaurantListView.inflateRestaurants(restaurants);
    } catch (_) {
      /* RestaurantList failure */
      xrint("error ${_}");
      _restaurantListView.loadRestaurantListLoading(false);
      if (_.toString().contains("-2")) {
        _restaurantListView.systemError(silently);
      } else {
        _restaurantListView.networkError(silently);
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
//     List<ShopProductModel> foods = await provider.fetchRestaurantListFromTag(tag);
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

FutureOr<List<ShopModel>> sortOutRestaurantList(Map<String, dynamic> data) {
  Iterable lo = data["data"]["resto"];

  List<ShopModel> tmp = lo?.map((resto) => ShopModel.fromJson(resto))?.toList();

  // remove the 79 & 80
  List<ShopModel> tf = List.empty(growable: true);

  try {
    bool is_email_account = data["is_email_account"];
    Position tmpPosition = data["position"];

    if (tmpPosition != null) {
      Map<String, String> myBillingArray = Map();
      // prepare billing array
      List<dynamic> lBilling =
          data["data"]["billing"][is_email_account ? "email" : "phoneNumber"];
      for (int s = 0; s < lBilling.length; s++) {
        int from = int.parse(lBilling[s]["from"]);
        int to = int.parse(lBilling[s]["to"]);
        int value = int.parse(lBilling[s]["value"]);
        // we take upper border
        myBillingArray["${from}"] = "${value}";
        if (to - from > 1) {
          for (int i = from + 1; i < to; i++) {
            myBillingArray["${i}"] = "${value}";
          }
        }
      }

      xrint(myBillingArray);

      int indexOf79 = -1;
      int indexOf80 = -1;

      for (int s = 0; s < tmp.length; s++) {
        // restaurants[s].distanceBetweenMeandRestaurant = Utils.locationDistance(position, restaurants[s]);
        tmp[s].distance =
            Utils.locationDistance(tmpPosition, tmp[s]).toString();
        // according to the distance, we get the matching delivery fees
        // i dont want to make another loop
        tmp[s].delivery_pricing =
            _getShippingPrice(tmp[s].distance, myBillingArray);

        if (tmp[s].id == 79) indexOf79 = s;
        if (tmp[s].id == 80) indexOf80 = s;
      }

      // add elements
      tf.add(tmp[indexOf79]);
      tf.add(tmp[indexOf80]);
      // remote from tmp
      tmp.removeAt(indexOf80);
      tmp.removeAt(indexOf79);

      // if (tmp[s].id == 79 || tmp[s].id == 80) {
      //   tf.add(tmp[s]);
      //   tmp.removeAt(s);
      // }

      // do the sort_out using the distances as well
      tf.sort((restA, restB) => (
              // try to put these 2 restaurants above
              double.parse(restA.distance) * 1000 -
                  double.parse(restB.distance) * 1000)
          .toInt());
      /* tmp =*/
      tmp.sort((restA, restB) => (
// try to put these 2 restaurants above
              double.parse(restA.distance) * 1000 -
                  double.parse(restB.distance) * 1000)
          .toInt());
    }

    tf.addAll(tmp);
    return tf;
  } catch (_) {
    xrint(_.toString());
    return tmp;
  }
}

String _getShippingPrice(String distance, Map<String, String> myBillingArray) {
  try {
    int distanceInt =
        int.parse(!distance.contains(".") ? distance : distance.split(".")[0]);
    if (myBillingArray["$distanceInt"] == null) {
      return "~";
    } else {
      return myBillingArray["$distanceInt"];
    }
  } catch (_) {
    xrint(_);
    return "~";
  }
}
