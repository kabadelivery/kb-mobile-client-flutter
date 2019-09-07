import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'dart:convert';

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

  /* get a list of submenus. */

}
