import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
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


  Future<Object> updateOrCreateAddress(DeliveryAddressModel address, CustomerModel customer) async {

    xrint("entered updateorCreateAddress");
    if (await Utils.hasNetwork()) {


   /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CREATE_NEW_ADRESS),
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
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
              return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(Uri.parse(ServerRoutes.LINK_CREATE_NEW_ADRESS).toString(),
          data: json.encode({
            "id": address?.id,
            "name":address?.name,
            "location":address?.location,
            "phone_number":address?.phone_number,
            "description":address?.description,
            "description_details": address?.description,
            "near":address?.near,
            "quartier":address?.quartier
          }));


     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        DeliveryAddressModel address = DeliveryAddressModel.fromJson(mJsonDecode(response.data)["data"]);
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


    /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_LOCATION_DETAILS),
          body: json.encode({"coordinates": '${position.latitude}:${position.longitude}'}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      var response = await dio.post(Uri.parse(ServerRoutes.LINK_GET_LOCATION_DETAILS).toString(),
          data: json.encode({"coordinates": '${position.latitude}:${position.longitude}'}));


     xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          String description_details = mJsonDecode(response.data)["data"]["display_name"];
          String suburb = mJsonDecode(response.data)["data"]["address"]["suburb"];
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


     /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_ADRESSES),
          headers: Utils.getHeadersWithToken(customer?.token)).timeout(
          const Duration(seconds: 30));
      */
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      var response = await dio.post(Uri.parse(ServerRoutes.LINK_GET_ADRESSES).toString(),
          data: json.encode({}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["adresses"];
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


     /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_DELETE_ADRESS),
          body: json.encode({
            "id": address?.id
          }),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      var response = await dio.post(Uri.parse(ServerRoutes.LINK_DELETE_ADRESS).toString(),
          data: json.encode({"id": address?.id}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
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
