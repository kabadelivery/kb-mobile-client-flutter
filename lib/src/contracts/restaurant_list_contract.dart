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

import '../../test/utils/testRandomPosition.dart';
import '../utils/functions/map.dart';

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
      CustomerModel customer, String type, Position? position,
      [bool silently = false, String? filter_key])
  async {
    if (isWorking && position == null) return;
    isWorking = true;
    xrint("made it to fetchShopList, filter_key : $filter_key");
    if (!silently) _restaurantListView.loadRestaurantListLoading(true);
    try {
      Position currentPosition = await Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).first;
      //currentPosition = generateRandomPositionAroundLome();
      Map<String, dynamic> data = await provider.fetchShopList(customer, type, currentPosition);
      List<ShopModel> restaurants = [];
      var configuration = await CustomerUtils.getShopListFilterConfiguration();
      CustomerModel user = await CustomerUtils.getCustomer();
      restaurants = await compute(sortOutRestaurantList, {
        "data": data,
        "position": currentPosition,
        "is_email_account": user.username == null
            ? false
            : (customer.username!.contains("@") ? true : false),
        "filter_key": filter_key,
        "filter_configuration": configuration
      });


      // save billing locally so that the other stuffs can use it.
      String billing = json.encode(data["billing"]);

      CustomerUtils.updateBillingLocally(billing);

      xrint("restaurants in fetchShopList $restaurants");

      _restaurantListView.loadRestaurantListLoading(false);

      // order list
      // restaurants = restaurants..sort((restA, restB) => _getDifferenceMeandRestaurant());
      // compare distance between i and the restaurant
      xrint('made it to inflateRestaurants');
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
      if (filter_key.trim() != "")
        shops = _filteredData(shops, filter_key);
      _restaurantListView.loadRestaurantListLoading(false);
      _restaurantListView.inflateFilteredRestaurants(shops, filter_key);
    } catch (e) {}
    isWorking = false;
    _restaurantListView.loadRestaurantListLoading(false);
  }
}

FutureOr<List<ShopModel>> sortOutRestaurantList(Map<String, dynamic> data) async {
  try {
    final Iterable rawList = data["data"]["data"];
    final bool isEmailAccount = data["is_email_account"];
    final Position userPosition = data["position"];
    final Map<String, dynamic> config = data["filter_configuration"];

    List<ShopModel> shops = rawList.map((resto) => ShopModel.fromJson(resto)).toList();
    if (config["opened_filter"] == true) {
      shops = shops.where((shop) => shop.is_open == 1 && shop.coming_soon == 0).toList();
    }
    final List<dynamic> billingData =
    data["data"]["billing"][isEmailAccount ? "email" : "phoneNumber"];
    final Map<String, String> billingMap = {};
    for (var entry in billingData) {
      int from = int.parse(entry["from"]);
      int to = int.parse(entry["to"]);
      String value = entry["value"].toString();
      for (int i = from; i < to; i++) {
        billingMap["$i"] = value;
      }
    }
    double parseDistance(String? distance) {
      if (distance == null || distance.contains(">")) return 9999.0;
      return double.tryParse(distance) ?? 9999.0;
    }

    for (final shop in shops) {
      final double dist = Utils.locationDistance(userPosition, shop);
      shop.distance = dist.toStringAsFixed(2);
      shop.delivery_pricing = _getShippingPrice(shop.distance!, billingMap);
    }
    const double maxDistanceKm = 20;

    shops = shops.where((shop) {
      final d = double.tryParse(shop.distance ?? "");
      return d != null && d <= maxDistanceKm;
    }).toList();


    shops.sort((a, b) =>
        parseDistance(a.distance).compareTo(parseDistance(b.distance)));
    return shops;
  } catch (e, stacktrace) {
    print("Error in sortOutRestaurantList: $e");
    print(stacktrace);
    return [];
  }
}
List<ShopModel> _filteredData(List<ShopModel> data, String filterKey) {
  List<ShopModel> result = [];

  final search = normalize(filterKey.trim());

  for (var restaurant in data) {
    final name = normalize(restaurant.name ?? '');

    if (name.contains(search)) {
      result.add(restaurant);
    }
  }

  return result;
}

String normalize(String input){
  return removeAccentFromString(input)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
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
