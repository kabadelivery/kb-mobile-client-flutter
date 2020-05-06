//FeedsProvider


import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CustomerCareChatMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class CustomerCareChatApiProvider {

  Client client = Client();

  Future<Object> fetchCustomerChatList (CustomerModel customer) async {

    DebugTools.iPrint("entered fetchCustomerChatList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_CUSTOMER_SERVICE_ALL_MESSAGES,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return List<CustomerCareChatMessageModel>();
          else {
            List<CustomerCareChatMessageModel> messages = lo?.map((message) =>
                CustomerCareChatMessageModel.fromJson(message))?.toList();
            return messages;
          }
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<int> sendMessageToCCare(CustomerModel customer, String message) async {

    DebugTools.iPrint("entered sendMessageToCCare");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_POST_SUGGESTION,
          body: json.encode({"message":message}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
         return errorCode;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

}