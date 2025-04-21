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

class MenuApiProvider {
  Future<Map> fetchRestaurantMenuList(int restaurantId) async {
    xrint("entered fetchRestaurantMenuList $restaurantId");
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
        data: json.encode({'id': restaurantId}),
      );

      xrint(response.data);
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel>? restaurantSubModel = lo
              ?.map((menu) => RestaurantSubMenuModel.fromJson(menu))
              ?.toList();
          ShopModel restaurantModel =
              ShopModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

          Map<String, dynamic> mapRes = new Map();
          mapRes.putIfAbsent("restaurant", () => restaurantModel);
          mapRes.putIfAbsent("menus", () => restaurantSubModel);

          return mapRes;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchRestaurantMenuListWithFoodId(int foodId) async {
    xrint("entered fetchRestaurantMenuListWithFoodId");
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
        data: json.encode({'food_id': foodId}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          ShopProductModel food = ShopProductModel.fromJson(
              mJsonDecode(response.data)["data"]["food"]);

          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel>? restaurantSubModel = lo
              ?.map((menu) => RestaurantSubMenuModel.fromJson(menu))
              ?.toList();
          ShopModel restaurantModel =
              ShopModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

          Map<String, dynamic> mapRes = new Map();
          mapRes.putIfAbsent("restaurant", () => restaurantModel);
          mapRes.putIfAbsent("menus", () => restaurantSubModel);
          mapRes.putIfAbsent("food", () => food);

          return mapRes;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<Map> fetchRestaurantMenuListWithMenuId(int menuId) async {
    xrint("entered fetchRestaurantMenuListWithMenuId");
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

      xrint(json.encode({'menu_id': menuId}));

      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
        data: json.encode({'menu_id': menuId}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel>? restaurantSubModel = lo
              ?.map((comment) => RestaurantSubMenuModel.fromJson(comment))
              ?.toList();
          ShopModel restaurantModel =
              ShopModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

          Map<String, dynamic> mapRes = new Map();
          mapRes.putIfAbsent("restaurant", () => restaurantModel);
          mapRes.putIfAbsent("menus", () => restaurantSubModel);

          return mapRes;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchShopScheduleList(int restaurant_id) async {
    xrint("entered fetchShopScheduleList");
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
        Uri.parse(ServerRoutes.LINK_GET_SHOP_SCHEDULE).toString(),
        data: json.encode({'id': restaurant_id}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          return response.data.toString();
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> fetchBestSellerList(CustomerModel customer) async {
    xrint("entered fetchBestSellerList \n");
    if (await Utils.hasNetwork()) {
      /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_BESTSELLERS_LIST),
        body: json.encode([]),
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_BESTSELLERS_LIST).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          return response.data.toString();
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchFoodDetailsWithId(int foodId) async {
    xrint("entered fetchFoodDetailsWithId");
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
          data: json.encode({"food_id": foodId}));

      xrint("fetchFoodDetailsWithId ${foodId}");
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          ShopProductModel restaurantFoodModel = ShopProductModel.fromJson(
              mJsonDecode(response.data)["data"]["food"]);
          return restaurantFoodModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  fetchRestaurantWithId(CustomerModel customer, int restaurantDetailsId) async {
    xrint(
        "entered fetchRestaurantWithId with $restaurantDetailsId and ${customer?.toJson()?.toString()}");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_RESTAURANT_DETAILS).toString(),
        data: json.encode({"id": restaurantDetailsId}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          ShopModel restaurantModel = ShopModel.fromJson(
              mJsonDecode(response.data)["data"]["restaurant"]);
          return restaurantModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  reviewRestaurant(CustomerModel customer, ShopModel restaurant, int stars,
      String message) async {
    xrint("entered reviewRestaurant");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_POST_COMMENT).toString(),
        data: json.encode({
          "restaurant_id": restaurant?.id,
          "stars": stars,
          "comment": message
        }),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode != -1) {
          return 0;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  checkCanComment(CustomerModel customer, ShopModel restaurant) async {
    xrint("entered checkCanComment");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_CAN_COMMENT).toString(),
        data: json.encode({"restaurant_id": restaurant?.id}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        // get restaurant entity here

        int can_comment = mJsonDecode(response.data)["data"]["can_comment"];
        return can_comment;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> fetchProposalList(CustomerModel customer) async {
    xrint("entered fetchProposalList \n");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_BESTSELLERS_LIST).toString(),
        data: json.encode({}),
      );

      /* look for menu details and put result inside data array and send back */
      var res = {"error": 1, "data": []};

      response = await dio.post(
          Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
          data: json.encode({'id': 150}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          res["data"] = mJsonDecode(response.data)["data"]["menus"][0]["foods"];
          return json.encode(res).toString();
          // return response.data.toString();
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
