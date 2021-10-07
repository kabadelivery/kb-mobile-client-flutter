import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/RestaurantSubMenuModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class MenuApiProvider {


  Future<Map> fetchRestaurantMenuList(int restaurantId) async {

    xrint("entered fetchRestaurantMenuList");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID),
        body: json.encode({'id': restaurantId}),
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        // ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
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
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((menu) => RestaurantSubMenuModel.fromJson(menu))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

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


   /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID), // by menu_id
        body: json.encode({'food_id': foodId}),
      )
          .timeout(const Duration(seconds: 30));*/


      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
        data:  json.encode({'food_id': foodId}),
      );


     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          RestaurantFoodModel food = RestaurantFoodModel.fromJson(mJsonDecode(response.data)["data"]["food"]);

          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((menu) => RestaurantSubMenuModel.fromJson(menu))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

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


      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID), // by menu_id
        body: json.encode({'menu_id': menuId}),
      )
          .timeout(const Duration(seconds: 30));
      */
      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
        data:  json.encode({'menu_id': menuId}),
      );


     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((comment) => RestaurantSubMenuModel.fromJson(comment))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

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



  Future<List<BestSellerModel>> fetchBestSellerList() async {

    xrint("entered fetchBestSellerList");
    if (await Utils.hasNetwork()) {

   /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_BESTSELLERS_LIST),
        body: json.encode([]),
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_BESTSELLERS_LIST).toString(),
        data:  json.encode({}),
      );


     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          List<BestSellerModel> bestSellers = lo?.map((bs) => BestSellerModel.fromJson(bs))?.toList();
          return bestSellers;
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
    /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE),
        body: json.encode({"food_id": foodId}),
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE).toString(),
        data:  json.encode({"food_id": foodId})
      );


     xrint("fetchFoodDetailsWithId ${foodId}");
     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          RestaurantFoodModel restaurantFoodModel = RestaurantFoodModel.fromJson(mJsonDecode(response.data)["data"]["food"]);
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

    xrint("entered fetchRestaurantWithId with $restaurantDetailsId and ${customer?.toJson()?.toString()}");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_RESTAURANT_DETAILS),
        body: json.encode({"id": restaurantDetailsId}),
        headers: customer?.token == null ? Map() : Utils.getHeadersWithToken(customer?.token),
      )
          .timeout(const Duration(seconds: 30));
     */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
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
          RestaurantModel restaurantModel = RestaurantModel.fromJson(mJsonDecode(response.data)["data"]["restaurant"]);
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

  reviewRestaurant(CustomerModel customer, RestaurantModel restaurant, int stars, String message) async {

    xrint("entered reviewRestaurant");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_POST_COMMENT),
        body: json.encode({"restaurant_id": restaurant?.id, "stars": stars, "comment": message}),
        headers: Utils.getHeadersWithToken(customer?.token),
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_POST_COMMENT).toString(),
        data:  json.encode({"restaurant_id": restaurant?.id, "stars": stars, "comment": message}),
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

  checkCanComment(CustomerModel customer, RestaurantModel restaurant) async {

    xrint("entered checkCanComment");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_CAN_COMMENT),
        body: json.encode({"restaurant_id": restaurant?.id}),
        headers: Utils.getHeadersWithToken(customer?.token),
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
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


}