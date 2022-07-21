import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/EvenementModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

import 'package:http/http.dart';

class AppApiProvider {
  Future<dynamic> fetchHomeScreenModel() async {
    xrint("entered fetchHomeScreenModel");
    if (await Utils.hasNetwork()) {
/*
      final response = await client
          .get(Uri.parse(ServerRoutes.LINK_HOME_PAGE),
          headers: Utils.getHeaders()).timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_HOME_PAGE).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0)
          return response.data;
        else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /* send the location and get back the not far from */
  Future<DeliveryAddressModel> checkLocationDetails(
      CustomerModel customer, Position position) async {
    xrint("entered checkLocationDetails");
    if (await Utils.hasNetwork()) {
      /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_LOCATION_DETAILS),
          body: position == null ? "" : json.encode(
              {"coordinates": "${position.latitude}:${position.longitude}"}),
          headers: Utils.getHeadersWithToken(customer.token)).timeout(
          const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_LOCATION_DETAILS).toString(),
        data: position == null
            ? ""
            : json.encode(
                {"coordinates": "${position.latitude}:${position.longitude}"}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          String description_details =
              mJsonDecode(response.data)["data"]["display_name"];
          String quartier = DeliveryAddressModel.fromJson(
                  mJsonDecode(response.data)["data"]["address"])
              .suburb;
          /* return only the content we need */
          DeliveryAddressModel deliveryAddressModel = DeliveryAddressModel(
              description: description_details, quartier: quartier);
          xrint("${description_details} , ${quartier}");
          return deliveryAddressModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<List<EvenementModel>> fetchEvenementList() async {
    /* get the events and show it */
    xrint("entered fetchEvenementList");
    if (await Utils.hasNetwork()) {
      /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_EVENEMENTS_LIST)).timeout(
          const Duration(seconds: 30));
*/

      var dio = Dio();
      dio.options..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_EVENEMENTS_LIST).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());

      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          List<EvenementModel> restaurantSubModel =
              lo?.map((comment) => EvenementModel.fromJson(comment))?.toList();
          return restaurantSubModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  updateToken(CustomerModel customer) async {
    /* get the events and show it */
    xrint("entered updateToken");

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String token = await firebaseMessaging.getToken(
        vapidKey:
            "BIGpDv3l5-XEgAyf9Y96gJ1vDTkQc0gH6v354UbR1flxhjl4UgRhKmqPaizF7ho4_rT5p2Pb8YBmUbAbwB0StY8");

    var _data;

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      xrint('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      _data = json.encode({
        'os_version': '${androidInfo.version.baseOS}',
        'build_device': '${androidInfo.device}',
        'version_sdk': '${androidInfo.version.sdkInt}',
        'build_model': '${androidInfo.model}',
        'build_product': '${androidInfo.product}',
        'push_token': '$token'
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      xrint('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      _data = json.encode({
        'os_version': '${iosInfo.systemVersion}',
        'build_device': '${iosInfo.utsname.sysname}',
        'version_sdk': '${iosInfo.utsname.version}',
        'build_model': '${iosInfo.utsname.machine}',
        'build_product': '${iosInfo.model}',
        'push_token': '$token'
      });
    }

    if (await Utils.hasNetwork()) {
      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_REGISTER_PUSH_TOKEN), body: _data,
          headers: Utils.getHeadersWithToken(customer.token))
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_REGISTER_PUSH_TOKEN).toString(),
        data: _data,
      );

      xrint(response.data.toString());

      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        return errorCode;
      } else
        throw Exception(-1); // there is an error in your request
    } else {}
  }

  checkUnreadMessages(customer) async {
//
    if (await Utils.hasNetwork()) {
      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_UNREAD_MESSAGES),
          headers: Utils.getHeadersWithToken(customer.token))
          .timeout(const Duration(seconds: 30));
      */
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_UNREAD_MESSAGES).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        bool data = mJsonDecode(response.data)["data"];
        return data;
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2);
    }
  }

  /*
  SELECT * FROM `food`, menu WHERE food.name LIKE '%piment%' AND
   food.menu_id = menu.id OR menu.name LIKE '%piment%' OR
   food.description LIKE '%piment%' GROUP BY food.id
  * */

  /*
  *  second proposal
  *
   SELECT food.name, (SELECT command.id FROM command WHERE command.food_command LIKE CONCAT("",food.id,"")) as order_count FROM `food`, menu WHERE food.name LIKE '%piment%' AND
   food.menu_id = menu.id OR menu.name LIKE '%piment%' OR
   food.description LIKE '%piment%' GROUP BY food.id ORDER BY order_count desc
  *
  * */

  /*
  fuck this

   SELECT food.name, (SELECT count(command.id) FROM command WHERE command.start_time > '2020-07-01'  AND command.food_command LIKE CONCAT("",food.id,"")) as order_count FROM `food`, menu WHERE food.name LIKE '%piment%' AND
   food.menu_id = menu.id OR menu.name LIKE '%piment%' OR
   food.description LIKE '%piment%' GROUP BY food.id ORDER BY order_count desc LIMIT 0,10

   */
  /* order by most sold count */
  fetchFoodFromRestaurantByName(String desc) async {
    if (await Utils.hasNetwork()) {
      /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_UNREAD_MESSAGES),
          body: {"desc":"${desc == null ? "" : desc}"}
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_UNREAD_MESSAGES).toString(),
        data: json.encode({"desc": "${desc == null ? "" : desc}"}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        bool data = mJsonDecode(response.data)["data"];
        return data;
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2);
    }
  }

  checkServiceMessage() async {
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_SYS_MESSAGE).toString(),
      );
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return mJsonDecode(response.data);
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2);
    }
  }

  checkVersion() async {
    if (await Utils.hasNetwork()) {
      /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_APP_VERSION)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_APP_VERSION).toString(),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        String version = mJsonDecode(response.data)["version"];
        int is_required =
            int.parse("${mJsonDecode(response.data)["isRequired"]}");
        Map res = Map();
        res["version"] = version;
        res["is_required"] = is_required;
        res["changeLog"] = mJsonDecode(response.data)["changeLog"];
        return res;
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2);
    }
  }

  /*hack */
  checkBalance(CustomerModel customer) async {
    xrint("entered checkBalance vHomePage");
    if (await Utils.hasNetwork()) {
      /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_BALANCE),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_BALANCE).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          String balance = mJsonDecode(response.data)["data"]["balance"];
          return balance;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  checkKabaPoints(CustomerModel customer) async {
    xrint("entered checkKabaPoints");
    if (await Utils.hasNetwork()) {
      /* final response = await client
          .post(Uri.parse(ServerRoutes.GET_KABA_POINTS),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
     */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.GET_KABA_POINTS).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          int kabaPoints =
              mJsonDecode(response.data)["total_kaba_point"] /*["balance"]*/;

          return "${kabaPoints}";
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<List<ServiceMainEntity>> fetchServiceCategoryFromLocation(
      String location) async {
    xrint("entered fetchServiceCategoryFromLocation");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        // ..headers = Utils.getHeadersWithToken(customer.token)
        ..connectTimeout = 30000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_SERVICE_CATEGORIES).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        Iterable lo = mJsonDecode(response.data)["services"];
        List<ServiceMainEntity> categories = lo
            ?.map((categorie) => ServiceMainEntity.fromJson(categorie))
            ?.toList();
        return categories;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
