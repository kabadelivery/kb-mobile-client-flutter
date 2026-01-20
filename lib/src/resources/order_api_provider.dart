import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/DeliveryRatingPending.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class OrderApiProvider {

  Future<OrderBillConfiguration> computeBillingAction(
      CustomerModel customer,
      ShopModel restaurant,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel address,
      VoucherModel? voucher,
      bool useKabaPoints) async {
    xrint("entered computeBillingAction");

    if (!await Utils.hasNetwork()) {
      throw Exception(-2); // pas de réseau
    }
    // Préparer la liste des aliments
    List<Object> food_quantity = [];
    foods.forEach((food_item, quantity) {
      food_quantity.add({'food_id': food_item.id, 'quantity': quantity});
    });

    Map<String, dynamic> requestData = {
      'food_command': food_quantity,
      'restaurant_id': restaurant.id,
      'shipping_address': address.id,
      "voucher_id": voucher?.id,
      "use_kaba_point": useKabaPoints
    };

    // === Appel à l'endpoint KABA_ABONNEMENT_GET_BY_USER avant le compute billing ===
    try {
      var dio = Dio();
      dio.options.headers = Utils.getHeadersWithToken(customer.token!);
      var abonnementResponse = await dio.post(
        ServerRoutes.KABA_ABONNEMENT_GET_BY_USER,
        data: {
          "userId": customer.id!,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (abonnementResponse.statusCode == 200 ||abonnementResponse.statusCode == 201) {
        requestData['user_abonnement'] = abonnementResponse.data;
      } else {
        xrint("KABA_ABONNEMENT_GET_BY_USER failed: ${abonnementResponse.statusCode}");
        requestData['user_abonnement'] = {};
      }
    } catch (e) {
      xrint("KABA_ABONNEMENT_GET_BY_USER exception: $e");
      requestData['user_abonnement'] = {};
    }
    var _data = json.encode(requestData);
    xrint(_data.toString());

    try {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      xrint("customer.token! ${customer.token!}");
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_COMPUTE_BILLING).toString(),
          data: _data);
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return OrderBillConfiguration.fromJson(
            mJsonDecode(response.data)["data"]);
      } else {
        xrint("computeBilling error ${response.statusCode}");
        throw Exception(-1); // erreur côté serveur
      }
    } catch (e) {
      xrint("computeBilling exception: $e");
      throw Exception(-1);
    }
  }


  Future<Map> launchOrder(
      bool isPayAtDelivery,
      CustomerModel? customer,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel selectedAddress,
      String mCode,
      String infos,
      VoucherModel? voucher,
      bool useKabaPoint)
  async {
    DeviceInfoPlugin? deviceInfo = DeviceInfoPlugin();
    var device;

    String? token = "";
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
    } catch (e) {
      xrint(e);
    }

    // Récupération des infos device
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
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
      device = {
        "os_version": "${iosInfo.systemVersion}",
        "build_device": "${iosInfo.utsname.sysname}",
        "version_sdk": "${iosInfo.utsname.version}",
        "build_model": "${iosInfo.utsname.machine}",
        "build_product": "${iosInfo.model}",
        "push_token": "$token"
      };
    }

    xrint("entered launchOrder");

    if (!await Utils.hasNetwork()) {
      throw Exception(-2); // pas de réseau
    }

    // Préparer la liste des aliments
    List<Object> food_quantity = [];
    foods.forEach((food_item, quantity) {
      food_quantity.add({'food_id': food_item.id, 'quantity': quantity});
    });

    // Préparer le JSON de base
    Map<String, dynamic> requestData = {
      'food_command': food_quantity,
      'pay_at_delivery': isPayAtDelivery,
      'shipping_address': selectedAddress.id,
      'transaction_password': mCode,
      'infos': infos,
      'device': device,
      'push_token': token,
      "voucher_id": voucher?.id,
      "use_kaba_point": useKabaPoint
    };
    var abonnementData ={};
    try {
      var dio = Dio();
      dio.options.headers = Utils.getHeadersWithToken(customer!.token!);
      var abonnementResponse = await dio.post(
        ServerRoutes.KABA_ABONNEMENT_GET_BY_USER,
        data: {
          "userId": customer.id!,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (abonnementResponse.statusCode == 200 ||abonnementResponse.statusCode == 201) {
        abonnementData= abonnementResponse.data;
        requestData['user_abonnement'] = abonnementResponse.data;
      } else {
        xrint("KABA_ABONNEMENT_GET_BY_USER failed: ${abonnementResponse.statusCode}");
        requestData['user_abonnement'] = {};
      }
    } catch (e) {
      xrint("KABA_ABONNEMENT_GET_BY_USER exception: $e");
      requestData['user_abonnement'] = {};
    }
    var _data = json.encode(requestData);
    xrint("Request data: $_data");
    try {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer!.token!)
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
        data: _data,
      );

      xrint("Response data: ${response.data}");
      xrint("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        var newData = mJsonDecode(response.data);

        return mJsonDecode(response.data);
      } else {
        throw Exception(-1); // erreur côté serveur
      }
    } catch (e) {
      xrint("launchOrder exception: $e");
      throw Exception(-1);
    }
  }


  loadOrderFromId(CustomerModel customer, int orderId, {bool is_out_of_app_order = false}) async {
    xrint("entered loadOrderFromId");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
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
        ..headers = Utils.getHeadersWithToken(customer.token!)
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

  Future<int> sendFeedback(CustomerModel customer,DeliveryRatingPending deliveryRatingPending) async {
    xrint("entered sendFeedback");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      xrint(deliveryRatingPending.toJson().toString());
      Map<String?, dynamic> json = deliveryRatingPending.toJson();
      json.remove("food");
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_SEND_ORDER_FEEDBACK).toString(),
          data:json);
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return mJsonDecode(response.data)["error"];
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // there is an error in your request
    }
  }

  Future<Map> launchPreorderOrder(
      CustomerModel customer,
      Map<ShopProductModel, int> foods,
      DeliveryAddressModel selectedAddress,
      String mCode,
      String infos,
      String start,
      String end,
      )
  async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var device;

    String? token = "";
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      xrint(e);
    }

    // ==== DEVICE INFO ====
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = {
        'os_version': '${androidInfo.version.baseOS}',
        'build_device': '${androidInfo.device}',
        'version_sdk': '${androidInfo.version.sdkInt}',
        'build_model': '${androidInfo.model}',
        'build_product': '${androidInfo.product}',
        'push_token': '$token',
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = {
        'os_version': '${iosInfo.systemVersion}',
        'build_device': '${iosInfo.utsname.sysname}',
        'version_sdk': '${iosInfo.utsname.version}',
        'build_model': '${iosInfo.utsname.machine}',
        'build_product': '${iosInfo.model}',
        'push_token': '$token',
      };
    }

    if (!await Utils.hasNetwork()) throw Exception(-2);

    // ==== FOODS LIST ====
    List<Object> food_quantity = [];
    foods.forEach((food_item, quantity) {
      food_quantity.add({'food_id': food_item.id, 'quantity': quantity});
    });

    // ==== BASE REQUEST DATA ====
    Map<String, dynamic> requestData = {
      'food_command': food_quantity,
      'pay_at_delivery': false,
      'pre_order': 1,
      'pre_order_hour': {"start": start, "end": end},
      'shipping_address': selectedAddress.id,
      'transaction_password': mCode,
      'infos': infos,
      'device': device,
      'push_token': token,
    };

    // ==== FETCH ABONNEMENT ====
    Map abonnementData = {};
    try {
      var dio = Dio();
      dio.options.headers = Utils.getHeadersWithToken(customer.token!);

      var aboRes = await dio.post(
        ServerRoutes.KABA_ABONNEMENT_GET_BY_USER,
        data: {"userId": customer.id!},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (aboRes.statusCode == 200 || aboRes.statusCode == 201) {
        abonnementData = aboRes.data;
        requestData["user_abonnement"] = aboRes.data;
      } else {
        requestData["user_abonnement"] = {};
      }
    } catch (e) {
      xrint("ABONNEMENT fetch error: $e");
      requestData["user_abonnement"] = {};
    }

    var _data = json.encode(requestData);
    xrint("PREORDER DATA: $_data");

    // ==== SEND CREATE PREORDER ====
    try {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 90000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
        return client;
      };

      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CREATE_COMMAND).toString(),
        data: _data,
      );

      xrint("PREORDER RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        final decoded = mJsonDecode(response.data);
        var newData = mJsonDecode(response.data);
        return decoded;
      } else {
        throw Exception(-1);
      }
    } catch (e) {
      xrint("launchPreorderOrder ERROR: $e");
      throw Exception(-1);
    }
  }

}
