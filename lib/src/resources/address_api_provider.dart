import 'dart:convert';

import 'package:KABA/src/xrint.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';



class AddressApiProvider {

  Client client = Client();

  Future<Object> updateOrCreateAddress(DeliveryAddressModel address, CustomerModel customer) async {

    xrint("entered updateorCreateAddress");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_CREATE_NEW_ADRESS,
          body: json.encode({
            "id": address?.id,
            "name":address?.name,
            "location":address?.location,
            "phone_number":address?.phone_number,
            "description":address?.description,
            "description_details": address?.description,
            "near":address?.near,
            "quartier":address?.quartier
          }),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        DeliveryAddressModel address = DeliveryAddressModel.fromJson(json.decode(response.body)["data"]);
        Map res = Map();
        if (errorCode == 0) {
          res["error"] = errorCode;
          res["address"] = address;
          return res;
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

    xrint("entered checkLocationDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LOCATION_DETAILS,
          body: json.encode({"coordinates": '${position.latitude}:${position.longitude}'}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
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

  Future<List<DeliveryAddressModel>> fetchAddressList(CustomerModel customer) async {

    xrint("entered fetchAddressList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_ADRESSES,
          headers: Utils.getHeadersWithToken(customer.token)).timeout(
          const Duration(seconds: 30));
     xrint(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["adresses"];
          List<DeliveryAddressModel> addresses = lo?.map((address) =>
              DeliveryAddressModel.fromJson(address))?.toList();
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

  deleteAddress(CustomerModel customer, DeliveryAddressModel address) async {

   xrint("entered deleteAddress");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_DELETE_ADRESS,
          body: json.encode({
            "id": address?.id
          }),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     xrint(response.body.toString());
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
}
