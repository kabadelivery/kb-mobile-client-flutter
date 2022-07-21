import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class CinemaApiProvider {


  Future<Map>   fetchMovieScheduleWithCinemaId(cinemaId) async {

    xrint("entered fetchMovieScheduleWithCinemaId");
    if (await Utils.hasNetwork()) {

      var dio = Dio();
      dio.options
        // ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
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
   /*   if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["menus"];
          List<RestaurantSubMenuModel> restaurantSubModel = lo?.map((menu) => RestaurantSubMenuModel.fromJson(menu))?.toList();
          ShopModel restaurantModel = ShopModel.fromJson(mJsonDecode(response.data)["data"]["resto"]);

          Map<String, dynamic> mapRes = new Map();
          mapRes.putIfAbsent("restaurant", () => restaurantModel);
          mapRes.putIfAbsent("menus", () => restaurantSubModel);

          return mapRes;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }*/
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<Map>  fetchMovieDetailsWithMovieId(int movieId) {}


}