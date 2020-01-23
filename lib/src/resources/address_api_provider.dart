import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';



class AddressApiProvider {

  Client client = Client();

  Future<Object> updateOrCreateAddress(DeliveryAddressModel address, CustomerModel customer) async {

    DebugTools.iPrint("entered updateorCreateAddress");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_CREATE_NEW_ADRESS,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 10));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["commands"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return List<CommandModel>();
          /// else
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

}
