import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'dart:convert';

import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
//import '../models/RestaurantModel.dart';

class CommandsApiProvider {

  Client client = Client();

  Future<List<CommandModel>> fetchDailyOrders(UserTokenModel userToken) async {

    DebugTools.iPrint("entered fetchDailyOrders");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MY_COMMANDS_GET_CURRENT,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(userToken.token)
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["commands"];
          List<CommandModel> commandModel = lo?.map((command) => CommandModel.fromJson(command))?.toList();
          return commandModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }


  /* order details */
  Future<CommandModel> fetchOrderDetails(UserTokenModel userToken, int orderId) async {

    DebugTools.iPrint("entered fetchOrderDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_COMMAND_DETAILS,
          body: json.encode({"command_id": orderId}),
          headers: Utils.getHeadersWithToken(userToken.token)
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          CommandModel commandModel = CommandModel.fromJson(json.decode(response.body)["data"]["command"]);
          return commandModel;
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
