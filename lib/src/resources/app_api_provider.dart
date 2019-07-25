import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'dart:convert';

import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
//import '../models/RestaurantModel.dart';


class AppApiProvider {

  Client client = Client();

/* make home page look like an entity */

  Future<HomeScreenModel> fetchHomeScreenModel() async {
    DebugTools.iPrint("entered fetchHomeScreenModel");
    if (await Utils.hasNetwork()) {
      final response = await client
          .get(ServerRoutes.LINK_HOME_PAGE,
//        .post(ServerRoutes.LINK_HOME_PAGE,
          headers: Utils.getHeaders()).timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0)
          return HomeScreenModel.fromJson(json.decode(response.body)["data"]);
        else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<List<RestaurantModel>> fetchRestaurantList() async {
    DebugTools.iPrint("entered fetchRestaurantList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_RESTO_LIST_V2,
//        .post(ServerRoutes.LINK_HOME_PAGE,
          headers: Utils.getHeaders()).timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["resto"];
          List<RestaurantModel> resto = lo?.map((resto) => RestaurantModel.fromJson(resto))?.toList();
          return resto;
        }
        else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }


}
