import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'dart:convert';

import 'package:kaba_flutter/src/models/TransactionModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


class ClientPersonalApiProvider {

  Client client = Client();

  Future<List<CommentModel>> fetchRestaurantComment(RestaurantModel restaurantModel, UserTokenModel userToken) async {
    DebugTools.iPrint("entered fetchRestaurantComment");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_RESTAURANT_REVIEWS,
          body: json.encode({'restaurant_id': restaurantModel.id.toString()}),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["comments"];
          List<CommentModel> comments = lo?.map((comment) => CommentModel.fromJson(comment))?.toList();
          return comments;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<List<DeliveryAddressModel>> fetchMyAddresses(UserTokenModel userToken) async {
    DebugTools.iPrint("entered fetchMyAddresses");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_ADRESSES,
//          body: json.encode({'token': restaurantModel.id.toString()}),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["adresses"];
          List<DeliveryAddressModel> addresses = lo?.map((address) => DeliveryAddressModel.fromJson(address))?.toList();
          return addresses;
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
