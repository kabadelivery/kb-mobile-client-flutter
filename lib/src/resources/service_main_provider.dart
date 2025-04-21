import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class ServiceMainApiProvider {
  Future<Object> fetchCategories() async {
    xrint("entered fetchCategories");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_GET_SERVICE_CATEGORIES).toString(),
          data: json.encode({}));

      print(response.statusCode);

      xrint(response.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo =
              mJsonDecode(response.data)["data"]["notification_feeds"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return [];
          else {
            List<FeedModel>? feeds =
                lo?.map((feed) => FeedModel.fromJson(feed))?.toList();
            return feeds!;
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
