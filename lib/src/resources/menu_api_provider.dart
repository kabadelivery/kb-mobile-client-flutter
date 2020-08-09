import 'dart:async';
import 'dart:convert';

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

  Client client = Client();

  Future<Map> fetchRestaurantMenuList(int restaurantId) async {

    DebugTools.iPrint("entered fetchRestaurantMenuList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID,
        body: json.encode({'id': restaurantId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((menu) => RestaurantSubMenuModel.fromJson(menu))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(response.body)["data"]["resto"]);

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

    DebugTools.iPrint("entered fetchRestaurantMenuListWithFoodId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID, // by menu_id
        body: json.encode({'food_id': foodId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          RestaurantFoodModel food = RestaurantFoodModel.fromJson(json.decode(response.body)["data"]["food"]);

          Iterable lo = json.decode(response.body)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((menu) => RestaurantSubMenuModel.fromJson(menu))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(response.body)["data"]["resto"]);

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

    DebugTools.iPrint("entered fetchRestaurantMenuListWithMenuId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID, // by menu_id
        body: json.encode({'menu_id': menuId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((comment) => RestaurantSubMenuModel.fromJson(comment))?.toList();
          RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(response.body)["data"]["resto"]);

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

    DebugTools.iPrint("entered fetchBestSellerList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_BESTSELLERS_LIST,
        body: json.encode([]),
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
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

    DebugTools.iPrint("entered fetchFoodDetailsWithId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE,
        body: json.encode({"food_id": foodId}),
      )
          .timeout(const Duration(seconds: 30));
      print("fetchFoodDetailsWithId ${foodId}");
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          RestaurantFoodModel restaurantFoodModel = RestaurantFoodModel.fromJson(json.decode(response.body)["data"]["food"]);
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

    DebugTools.iPrint("entered fetchRestaurantWithId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_RESTAURANT_DETAILS,
        body: json.encode({"id": restaurantDetailsId}),
        headers: Utils.getHeadersWithToken(customer.token),
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(response.body)["data"]["restaurant"]);
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

    DebugTools.iPrint("entered reviewRestaurant");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_POST_COMMENT,
        body: json.encode({"restaurant_id": restaurant?.id, "stars": stars, "comment": message}),
        headers: Utils.getHeadersWithToken(customer.token),
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
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

    DebugTools.iPrint("entered checkCanComment");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_CHECK_CAN_COMMENT,
        body: json.encode({"restaurant_id": restaurant?.id}),
        headers: Utils.getHeadersWithToken(customer.token),
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {

        // get restaurant entity here

        int can_comment = json.decode(response.body)["data"]["can_comment"];
        return can_comment;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }


}