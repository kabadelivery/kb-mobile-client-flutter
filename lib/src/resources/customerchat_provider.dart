//FeedsProvider

import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CustomerCareChatMessageModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomerCareChatApiProvider {
  Future<Object> fetchCustomerChatList(CustomerModel customer) async {
    xrint("entered fetchCustomerChatList");
    if (await Utils.hasNetwork()) {
      /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_CUSTOMER_SERVICE_ALL_MESSAGES),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token!)
      )
          .timeout(const Duration(seconds: 30));
   */

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
        Uri.parse(ServerRoutes.LINK_GET_CUSTOMER_SERVICE_ALL_MESSAGES)
            .toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return [];
          else {
            List<CustomerCareChatMessageModel>? messages = lo
                ?.map(
                    (message) => CustomerCareChatMessageModel.fromJson(message))
                ?.toList();
            return messages!;
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
    xrint("entered sendMessageToCCare");
    if (await Utils.hasNetwork()) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      var device;

      String? token = "";
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
/*
      final response = await client
          .post(Uri.parse(ServerRoutes.LINK_POST_SUGGESTION),
          body: json.encode({"message":message, 'device': device}),
          headers: Utils.getHeadersWithToken(customer.token!)
      )
          .timeout(const Duration(seconds: 30));*/

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
        Uri.parse(ServerRoutes.LINK_POST_SUGGESTION).toString(),
        data: json.encode({"message": message, 'device': device}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        return errorCode;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
