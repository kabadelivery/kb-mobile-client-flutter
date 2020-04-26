import 'dart:convert';

import 'package:geolocator/geolocator.dart';
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
          body: json.encode({"id": address.id, "name":address.name, "location":address.location, "phone_number":address.phone_number,
          "description":address.description, "description_details": address.description, "near":address.near, "quartier":address.quartier
          }),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
      return 0;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  checkLocationDetails(CustomerModel customer, Position position) async {


//    String position = lat+":"+lon;
//    Map<String, Object> data = new HashMap<>();
//    data.put("coordinates", position);

    DebugTools.iPrint("entered checkLocationDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LOCATION_DETAILS,
          body: json.encode({"coordinates": '${position.latitude}:${position.longitude}'}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
//    String balance = json.decode(response.body)["data"]["balance"];
//    return balance;

          String description_details = json.decode(response.body)["data"]["display_name"];
          String suburb = json.decode(response.body)["data"]["address"]["suburb"];

          var m = Map();
          m.putIfAbsent("suburb", ()=>suburb);
          m.putIfAbsent("description_details", ()=>description_details);
          return m;

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
