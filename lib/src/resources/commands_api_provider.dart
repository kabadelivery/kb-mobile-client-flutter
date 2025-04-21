import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class CommandsApiProvider {
  Future<List<CommandModel>> fetchDailyOrders(CustomerModel customer,{bool is_out_of_app_order=false}) async {
    xrint("entered fetchDailyOrders");
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
        Uri.parse(
            is_out_of_app_order==false?
            ServerRoutes.LINK_MY_COMMANDS_GET_CURRENT:
            ServerRoutes.LINK_OUT_OF_APP_MY_COMMANDS_GET_CURRENT
        ).toString(),
        data: json.encode({}),
      );

      xrint(customer?.toJson()?.toString());
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["commands"];
          List<CommandModel>? commandModel =
              lo?.map((command) => CommandModel.fromJson(command))?.toList();
          return commandModel!;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /* order details */
  Future<CommandModel> fetchOrderDetails(
      CustomerModel customer, int orderId) async {
    xrint("entered fetchOrderDetails");
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
        Uri.parse(ServerRoutes.LINK_GET_COMMAND_DETAILS).toString(),
        data: json.encode({"command_id": orderId}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          CommandModel commandModel = CommandModel.fromJson(
              mJsonDecode(response.data)["data"]["command"]);
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

  /* all orders details */
  Future<List<CommandModel>?> fetchLastOrders(CustomerModel customer) async {
    xrint("entered fetchLastOrders");
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
        Uri.parse(ServerRoutes.LINK_GET_ALL_COMMAND_LIST).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      try {
        if (response.statusCode == 200) {
          int errorCode = mJsonDecode(response.data)["error"];
          if (errorCode == 0) {
            try {
              Iterable lo = mJsonDecode(response.data)["data"]["commands"];
              if (lo == null || lo.isEmpty || lo.length == 0)
                return [];

              /// else
              List<CommandModel>? commandModel = lo
                  ?.map((command) => CommandModel.fromJson(command))
                  ?.toList();
              return commandModel;
            } catch (_) {
              return [];
            }
          } else
            throw Exception(-1); // there is an error in your request
        }
      } catch (_) {
        xrint(_);
        return [];
      }
    } else {
      throw Exception(-2);
    }
  }
}
