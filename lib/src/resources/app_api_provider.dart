import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/EvenementModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


class AppApiProvider {

  Client client = Client();


  Future<String> fetchHomeScreenModel() async {
    DebugTools.iPrint("entered fetchHomeScreenModel");
    if (await Utils.hasNetwork()) {
      final response = await client
          .get(ServerRoutes.LINK_HOME_PAGE,
          headers: Utils.getHeaders()).timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0)
          return response.body;
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
          body: position == null ? "" : json.encode(
              {"location": "${position?.latitude}:${position?.longitude}"}),
          headers: Utils.getHeaders()).timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["resto"];
          List<RestaurantModel> resto = lo?.map((resto) =>
              RestaurantModel.fromJson(resto))?.toList();
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
  Future<DeliveryAddressModel> checkLocationDetails(CustomerModel customer, Position position) async {
    DebugTools.iPrint("entered checkLocationDetails");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LOCATION_DETAILS,
          body: position == null ? "" : json.encode(
              {"coordinates": "${position.latitude}:${position.longitude}"}),
          headers: Utils.getHeadersWithToken(customer.token)).timeout(
          const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String description_details = json.decode(
              response.body)["data"]["display_name"];
          String quartier = DeliveryAddressModel
              .fromJson(json.decode(response.body)["data"]["address"])
              .suburb;
          /* return only the content we need */
          DeliveryAddressModel deliveryAddressModel = DeliveryAddressModel(
              description: description_details, quartier: quartier);
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

  Future<List<EvenementModel>> fetchEvenementList() async {

    /* get the events and show it */
    DebugTools.iPrint("entered fetchEvenementList");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_EVENEMENTS_LIST).timeout(
          const Duration(seconds: 30));

      print(response.body.toString());

      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
          List<EvenementModel> restaurantSubModel = lo?.map((comment) =>
              EvenementModel.fromJson(comment))?.toList();
          return restaurantSubModel;
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

  updateToken(CustomerModel customer) async {

    /* get the events and show it */
    DebugTools.iPrint("entered updateToken");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    String token = await firebaseMessaging.getToken();

    var _data;

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      _data = json.encode({
        'os_version': '${androidInfo.version.baseOS}',
        'build_device': '${androidInfo.device}',
        'version_sdk': '${androidInfo.version.sdkInt}',
        'build_model': '${androidInfo.model}',
        'build_product': '${androidInfo.product}',
        'push_token': '$token'
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      _data = json.encode({
        'os_version': '${iosInfo.systemVersion}',
        'build_device': '${iosInfo.utsname.sysname}',
        'version_sdk': '${iosInfo.utsname.version}',
        'build_model':'${iosInfo.utsname.machine}',
        'build_product': '${iosInfo.model}',
        'push_token': '$token'
      });
    }

    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_REGISTER_PUSH_TOKEN, body: _data,
          headers: Utils.getHeadersWithToken(customer.token))
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());

      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        return errorCode;
      }
      else
        throw Exception(-1); // there is an error in your request
    } else {}
  }

  checkUnreadMessages(customer) async {
//
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_CHECK_UNREAD_MESSAGES,
          headers: Utils.getHeadersWithToken(customer.token))
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        bool data = json.decode(response.body)["data"];
        return data;
      }
      else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2);
    }
  }
}
