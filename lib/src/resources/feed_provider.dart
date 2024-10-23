//FeedsProvider


import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


import 'package:dio/dio.dart';

class FeedApiProvider {


  Future<Object> fetchFeedList (CustomerModel customer) async {

    xrint("entered getFeedHistory");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_LASTEST_FEEDS),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(Uri.parse(ServerRoutes.LINK_GET_LASTEST_FEEDS).toString(),
          data: json.encode({}));

      print(response.statusCode);

      xrint(response.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["notification_feeds"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return List<FeedModel>();
          else {
            List<FeedModel> feeds = lo?.map((feed) =>
                FeedModel.fromJson(feed))?.toList();
            return feeds;
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