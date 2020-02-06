import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class RestaurantApiProvider {

  Client client = Client();

  Future<List<RestaurantSubMenuModel>> fetchRestaurantMenuList(RestaurantModel restaurantModel) async {

    DebugTools.iPrint("entered fetchRestaurantMenuList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID,
        body: json.encode({'id': restaurantModel.id.toString()}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((comment) => RestaurantSubMenuModel.fromJson(comment))?.toList();
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
  Future<RestaurantModel> loadRestaurantFromId(int restaurantId) async {

    DebugTools.iPrint("entered loadRestaurantFromId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_RESTAURANT_DETAILS,
        body: json.encode({'id': restaurantId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
//          print(json.decode(response.body)["data"]);
//          print(json.decode(response.body)["data"][0]);
          RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(response.body)["data"]["menu"]);
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


  /// load food from id
  Future<RestaurantFoodModel> loadFoodFromId(int foodId) async {

    DebugTools.iPrint("entered loadFoodFromId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE,
        body: json.encode({'id': foodId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          RestaurantFoodModel foodModel = RestaurantFoodModel.fromJson(json.decode(response.body)["data"]["food"]);
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

}
