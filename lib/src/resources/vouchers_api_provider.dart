import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/VoucherModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class VoucherApiProvider {
  loadVouchers(
      {CustomerModel customer,
      int restaurantId = -1,
      List<int> foodsId,
      bool pick = false}) async {
    xrint("entered loadVouchers");
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
          Uri.parse(restaurantId == -1
                  ? ServerRoutes.LINK_GET_MY_VOUCHERS
                  : ServerRoutes.LINK_GET_VOUCHERS_FOR_ORDER)
              .toString(),
          data: restaurantId == -1
              ? ""
              : json.encode(
                  {"restaurant_id": '${restaurantId}', 'foods': foodsId}));

      xrint(response.data);
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          if (lo == null) {
            return [];
          } else {
            List<VoucherModel> vouchers =
                lo?.map((voucher) => VoucherModel.fromJson(voucher))?.toList();
            return vouchers;
          }
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
    /**/
  }

  subscribeVoucher(CustomerModel customer, String promoCode,
      {bool isQrCode = false}) async {
    xrint("entered subscribeVoucher");
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
          Uri.parse(ServerRoutes.LINK_SUBSCRIBE_VOUCHERS).toString(),
          data: json.encode(isQrCode
              ? {"qr_code": "${promoCode}"}
              : {"code": "${promoCode}"}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          return VoucherModel.fromJson(mJsonDecode(response.data)["data"]);
        } else {
          // -1, -2,
          return errorCode;
        }
      } else
        return -1;
    } else {
      throw Exception(-2); // you have no network
    }
  }

  subscribeVoucherForDamage(CustomerModel customer, int damage_id) async {
    xrint("entered subscribeVoucherForDamage");
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
          Uri.parse(ServerRoutes.LINK_GET_VOUCHER_FOR_DAMAGE).toString(),
          data: json.encode({"account_deleting_request_id": "${damage_id}"}));

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          // return voucher , with instance of .
          return VoucherModel.fromJson(mJsonDecode(response.data)["data"]);
        } else {
          // -1, -2,
          return errorCode;
        }
      } else
        return -1;
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
