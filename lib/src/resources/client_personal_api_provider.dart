import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/utils/ssl/ssl_validation_certificate.dart';
import 'package:KABA/src/xrint.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' show Client, MultipartRequest, StreamedResponse;
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/TransactionModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';


class ClientPersonalApiProvider {


  var TGO = "228";

  /// COMMENTS
  ///
  /// Get restaurants comments list
  fetchRestaurantComment(RestaurantModel restaurantModel, UserTokenModel userToken) async {
    xrint("entered fetchRestaurantComment");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_RESTAURANT_REVIEWS),
          body: json.encode({'restaurant_id': restaurantModel.id.toString()}),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 30));
*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(userToken?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_RESTAURANT_REVIEWS).toString(),
        data: json.encode({'restaurant_id': restaurantModel.id.toString()}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          String stars = mJsonDecode(response.data)["data"]["stars"];
          String votes = mJsonDecode(response.data)["data"]["votes"];
          Iterable lo = mJsonDecode(response.data)["data"]["comments"];
          List<CommentModel> comments = lo?.map((comment) => CommentModel.fromJson(comment))?.toList();

          Map<String, dynamic> res = Map();
          res.putIfAbsent("stars",()=> stars);
          res.putIfAbsent("votes",() => votes);
          res.putIfAbsent("comments",() => comments);

          return res;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /// User Delivery Addresses
  ///
  /// Get customer account's delivery address
  Future<List<DeliveryAddressModel>> fetchMyAddresses(UserTokenModel userToken) async {
    xrint("entered fetchMyAddresses");
    if (await Utils.hasNetwork()) {

      /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_ADRESSES),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 30));
*/
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(userToken.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_ADRESSES).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"]["adresses"];
          List<DeliveryAddressModel> addresses = lo?.map((address) => DeliveryAddressModel.fromJson(address))?.toList();
          return addresses;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /* register sending code */
  Future<String> registerSendingCodeAction (String login) async {
    xrint("entered registerSendingCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));

      /*final response = await client
          .post(Uri.parse(Utils.isEmailValid(login) ? ServerRoutes.LINK_SEND_VERIFCATION_EMAIL_SMS : ServerRoutes.LINK_SEND_VERIFCATION_SMS),
          body:
          Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      )
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(Utils.isEmailValid(login) ? ServerRoutes.LINK_SEND_VERIFCATION_EMAIL_SMS : ServerRoutes.LINK_SEND_VERIFCATION_SMS).toString(),
          data:  Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> checkRequestCodeAction(String code, String requestId) async {

    /*  */
    xrint("entered checkRequestCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_VERIFCATION_CODE),
          body: json.encode({"code": code, "request_id": requestId}))
          .timeout(const Duration(seconds: 60));
      */

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_CHECK_VERIFCATION_CODE).toString(),
          data: json.encode({"code": code, "request_id": requestId})
      );

      xrint(json.encode({"code": code, "request_id": requestId}));
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> registerCreateAccountAction({String nickname, String password, String phone_number="", String email="", String request_id, String whatsapp_number}) async {

    xrint("entered registerCreateAccountAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_USER_REGISTER),
          body: json.encode({"nickname": nickname, "password": password, "whatsapp_number": whatsapp_number, "phone_number": phone_number, "email": email, "request_id":request_id, 'type': Utils.isEmailValid(email) ? 1 : 0}))
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_USER_REGISTER).toString(),
          data: json.encode({"nickname": nickname, "password": password, "whatsapp_number": whatsapp_number, "phone_number": phone_number, "email": email, "request_id":request_id, 'type': Utils.isEmailValid(email) ? 1 : 0})
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /*
  Future<String> loginAction({String login, String password}) async {

    xrint("entered loginAction");
    if (await Utils.hasNetwork()) {
//      await Future.delayed(const Duration(seconds: 1));
      var request =   MultipartRequest("POST", Uri.parse(ServerRoutes.LINK_USER_LOGIN));
      request.fields['_username'] = "${login}";
      request.fields['_password'] = "${password}";
      /*    request.files.add(http.MultipartFile.fromPath(
        'package',
        'build/package.tar.gz',
        contentType: new MediaType('application', 'x-tar'),
      ));*/
      try {
        StreamedResponse send = await request.send();
        String body = await send.stream.transform(utf8.decoder).single;
        return body;
      } catch (_) {
        throw Exception(-1); // system error
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }*/

  Future<dynamic> loginAction({String login, String password, String app_version, bool shouldSendOtpCode}) async {

    xrint("entered loginAction");
    if (await Utils.hasNetwork()) {

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      var device;

      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      String token = await firebaseMessaging.getToken();

      if (Platform.isAndroid) {
        // Android-specific code
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        xrint('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
        device = {
          'app_version' : 'Flutter $app_version',
          'os_version':'${androidInfo.version.baseOS}',
          'build_device':'${androidInfo.device}',
          'version_sdk':'${androidInfo.version.sdkInt}',
          'build_model':'${androidInfo.model}',
          'build_product':'${androidInfo.product}',
          'push_token':'$token'
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        xrint('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
        device = {
          'app_version' : 'Flutter $app_version',
          'os_version':'${iosInfo.systemVersion}',
          'build_device':'${iosInfo.utsname.sysname}',
          'version_sdk':'${iosInfo.utsname.version}',
          'build_model':'${iosInfo.utsname.machine}',
          'build_product':'${iosInfo.model}',
          'push_token':'$token'
        };
      }

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_USER_LOGIN_V2),
        body:  json.encode({"username": login, "password":password, 'device':device }),
      ).timeout(const Duration(seconds: 30));
      */
      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        !shouldSendOtpCode ?  Uri.parse(ServerRoutes.LINK_USER_LOGIN_V2).toString() :  Uri.parse(ServerRoutes.LINK_USER_LOGIN_V3).toString(),
        data: json.encode({"username": login, "password":password, 'device':device }),
      );

      // xrint(response.data);
      // return json.encode(response.data);
      return response.data;
    } else {
      throw Exception(-2); // there is an error in your request
    }
  }

  /// UPDATE CUSTOMER INFORMATIONS -nickname, job, district ... -
  ///
  ///
  Future<CustomerModel> updatePersonnalPage(CustomerModel customer) async {
    xrint("entered updatePersonnalPage");
    if (await Utils.hasNetwork()) {
      var _data = json.encode({'nickname':customer.nickname, 'whatsapp_number': customer.whatsapp_number, 'district':customer.district, 'job_title':customer.job_title, 'email': customer.email, 'gender':customer.gender, 'birthday':customer.birthday});
      if (customer.profile_picture != null)
        _data = json.encode({'nickname':customer.nickname,'district':customer.district, 'whatsapp_number': customer.whatsapp_number, 'job_title':customer.job_title, 'email': customer.email, 'gender':customer.gender, 'birthday':customer.birthday, 'profile_picture' : customer.profile_picture });

      /* final response = await client
          .post(Uri.parse(ServerRoutes.LINK_UPDATE_USER_INFORMATIONS),
          body: _data,
          headers: Utils.getHeadersWithToken(customer?.token)).timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_UPDATE_USER_INFORMATIONS).toString(),
        data:  _data,
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          /* return resulting customer that has to be saved in the shared preferences again. */
          var obj = mJsonDecode(response.data);
          customer = CustomerModel.fromJson(obj["data"]);
          return customer;
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
  Future<List<TransactionModel>> fetchTransactionsHistory(CustomerModel customer) async {

    xrint("entered fetchLastTransactions");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_TRANSACTION_HISTORY),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 60));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 60000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_GET_TRANSACTION_HISTORY).toString(),
        data: json.encode({}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          Iterable lo = mJsonDecode(response.data)["data"];
          if (lo == null || lo.isEmpty || lo.length == 0)
            return List<TransactionModel>();
          List<TransactionModel> transactionModel = lo?.map((command) => TransactionModel.fromJson(command))?.toList();
          return transactionModel;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  checkBalance(CustomerModel customer) async {

    xrint("entered checkBalance");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_GET_BALANCE),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 60));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 60000
      ;
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

  launchTopUp(CustomerModel customer, String phoneNumber, String balance, double fees) async {

    xrint("entered launchTopUp");
    if (await Utils.hasNetwork()) {
      /*  final response = await client
          .post(Uri.parse(Utils.isPhoneNumber_Tgcel(phoneNumber) ? ServerRoutes.LINK_TOPUP_TMONEY : ServerRoutes.LINK_TOPUP_FLOOZ),
          body: json.encode({"phone_number": phoneNumber, "amount": balance, 'fees':'$fees'}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(Utils.isPhoneNumber_Tgcel(phoneNumber) ? ServerRoutes.LINK_TOPUP_TMONEY : ServerRoutes.LINK_TOPUP_FLOOZ).toString(),
        data:  json.encode({"phone_number": phoneNumber, "amount": balance, 'fees':'$fees'}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          // String link = mJsonDecode(response.data)["data"]["url"];
          // return link;
          return response.data;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  launchPayDunya(CustomerModel customer, String balance, double fees) async {
    xrint("entered launchPayDunya ${json.encode({"amount": balance, 'fees':'$fees'})} ${ServerRoutes.LINK_TOPUP_PAYDUNYA}");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_TOPUP_PAYDUNYA),
          body: json.encode({"amount": balance, 'fees':'$fees'}),
          headers: Utils.getHeadersWithToken(customer?.token))
          .timeout(const Duration(seconds: 30));
      */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_TOPUP_PAYDUNYA).toString(),
        data: json.encode({"amount": balance, 'fees':'$fees'}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          return response.data;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }


  launchTransferMoneyRequest(CustomerModel customer, String username) async {

    xrint("entered launchTransferMoneyRequest");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_USER_ACCOUNT),
          body: json.encode({"username": username}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));
    */

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_CHECK_USER_ACCOUNT).toString(),
        data: json.encode({"username": username}),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == -2) {
          return null;
        } else {
          CustomerModel customer = new CustomerModel();
          customer.id = mJsonDecode(response.data)["data"]["id"];
          customer.nickname = mJsonDecode(response.data)["data"]["username"];
          customer.phone_number = mJsonDecode(response.data)["data"]["phone_number"];
          customer.profile_picture = mJsonDecode(response.data)["data"]["pic"];
          return customer;
        }
      }
      else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  launchTransferMoneyAction(CustomerModel customer, int receiverId, String transaction_password, String amount) async {

    xrint("entered launchTransferMoneyAction");
    if (await Utils.hasNetwork()) {

      /*final response = await client
          .post(Uri.parse(ServerRoutes.LINK_MONEY_TRANSFER),
          body: json.encode({"id": receiverId, "amount": amount, "transaction_password":transaction_password}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));
      */
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_MONEY_TRANSFER).toString(),
        data: json.encode({"id": receiverId, "amount": amount, "transaction_password":transaction_password}),
      );


      xrint(response.data.toString());
      if (response.statusCode == 200) {
        Map res = Map();
        int errorCode = mJsonDecode(response.data)["error"];
        res.putIfAbsent("errorCode", ()=> errorCode);
        if (errorCode == 0) {
          CustomerModel customer = CustomerModel.fromJson(mJsonDecode(response.data)["data"]["customer"]);
          res.putIfAbsent("customer", ()=>customer);
          res.putIfAbsent("statut", ()=>mJsonDecode(response.data)["data"]["statut"]);
          res.putIfAbsent("amount", ()=>mJsonDecode(response.data)["data"]["amount"]);
          res.putIfAbsent("balance", ()=>mJsonDecode(response.data)["data"]["balance"]);
        }
        return res;
      }
      else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<dynamic> fetchFees(CustomerModel customer) async {

    xrint("entered fetchFees");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_TOPUP_FEES_RATE_V2),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));
*/
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_TOPUP_FEES_RATE_V2).toString(),
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        // check the fees, if an error during this process, throw error no pb
//        int fees_flooz = mJsonDecode(response.body)["data"]["fees_flooz"];
//        int fees_tmoney = mJsonDecode(response.body)["data"]["fees_tmoney"];
//        int fees_bankcard = mJsonDecode(response.body)["data"]["fees_bankcard"];
        /* if (fees > 0)
          return fees;
        return 10;*/
        return mJsonDecode(response.data)["data"];
      }
      else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> recoverPasswordSendingCodeAction (String login) async {
    xrint("entered recoverPasswordSendingCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));
      /*   final response = await client
          .post(Uri.parse(ServerRoutes.LINK_SEND_RECOVER_VERIFCATION_SMS),
          body:
          Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_SEND_RECOVER_VERIFCATION_SMS).toString(),
          data: Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      );


      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> checkRecoverPasswordRequestCodeAction(String code, String requestId) async {

    /*  */
    xrint("entered checkRecoverPasswordRequestCodeAction");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_CHECK_RECOVER_VERIFCATION_CODE),
          body: json.encode({"code": code, "request_id": requestId}))
          .timeout(const Duration(seconds: 60));*/

      var dio = Dio();
      dio.options
        ..connectTimeout = 60000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_CHECK_RECOVER_VERIFCATION_CODE).toString(),
          data: json.encode({"code": code, "request_id": requestId})
      );

      xrint(json.encode({"code": code, "request_id": requestId}));
      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String>  passwordResetAction(String login, String newCode, String requestId) async {

    xrint("entered passwordResetAction");
    if (await Utils.hasNetwork()) {

      /*  final response = await client
          .post(Uri.parse(ServerRoutes.LINK_PASSWORD_RESET),
          body: Utils.isEmailValid(login) ?
          json.encode({"password": newCode, "request_id": requestId, "email":"${login}"}) :
          json.encode({"password": newCode, "request_id": requestId, "phone_number":"228${login}"}) )
          .timeout(const Duration(seconds: 60));*/

      var dio = Dio();
      dio.options
        ..connectTimeout = 60000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_PASSWORD_RESET).toString(),
          data: Utils.isEmailValid(login) ?
          json.encode({"password": newCode, "request_id": requestId, "email":"${login}"}) :
          json.encode({"password": newCode, "request_id": requestId, "phone_number":"228${login}"})
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return response.data;
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

      /*final response = await client
          .post(Uri.parse(ServerRoutes.GET_KABA_POINTS),
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer?.token)
      )
          .timeout(const Duration(seconds: 30));*/

      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
        ..connectTimeout = 30000
      ;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
          Uri.parse(ServerRoutes.GET_KABA_POINTS).toString(),
          data: json.encode({})
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          int kabaPoints = mJsonDecode(response.data)["total_kaba_point"]/*["balance"]*/;
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



}
