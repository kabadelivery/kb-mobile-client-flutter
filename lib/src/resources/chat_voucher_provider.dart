import 'dart:io';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class ChatVoucherProvider {
  Future<VoucherModel> fetchVoucherDetails(
      CustomerModel customer, String voucher_code) async {
    xrint("entered fetchVoucherDetails");
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

      var response = await dio.get(
          Uri.parse(ServerRoutes.LINK_GET_VOUCHER_DETAILS).toString() +
              "/${voucher_code}");

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          var obj = mJsonDecode(response.data)["data"];
          if (obj != null) {
            return VoucherModel.fromJson(obj);
          } else {
            throw Exception(-1);
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
}
