import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class CinemaApiProvider {
  Future<Map> fetchMovieScheduleWithCinemaId(cinemaId) async {
    xrint("entered fetchMovieScheduleWithCinemaId");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        // ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      /* to do again */
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_MENU_BY_RESTAURANT_ID).toString(),
        data: json.encode({'id': cinemaId}),
      );

      xrint(response.data);
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<Map> fetchMovieDetailsWithMovieId(int movieId) {}
}
