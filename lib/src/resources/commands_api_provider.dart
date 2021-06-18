import 'dart:async';
import 'dart:convert';

import 'package:KABA/src/xrint.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class CommandsApiProvider {

  Client client = Client();

  Future<List<CommandModel>> fetchDailyOrders(CustomerModel customer) async {

    xrint("entered fetchDailyOrders");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(Uri.parse(ServerRoutes.LINK_MY_COMMANDS_GET_CURRENT),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      xrint(customer?.toJson()?.toString());
     xrint(response.body.toString());
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
  Future<CommandModel> fetchOrderDetails(CustomerModel customer, int orderId) async {

    xrint("entered fetchOrderDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_COMMAND_DETAILS),
          body: json.encode({"command_id": orderId}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
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


  /* all orders details */
  Future<List<CommandModel>> fetchLastOrders(CustomerModel customer) async {

    xrint("entered fetchLastOrders");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_ALL_COMMAND_LIST),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
      try {
        if (response.statusCode == 200) {
          int errorCode = json.decode(response.body)["error"];
          if (errorCode == 0) {

            try {
              Iterable lo = json.decode(response.body)["data"]["commands"];
              if (lo == null || lo.isEmpty || lo.length == 0)
                return List<CommandModel>();
              /// else
              List<CommandModel> commandModel = lo?.map((command) =>
                  CommandModel.fromJson(command))?.toList();
              return commandModel;
            } catch (_) {
              return List<CommandModel>();
            }
          } else
            throw Exception(-1); // there is an error in your request
        } }
      catch(_) {
       xrint(_);
        return List<CommandModel>();
      }
    } else {
      throw Exception(-2);
    }
  }
}
