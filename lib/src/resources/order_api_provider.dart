import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
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

  payAtDelivery(CustomerModel customer, Map<RestaurantFoodModel, int> foods, DeliveryAddressModel selectedAddress) async {

    /* purchase or not */
//    JSONObject device_object = new JSONObject();
//    device_object.put("os_version", System.getProperty("os.version"));
//    device_object.put("build_device", Build.DEVICE);
//    device_object.put("version_sdk", Build.VERSION.SDK);
//    device_object.put("build_model", Build.MODEL);
//    device_object.put("build_product", Build.PRODUCT);
//    device_object.put("push_token", refreshedToken);


    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    List<Object> device = List();

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"

      device.add({'os_version':'${androidInfo.version.baseOS}'});
      device.add({'build_device':'${androidInfo.device}'});
      device.add({'version_sdk':'${androidInfo.version.sdkInt}'});
      device.add({'build_model':'${androidInfo.model}'});
      device.add({'build_product':'${androidInfo.product}'});
      device.add({'push_token':''});

    } else if (Platform.isIOS) {
      
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"

      device.add({'os_version':'${iosInfo.systemVersion}'});
      device.add({'build_device':'${iosInfo.utsname.sysname}'});
      device.add({'version_sdk':'${iosInfo.utsname.version}'});
      device.add({'build_model':'${iosInfo.model}'});
      device.add({'build_product':'${iosInfo.model}'});
      device.add({'push_token':''});
    }

    DebugTools.iPrint("entered payAtDelivery");
    if (await Utils.hasNetwork()) {

      List<Object> food_quantity = List();

      foods.forEach((food_item, quantity) => {
        food_quantity.add({'food_id': food_item.id, 'quantity' : quantity})
      });

      var _data = json.encode({
        'food_command': food_quantity,
        'pay_at_delivery': true,
        'shipping_address': selectedAddress.id,
        'transaction_password' : '',
        'infos' : '',
        'device': device, // device informations
        'push_token': '', // push token
      });

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

}
