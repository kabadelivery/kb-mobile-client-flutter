import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class AppApiProvider {

  Client client = Client();


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

  Future<List<RestaurantModel>> fetchRestaurantList(Position position) async {
    DebugTools.iPrint("entered fetchRestaurantList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_RESTO_LIST_V2,
          body: position == null ? "" : json.encode({"location" : "${position.latitude}:${position.longitude}"}),
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


  /* send the location and get back the not far from */
  Future<DeliveryAddressModel> checkLocationDetails(UserTokenModel userToken, Position position) async {
    DebugTools.iPrint("entered checkLocationDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LOCATION_DETAILS,
          body: position == null ? "" : json.encode({"coordinates" : "${position.latitude}:${position.longitude}"}),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String description_details = json.decode(response.body)["data"]["display_name"];
          String quartier = DeliveryAddressModel.fromJson(json.decode(response.body)["data"]["address"]).suburb;
          /* return only the content we need */
          DeliveryAddressModel deliveryAddressModel = DeliveryAddressModel(description: description_details, quartier: quartier);
          print("${description_details} , ${quartier}");
          return deliveryAddressModel;
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
