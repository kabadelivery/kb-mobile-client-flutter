import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
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

  Client client = Client();

  var TGO = "228";

  /// COMMENTS
  ///
  /// Get restaurants comments list
  fetchRestaurantComment(RestaurantModel restaurantModel, UserTokenModel userToken) async {
    DebugTools.iPrint("entered fetchRestaurantComment");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_RESTAURANT_REVIEWS,
          body: json.encode({'restaurant_id': restaurantModel.id.toString()}),
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String stars = json.decode(response.body)["data"]["stars"];
          String votes = json.decode(response.body)["data"]["votes"];
          Iterable lo = json.decode(response.body)["data"]["comments"];
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
    DebugTools.iPrint("entered fetchMyAddresses");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_ADRESSES,
          headers: Utils.getHeadersWithToken(userToken.token)).timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"]["adresses"];
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
    DebugTools.iPrint("entered registerSendingCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));
      final response = await client
          .post(Utils.isEmailValid(login) ? ServerRoutes.LINK_SEND_VERIFCATION_EMAIL_SMS : ServerRoutes.LINK_SEND_VERIFCATION_SMS,
          body:
          Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> checkRequestCodeAction(String code, String requestId) async {

    /*  */
    DebugTools.iPrint("entered checkRequestCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));
      final response = await client
          .post(ServerRoutes.LINK_CHECK_VERIFCATION_CODE,
          body: json.encode({"code": code, "request_id": requestId}))
          .timeout(const Duration(seconds: 60));
      print(json.encode({"code": code, "request_id": requestId}));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> registerCreateAccountAction({String nickname, String password, String phone_number="", String email="", String request_id}) async {

    DebugTools.iPrint("entered registerCreateAccountAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));
      final response = await client
          .post(ServerRoutes.LINK_USER_REGISTER,
          body: json.encode({"nickname": nickname, "password": password, "phone_number": phone_number, "email": email, "request_id":request_id, 'type': Utils.isEmailValid(email) ? 1 : 0}))
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  /*
  Future<String> loginAction({String login, String password}) async {

    DebugTools.iPrint("entered loginAction");
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

  Future<String> loginAction({String login, String password, String app_version}) async {

    DebugTools.iPrint("entered loginAction");
    if (await Utils.hasNetwork()) {

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      var device;

      final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
      String token = await firebaseMessaging.getToken();

      if (Platform.isAndroid) {
        // Android-specific code
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
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
        print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
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

      final response = await client
          .post(ServerRoutes.LINK_USER_LOGIN_V2,
        body:  json.encode({"username": login, "password":password, 'device':device }),
      ).timeout(const Duration(seconds: 30));
      print(response.body.toString());
        return response.body.toString();
    } else {
      throw Exception(-2); // there is an error in your request
    }
  }

  /// UPDATE CUSTOMER INFORMATIONS -nickname, job, district ... -
  ///
  ///
  Future<CustomerModel> updatePersonnalPage(CustomerModel customer) async {
    DebugTools.iPrint("entered updatePersonnalPage");
    if (await Utils.hasNetwork()) {
      var _data = json.encode({'nickname':customer.nickname,'district':customer.district, 'job_title':customer.job_title, 'email': customer.email, 'gender':customer.gender, 'birthday':customer.birthday});
      if (customer.profile_picture != null)
        _data = json.encode({'nickname':customer.nickname,'district':customer.district, 'job_title':customer.job_title, 'email': customer.email, 'gender':customer.gender, 'birthday':customer.birthday, 'profile_picture' : customer.profile_picture });
      final response = await client
          .post(ServerRoutes.LINK_UPDATE_USER_INFORMATIONS,
          body: _data,
          headers: Utils.getHeadersWithToken(customer.token)).timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          /* return resulting customer that has to be saved in the shared preferences again. */
          var obj = json.decode(response.body);
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

    DebugTools.iPrint("entered fetchLastTransactions");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_TRANSACTION_HISTORY,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
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

    DebugTools.iPrint("entered checkBalance");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_BALANCE,
          body: json.encode({}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String balance = json.decode(response.body)["data"]["balance"];
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

  launchTopUp(CustomerModel customer, String phoneNumber, String balance, int fees) async {

    DebugTools.iPrint("entered launchTopUp");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(Utils.isPhoneNumber_Tgcel(phoneNumber) ? ServerRoutes.LINK_TOPUP_TMONEY : ServerRoutes.LINK_TOPUP_FLOOZ,
          body: json.encode({"phone_number": phoneNumber, "amount": balance, 'fees':'$fees'}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String link = json.decode(response.body)["data"]["url"];
          return link;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  launchTransferMoneyRequest(CustomerModel customer, String phoneNumber) async {

    DebugTools.iPrint("entered launchTransferMoneyRequest");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_CHECK_USER_ACCOUNT,
          body: json.encode({"phone_number": phoneNumber}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == -2) {
          return null;
        } else {
          CustomerModel customer = new CustomerModel();
          customer.id = json.decode(response.body)["data"]["id"];
          customer.nickname = json.decode(response.body)["data"]["username"];
          customer.phone_number = json.decode(response.body)["data"]["phone_number"];
          customer.profile_picture = json.decode(response.body)["data"]["pic"];
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

    DebugTools.iPrint("entered launchTransferMoneyAction");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_MONEY_TRANSFER,
          body: json.encode({"id": receiverId, "amount": amount, "transaction_password":transaction_password}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        Map res = Map();
        int errorCode = json.decode(response.body)["error"];
        res.putIfAbsent("errorCode", ()=> errorCode);
        if (errorCode == 0) {
          CustomerModel customer = CustomerModel.fromJson(json.decode(response.body)["data"]["customer"]);
          res.putIfAbsent("customer", ()=>customer);
          res.putIfAbsent("statut", ()=>json.decode(response.body)["data"]["statut"]);
          res.putIfAbsent("amount", ()=>json.decode(response.body)["data"]["amount"]);
          res.putIfAbsent("balance", ()=>json.decode(response.body)["data"]["balance"]);
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

  Future<int> fetchFees(CustomerModel customer) async {

    DebugTools.iPrint("entered fetchFees");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_TOPUP_FEES_RATE,
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        // check the fees, if an error during this process, throw error no pb
        int fees = json.decode(response.body)["data"]["fees"];
        if (fees > 0)
          return fees;
        return 10;
      }
      else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> recoverPasswordSendingCodeAction (String login) async {
    DebugTools.iPrint("entered recoverPasswordSendingCodeAction");
    if (await Utils.hasNetwork()) {
      await Future.delayed(const Duration(seconds: 1));
      final response = await client
          .post(Utils.isEmailValid(login) ? ServerRoutes.LINK_SEND_VERIFCATION_EMAIL_SMS : ServerRoutes.LINK_SEND_RECOVER_VERIFCATION_SMS,
          body:
          Utils.isEmailValid(login) ?
          json.encode({"email": login, "type": 1}) :  json.encode({"phone_number": TGO + login, "type": 0})
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String> checkRecoverPasswordRequestCodeAction(String code, String requestId) async {

    /*  */
    DebugTools.iPrint("entered checkRecoverPasswordRequestCodeAction");
    if (await Utils.hasNetwork()) {
//      await Future.delayed(const Duration(seconds: 1));
      final response = await client
          .post(ServerRoutes.LINK_CHECK_RECOVER_VERIFCATION_CODE,
          body: json.encode({"code": code, "request_id": requestId}))
          .timeout(const Duration(seconds: 60));
      print(json.encode({"code": code, "request_id": requestId}));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }

  Future<String>  passwordResetAction(String phoneNumber, String newCode, String requestId) async {

    DebugTools.iPrint("entered passwordResetAction");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_PASSWORD_RESET,
          body: json.encode({"password": newCode, "request_id": requestId, "phone_number":"228${phoneNumber}"}))
          .timeout(const Duration(seconds: 60));
      print(response.body.toString());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }


}
