import 'dart:async';
import 'dart:convert';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantListContract {
//  void RestaurantList (String password, String phoneCode){}
//  Map<ShopProductModel, int> food_selected, adds_on_selected;
//  void computeBilling (CustomerModel customer, Map<ShopProductModel, int> foods, DeliveryAddressModel address){}
  void fetchShopList(CustomerModel customer, String type, Position position,
      [bool silently = false, String? filter_key]) async {}

  void filterShopList(List<ShopModel> shops, String filter_key) async {}
}

class RestaurantListView {
  void systemError([bool? silently]) {}

  void networkError([bool? silently]) {}

  void loadRestaurantListLoading(bool isLoading) {}

  void inflateRestaurants(List<ShopModel> restaurants) {}

  void inflateFilteredRestaurants(List<ShopModel> shops, String sKey) {}
}

/* RestaurantList presenter */
class RestaurantListPresenter implements RestaurantListContract {
  bool isWorking = false;

  RestaurantListView _restaurantListView;

  late RestaurantApiProvider provider;

  RestaurantListPresenter(this._restaurantListView) {
    provider = new RestaurantApiProvider();
  }

  set restaurantListView(RestaurantListView value) {
    _restaurantListView = value;
  }

  @override
  Future<void> fetchShopList(
      CustomerModel customer, String type, Position position,
      [bool silently = false, String? filter_key]) async {
    if (isWorking && position == null) return;
    isWorking = true;
    if (!silently) _restaurantListView.loadRestaurantListLoading(true);

    // load from cache the last request while looking for the newest set of data

    try {
      Map<String, dynamic> data =
          await provider.fetchShopList(customer, type, position);
      // save data if it contains restaurants, then the filtering will be done on it
      List<ShopModel> restaurants = [];

      var configuration = await CustomerUtils.getShopListFilterConfiguration();

      if (data["data"]?.length > 0)
        restaurants = await compute(sortOutRestaurantList, {
          "data": data,
          "position": position,
          "is_email_account": customer == null || customer?.username == null
              ? false
              : (customer.username!.contains("@") ? true : false),
          "filter_key": filter_key,
          "filter_configuration": configuration
        });

      // save billing locally so that the other stuffs can use it.
      String billing = json.encode(data["billing"]);

      CustomerUtils.updateBillingLocally(billing);

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

  @override
  Future<void> filterShopList(List<ShopModel> shops, String filter_key) async {
    if (isWorking) return;

    isWorking = true;
    _restaurantListView.loadRestaurantListLoading(true);

    try {
      await Future.delayed(Duration(milliseconds: 1000), () => {});
      if (filter_key != null && filter_key?.trim() != "")
        shops = _filteredData(shops, filter_key);
      _restaurantListView.loadRestaurantListLoading(false);
      _restaurantListView.inflateFilteredRestaurants(shops, filter_key);
    } catch (e) {}
    isWorking = false;
    _restaurantListView.loadRestaurantListLoading(false);
  }
}

FutureOr<List<ShopModel>> sortOutRestaurantList(Map<String, dynamic> data) {
  Iterable lo = data["data"]["data"] /*["resto"]*/;

  List<ShopModel>? tmp = lo?.map((resto) => ShopModel.fromJson(resto))?.toList();

  // remove the 79 & 80
  List<ShopModel> tf = List.empty(growable: true);

  try {
    bool is_email_account = data["is_email_account"];
    Position tmpPosition = data["position"];
    String filter_key = data["filter_key"];
    Map<String, dynamic> configuration = data["filter_configuration"];

    xrint("before filtered ${tmp?.length}");
    /* filter the data */
    /* if (filter_key != null && filter_key?.trim() != "")
      tmp = _filteredData(tmp, filter_key);
    xrint("after filtered ${tmp?.length}");*/

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
      // we can store the billing array locally

      int indexOf79 = -1;
      int indexOf80 = -1;

      // filter tmp with only restaurant that are opened or all
      tmp = tmp!.where((e) {
        if (configuration["opened_filter"] == true)
          return e.is_open == 1 && e.coming_soon == 0;
        return true;
      }).toList();

      /* make sure the distances and shipping prices are computed */
      for (int s = 0; s < tmp.length; s++) {
        tmp[s].distance = (Utils.locationDistance(tmpPosition, tmp[s]) > 100
            ? "> 100"
            : Utils.locationDistance(tmpPosition, tmp[s])?.toString())!;
        tmp[s].delivery_pricing =
            _getShippingPrice(tmp[s].distance!, myBillingArray)!;
        if (tmp[s].id == 79) indexOf79 = s;
        if (tmp[s].id == 80) indexOf80 = s;
      }

      // add elements
      /*   tf.add(tmp[indexOf79]);
      tf.add(tmp[indexOf80]);*/
      // remote from tmp
      /*     tmp.removeAt(indexOf80);
      tmp.removeAt(indexOf79);*/

      // if (tmp[s].id == 79 || tmp[s].id == 80) {
      //   tf.add(tmp[s]);
      //   tmp.removeAt(s);
      // }

      // do the sort_out using the distances as well
      tf.sort((restA, restB) => (
              // try to put these 2 restaurants above
              double.parse(restA.distance!) * 1000 -
                  double.parse(restB.distance!) * 1000)
          .toInt());
      /* tmp =*/
      tmp.sort((restA, restB) => (
// try to put these 2 restaurants above
              double.parse(restA.distance!) * 1000 -
                  double.parse(restB.distance!) * 1000)
          .toInt());
    }

    tf.addAll(tmp!);
    return tf;
  } catch (_) {
    xrint(_.toString());
    return tmp!;
  }
}

_filteredData(List<ShopModel> data, String filter_key) {
  List<ShopModel> d =[];

  for (var restaurant in data) {
    String sentence =
        removeAccentFromString("${restaurant.name}".toLowerCase());
    String sentence1 = removeAccentFromString(filter_key.trim()).toLowerCase();

    if (sentence.contains(sentence1)) {
      d.add(restaurant);
    }
  }
  return d;
}

String removeAccentFromString(String sentence) {
  String sentence1 = sentence
      .replaceAll(new RegExp(r'é'), "e")
      .replaceAll(new RegExp(r'è'), "e")
      .replaceAll(new RegExp(r'ê'), "e")
      .replaceAll(new RegExp(r'ë'), "e")
      .replaceAll(new RegExp(r'ē'), "e")
      .replaceAll(new RegExp(r'ė'), "e")
      .replaceAll(new RegExp(r'ę'), "e")
      .replaceAll(new RegExp(r'à'), "a")
      .replaceAll(new RegExp(r'á'), "a")
      .replaceAll(new RegExp(r'â'), "a")
      .replaceAll(new RegExp(r'ä'), "a")
      .replaceAll(new RegExp(r'æ'), "a")
      .replaceAll(new RegExp(r'ã'), "a")
      .replaceAll(new RegExp(r'ā'), "a")
      .replaceAll(new RegExp(r'ô'), "o")
      .replaceAll(new RegExp(r'ö'), "o")
      .replaceAll(new RegExp(r'ò'), "o")
      .replaceAll(new RegExp(r'ó'), "o")
      .replaceAll(new RegExp(r'œ'), "o")
      .replaceAll(new RegExp(r'ø'), "o")
      .replaceAll(new RegExp(r'ō'), "o")
      .replaceAll(new RegExp(r'õ'), "o")
      .replaceAll(new RegExp(r'î'), "i")
      .replaceAll(new RegExp(r'ï'), "i")
      .replaceAll(new RegExp(r'í'), "i")
      .replaceAll(new RegExp(r'ī'), "i")
      .replaceAll(new RegExp(r'į'), "i")
      .replaceAll(new RegExp(r'ì'), "i")
      .replaceAll(new RegExp(r'û'), "u")
      .replaceAll(new RegExp(r'ü'), "u")
      .replaceAll(new RegExp(r'ù'), "u")
      .replaceAll(new RegExp(r'ú'), "u")
      .replaceAll(new RegExp(r'ū'), "u")

      //

      .replaceAll(new RegExp(r'É'), "e")
      .replaceAll(new RegExp(r'È'), "e")
      .replaceAll(new RegExp(r'Ê'), "e")
      .replaceAll(new RegExp(r'Ë'), "e")
      .replaceAll(new RegExp(r'Ē'), "e")
      .replaceAll(new RegExp(r'Ė'), "e")
      .replaceAll(new RegExp(r'Ę'), "e")
      .replaceAll(new RegExp(r'À'), "a")
      .replaceAll(new RegExp(r'Á'), "a")
      .replaceAll(new RegExp(r'Â'), "a")
      .replaceAll(new RegExp(r'Ä'), "a")
      .replaceAll(new RegExp(r'AÆ'), "a")
      .replaceAll(new RegExp(r'Ã'), "a")
      .replaceAll(new RegExp(r'Å'), "a")
      .replaceAll(new RegExp(r'Ā'), "a")
      .replaceAll(new RegExp(r'Ô'), "o")
      .replaceAll(new RegExp(r'Ö'), "o")
      .replaceAll(new RegExp(r'Ò'), "o")
      .replaceAll(new RegExp(r'Ó'), "o")
      .replaceAll(new RegExp(r'Œ'), "o")
      .replaceAll(new RegExp(r'Ø'), "o")
      .replaceAll(new RegExp(r'Ō'), "o")
      .replaceAll(new RegExp(r'Õ'), "o")
      .replaceAll(new RegExp(r'Î'), "i")
      .replaceAll(new RegExp(r'Ï'), "i")
      .replaceAll(new RegExp(r'Í'), "i")
      .replaceAll(new RegExp(r'Ī'), "i")
      .replaceAll(new RegExp(r'Į'), "i")
      .replaceAll(new RegExp(r'Ì'), "i")
      .replaceAll(new RegExp(r'Û'), "u")
      .replaceAll(new RegExp(r'Ü'), "u")
      .replaceAll(new RegExp(r'Ù'), "u")
      .replaceAll(new RegExp(r'Ú'), "u")
      .replaceAll(new RegExp(r'Ū'), "u")
      .replaceAll(new RegExp(r"'"), "")
      .replaceAll(new RegExp(r" "), "");

  return sentence1;
}

String? _getShippingPrice(String distance, Map<String, String> myBillingArray) {
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
