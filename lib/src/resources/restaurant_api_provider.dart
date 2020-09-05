import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/RestaurantSubMenuModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

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
          .timeout(const Duration(seconds: 30));
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
  Future<RestaurantModel> loadRestaurantFromId(int restaurantIdOrMenuId/*, int DESTINATION*/) async {


    DebugTools.iPrint("entered loadRestaurantFromId");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(
//        DESTINATION == 1 ?
          ServerRoutes.LINK_GET_RESTAURANT_DETAILS/* : ServerRoutes.LINK_MENU_BY_ID*/,
          body: /*DESTINATION == 1 ? */json.encode({'id': restaurantIdOrMenuId}) /*: json.encode({'menu_id': restaurantIdOrMenuId}),*/
      )
          .timeout(const Duration(seconds: 30));
      print("001_ "+response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
//          print(json.decode(response.body)["data"]);
//          print(json.decode(response.body)["data"][0]);
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


  /// load food from id
  Future<RestaurantFoodModel> loadFoodFromId(int foodId) async {

    DebugTools.iPrint("entered loadFoodFromId ${foodId} ");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_FOOD_DETAILS_SIMPLE,
        body: json.encode({'food_id': foodId}),
//          headers: Utils.getHeadersWithToken()
      )
          .timeout(const Duration(seconds: 30));
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

  fetchRestaurantFoodProposalFromTag(String tag) async {

    DebugTools.iPrint("entered fetchRestaurantFoodProposalFromTag ${tag}");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_SEARCH_FOOD_BY_TAG,
        body: json.encode({'tag': tag}),
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      List<RestaurantFoodModel> foods = [];
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
          if (lo == null) {
            return [];
          } else {
            // foods with restaurant inside.
            lo?.map((food_restaurant){
              RestaurantFoodModel f = RestaurantFoodModel.fromJson(food_restaurant["food"]);
              f.restaurant_entity = RestaurantModel.fromJson(food_restaurant["restaurant"]);
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
}
