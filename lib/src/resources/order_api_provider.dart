import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class OrderApiProvider {

  Client client = Client();


  Future<OrderBillConfiguration> computeBillingAction (CustomerModel customer,Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address) async {

    DebugTools.iPrint("entered computeBillingAction");
    if (await Utils.hasNetwork()) {

      List<Object> food_quantity = List();
      foods.forEach((food_item, quantity) => {
        food_quantity.add({'food_id': food_item.id, 'quantity' : quantity})
      });

      var _data = json.encode({'food_command': food_quantity, 'restaurant_id': foods.keys.elementAt(0).restaurant_entity.id, 'shipping_address': address.id});

      print(_data.toString());

      final response = await client
          .post(ServerRoutes.LINK_COMPUTE_BILLING,
          body:  _data,
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 10));

      print(response.body.toString());
      if (response.statusCode == 200) {
        return OrderBillConfiguration.fromJson(json.decode(response.body)["data"]);
      } else
        throw Exception(-1); // there is an error in your request
    } else {
//      throw Exception(response.statusCode); // you have no right to do this
    }
  }

  Future<bool> launchOrder(bool isPayAtDelivery, CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel selectedAddress, String mCode, String infos) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    var device;

    final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
    String token = await firebaseMessaging.getToken();

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
      device = json.encode({
        'os_version':'${androidInfo.version.baseOS}',
        'build_device':'${androidInfo.device}',
        'version_sdk':'${androidInfo.version.sdkInt}',
        'build_model':'${androidInfo.model}',
        'build_product':'${androidInfo.product}',
        'push_token':''
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
      device = json.encode({
        'os_version':'${iosInfo.systemVersion}',
        'build_device':'${iosInfo.utsname.sysname}',
        'version_sdk':'${iosInfo.utsname.version}',
        'build_model':'${iosInfo.model}',
        'build_product':'${iosInfo.model}',
        'push_token':'$token'
      });
    }

    DebugTools.iPrint("entered payAtDelivery");
    if (await Utils.hasNetwork()) {

      List<Object> food_quantity = List();

      foods.forEach((food_item, quantity) => {
        food_quantity.add({'food_id': food_item.id, 'quantity' : quantity})
      });

      var _data = json.encode({
        'food_command': food_quantity,
        'pay_at_delivery': isPayAtDelivery,
        'shipping_address': selectedAddress.id,
        'transaction_password' : '$mCode',
        'infos' : '$infos',
        'device': device, // device informations
        'push_token':'$token', // push token
      });

      print("000 _ "+_data.toString());

      final response = await client
          .post(ServerRoutes.LINK_CREATE_COMMAND,
          body:  _data,
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 60));

      print("001 _ "+response.body.toString());
      if (response.statusCode == 200) {
        // if ok, send true or false
//        return OrderBillConfiguration.fromJson(json.decode(response.body)["data"]);
        if (json.decode(response.body)["error"] == 0)
          return true;
        return false;
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // you have no right to do this
    }
  }
}
