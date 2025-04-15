import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OrderApiProvider {

  Future<OrderBillConfiguration> computeBillingAction(
      CustomerModel customer,
      ShopModel restaurant,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel address,
      VoucherModel voucher,
      bool useKabaPoints) async {
    xrint("entered computeBillingAction");
    if (await Utils.hasNetwork()) {
      List<Object> food_quantity = List();
      foods.forEach((food_item, quantity) => {
            food_quantity.add({'food_id': food_item.id, 'quantity': quantity})
          });

      var _data = json.encode({
        'food_command': food_quantity,
        'restaurant_id': restaurant.id,
        'shipping_address': address.id,
        "voucher_id": voucher?.id,
        "use_kaba_point": useKabaPoints
      });

      xrint(_data.toString());
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      print("customer?.token ${customer?.token}");
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_COMPUTE_BILLING).toString(),
          data: _data);

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return OrderBillConfiguration.fromJson(
            mJsonDecode(response.data)["data"]);
      } else {
        xrint("computeBilling error ${response.statusCode}");
        throw Exception(-1); // there is an error in your request
      }
    } else {
      throw Exception(-2); // you have no right to do this
    }
  }

  Future<int> launchOrder(
      bool isPayAtDelivery,
      CustomerModel customer,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel selectedAddress,
      String mCode,
      String infos,
      VoucherModel voucher,
      bool useKabaPoint) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    var device;

    String token = "";
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
    } catch (e) {
      xrint(e);
    }

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      xrint("Running on ${androidInfo.model}"); // e.g. "Moto G (4)"
      device = {
        "os_version": "${androidInfo.version.baseOS}",
        "build_device": "${androidInfo.device}",
        "version_sdk": "${androidInfo.version.sdkInt}",
        "build_model": "${androidInfo.model}",
        "build_product": "${androidInfo.product}",
        "push_token": "$token"
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      xrint("Running on ${iosInfo.utsname.machine}"); // e.g. "iPod7,1"
      device = {
        "os_version": "${iosInfo.systemVersion}",
        "build_device": "${iosInfo.utsname.sysname}",
        "version_sdk": "${iosInfo.utsname.version}",
        'build_model': '${iosInfo.utsname.machine}',
        "build_product": "${iosInfo.model}",
        "push_token": "$token"
      };
    }

    xrint("entered payAtDelivery");
    xrint("entered payAtDelivery");
    if (await Utils.hasNetwork()) {
      List<Object> food_quantity = List();

      foods.forEach((food_item, quantity) => {
            food_quantity.add({'food_id': food_item.id, 'quantity': quantity})
          });

      var _data = json.encode({
        'food_command': food_quantity,
        'pay_at_delivery': isPayAtDelivery,
        'shipping_address': selectedAddress.id,
        'transaction_password': '$mCode',
        'infos': '$infos',
        'device': device, // device informations
        'push_token': '$token', // push token
        "voucher_id": voucher?.id,
        "use_kaba_point": useKabaPoint
      });

      xrint("000 _ " + _data.toString());
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 90000
        ..headers['Cache-Control'] = 'no-cache';
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_CREATE_COMMAND).toString(),
          data: _data);

      xrint("001 _ " + response.data.toString());
      xrint("002 _status code  " + response.statusCode.toString());

      if (response.statusCode == 200) {
        // if ok, send true or false
        return mJsonDecode(response.data)["error"];
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // you have no right to do this
    }
  }

  loadOrderFromId(CustomerModel customer, int orderId, {bool is_out_of_app_order = false}) async {
    xrint("entered loadOrderFromId");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000
        ..headers['Cache-Control'] = 'no-cache';
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(
              is_out_of_app_order == false
                  ? ServerRoutes.LINK_GET_COMMAND_DETAILS
                  : ServerRoutes.LINK_OUT_OF_APP_GET_COMMAND_DETAILS
          ).toString(),
          data: json.encode({"command_id": orderId}));

      String content = response.data.toString();
      xrint("content ${content}");
      if (response.statusCode == 200) {
        return CommandModel.fromJson(
            mJsonDecode(response.data)["data"]["command"]);
      } else {
        throw Exception(-1);
      }
    } else {
      throw Exception(-2);
    }
  }


  Future<String> checkOpeningStateOfRestaurant(
      CustomerModel customer, ShopModel restaurant) async {
    xrint("entered checkOpeningStateOfRestaurant");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_CHECK_RESTAURANT_IS_OPEN).toString(),
          data: json.encode({"restaurant_id": restaurant.id}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // there is an error in your request
    }
  }

  Future<int> sendFeedback(
      CustomerModel customer, int orderId, int rating, String message) async {
    xrint("entered sendFeedback");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_SEND_ORDER_FEEDBACK).toString(),
          data: json.encode(
              {"command_id": orderId, "rate": rating, "comment": message}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return mJsonDecode(response.data)["error"];
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // there is an error in your request
    }
  }

  launchPreorderOrder(
      CustomerModel customer,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel selectedAddress,
      String mCode,
      String infos,
      String start,
      String end) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    var device;

    String token = "";
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
    } catch (e) {
      xrint(e);
    }

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      xrint('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      device = {
        'os_version': '${androidInfo.version.baseOS}',
        'build_device': '${androidInfo.device}',
        'version_sdk': '${androidInfo.version.sdkInt}',
        'build_model': '${androidInfo.model}',
        'build_product': '${androidInfo.product}',
        'push_token': '$token'
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      xrint('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      device = {
        'os_version': '${iosInfo.systemVersion}',
        'build_device': '${iosInfo.utsname.sysname}',
        'version_sdk': '${iosInfo.utsname.version}',
        'build_model': '${iosInfo.utsname.machine}',
        'build_product': '${iosInfo.model}',
        'push_token': '$token'
      };
    }

    xrint("entered payAtDelivery");
    if (await Utils.hasNetwork()) {
      List<Object> food_quantity = List();

      foods.forEach((food_item, quantity) => {
            food_quantity.add({'food_id': food_item.id, 'quantity': quantity})
          });

      var _data = json.encode({
        'food_command': food_quantity,
        'pay_at_delivery': false,
        'pre_order': 1,
        'pre_order_hour': {"start": start, "end": end},
        'shipping_address': selectedAddress.id,
        'transaction_password': '$mCode',
        'infos': '$infos',
        'device': device, // device informations
        'push_token': '$token', // push token
      });

      xrint("000 _ " + _data.toString());

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 90000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_CREATE_COMMAND).toString(),
          data: _data);

      xrint("001 _ " + response.data.toString());
      if (response.statusCode == 200) {
        // if ok, send true or false
        return mJsonDecode(response.data)["error"];
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // you have no right to do this
    }
  }
}
