import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantApiProvider {
  Future<List<RestaurantSubMenuModel>> fetchRestaurantMenuList(
      ShopModel ShopModel) async {
    xrint("entered fetchRestaurantMenuList");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
          data: json.encode({'id': ShopModel.id.toString()}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo
              ?.map((comment) => RestaurantSubMenuModel.fromJson(comment))
              ?.toList();
          return restaurantSubModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /// load restaurant from Id
  Future<ShopModel> loadRestaurantFromId(
      int restaurantIdOrMenuId /*, int DESTINATION*/) async {
    xrint("entered loadRestaurantFromId");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_GET_RESTAURANT_DETAILS).toString(),
          data: json.encode({'id': restaurantIdOrMenuId}));

      xrint("001_ " + response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          ShopModel shopModel = ShopModel.fromJson(
              mJsonDecode(response.data)["data"]["restaurant"]);
          return shopModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /// load food from id
  Future<ShopProductModel> loadFoodFromId(int foodId) async {
    xrint("entered loadFoodFromId ${foodId} ");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE).toString(),
          data: json.encode({'food_id': foodId}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          ShopProductModel foodModel = ShopProductModel.fromJson(
              mJsonDecode(response.data)["data"]["food"]);
          return foodModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchRestaurantFoodProposal2FromTag(String category, String query) async {
    xrint("entered fetchRestaurantFoodProposalFromTag ${query}");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      /*   var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_SEARCH_FOOD_BY_TAG).toString(),
        data: json.encode({'tag': query}),
      );*/
      // /api/v4/search?category=food&limit=1000&search_type=product&query=riz
      Map<String, String> queryParams = {
        "search_type": "product",
        "category": "$category",
        "limit": "1000",
        "query": query
      };

      if ("all" == category) queryParams.remove("category");

      var response = await dio.get(
          Uri.parse(ServerRoutes.LINK_SHOP_LIST_V4).toString(),
          queryParameters: queryParams // json.encode({'tag': query}),
          );

      xrint(response.data.toString());
      List<ShopProductModel> foods = [];
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          if (lo == null) {
            return [];
          } else {
            // foods with restaurant inside.
            lo?.map((food_restaurant) {
              ShopProductModel f = ShopProductModel.fromJson(food_restaurant);
              f.restaurant_entity =
                  ShopModel.fromJson(food_restaurant["restaurant"]);
              foods.add(f);
            })?.toList();
            return foods;
          }
        } else
          return foods;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchRestaurantFoodProposalFromTagOld(String query) async {
    xrint("entered fetchRestaurantFoodProposalFromTag ${query}");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_SEARCH_FOOD_BY_TAG).toString(),
        data: json.encode({'tag': query}),
      );

      xrint(response.data.toString());
      List<ShopProductModel> foods = [];
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          if (lo == null) {
            return [];
          } else {
            lo?.map((food_restaurant) {
              ShopProductModel f =
                  ShopProductModel.fromJson(food_restaurant["food"]);
              f.restaurant_entity =
                  ShopModel.fromJson(food_restaurant["restaurant"]);
              foods.add(f);
            })?.toList();
            return foods;
          }
        } else
          return foods;
//          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> fetchShopList(
      CustomerModel model, String type, Position position) async {
    xrint(
        "entered fetchShopList ${position?.latitude} : ${position?.longitude}");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      xrint("location is --> ");
      xrint({"location": "${position?.latitude}:${position?.longitude}"}
          .toString());

      Map<String, dynamic> params = Map();
      params.putIfAbsent("limit", () => 1000);
      params.putIfAbsent("search_type", () => "shop");
      if (type != null && type != "all")
        params.putIfAbsent("category", () => type);

      var response = await dio.get(
          Uri.parse(ServerRoutes.LINK_SHOP_LIST_V4).toString(),
          queryParameters: params);

      xrint(response.data);
      if (response.statusCode == 200) {
        dynamic data = mJsonDecode(response.data);

        return data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> fetchRestaurantList(
      CustomerModel model, String type, Position position) async {
    xrint(
        "entered fetchRestaurantList ${position?.latitude} : ${position?.longitude}");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      xrint("location is --> ");
      xrint({"location": "${position?.latitude}:${position?.longitude}"}
          .toString());

      Map<String, dynamic> params = Map();
      params.putIfAbsent("limit", () => 1000);
      params.putIfAbsent("search_type", () => "shop");
      if (type != null && type != "all")
        params.putIfAbsent("category", () => type);

      var response = await dio.get(
          Uri.parse(ServerRoutes.LINK_SHOP_LIST_V4).toString(),
          queryParameters: params);

      xrint(response.data);
      if (response.statusCode == 200) {
        dynamic data = mJsonDecode(response.data);

        return data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
