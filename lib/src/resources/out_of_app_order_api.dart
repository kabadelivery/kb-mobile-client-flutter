import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/CustomerModel.dart';
import '../models/DeliveryAddressModel.dart';
import '../models/OrderBillConfiguration.dart';
import '../models/VoucherModel.dart';
import '../utils/_static_data/ServerRoutes.dart';
import '../utils/functions/OutOfAppOrder/imagePicker.dart';
import '../utils/functions/Utils.dart';
import '../utils/ssl/ssl_validation_certificate.dart';
import '../xrint.dart';

class OutOfAppOrderApiProvider{
  Future<OrderBillConfiguration> computeBillingAction(
      CustomerModel customer,
      List<DeliveryAddressModel>? order_adress,
      List<Map<String, dynamic>> foods,
      DeliveryAddressModel? shipping_adress,
      VoucherModel? voucher,
      bool useKabaPoints) async {
    xrint("entered computeBillingAction");

    if (!await Utils.hasNetwork()) {
      throw Exception(-2); // pas de réseau
    }

    // Préparer les IDs des adresses
    var order_adress_ids = <int>[];
    if (order_adress != null) {
      for (DeliveryAddressModel adress in order_adress) {
        order_adress_ids.add(adress.id!);
      }
    }
    // JSON de base
    Map<String, dynamic> requestData = {
      'order_details': foods,
      'order_address': order_adress_ids.isEmpty ? [0] : order_adress_ids,
      'shipping_address': shipping_adress!.id,
      "voucher_id": voucher?.id,
      "use_kaba_point": useKabaPoints,
      "pay_at_delivery": true,
    };
    try {
      var dio = Dio();
      dio.options.headers = Utils.getHeadersWithToken(customer.token!);
      var abonnementResponse = await dio.post(
        ServerRoutes.KABA_ABONNEMENT_GET_BY_USER,
        data: {
          "userId": customer.id!,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (abonnementResponse.statusCode == 200 ||abonnementResponse.statusCode == 201) {
        requestData['user_abonnement'] = abonnementResponse.data;
      } else {
        xrint("KABA_ABONNEMENT_GET_BY_USER failed: ${abonnementResponse.statusCode}");
        requestData['user_abonnement'] = {};
      }
    } catch (e) {
      xrint("KABA_ABONNEMENT_GET_BY_USER exception: $e");
      requestData['user_abonnement'] = {};
    }

    // Encode le JSON final
    var _data = json.encode(requestData);
    xrint(_data.toString());

    // === Appel à LINK_OUT_OF_APP_COMPUTE_BILLING ===
    try {
      var dio = Dio();
      dio.options
        ..headers = {
          ...Utils.getHeadersWithToken(customer.token!),
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0"
        }
        ..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      xrint("customer.token! ${customer.token!}");
      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_OUT_OF_APP_COMPUTE_BILLING).toString(),
        data: _data,
      );

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return OrderBillConfiguration.fromJson(
            mJsonDecode(response.data)["data"]);
      } else {
        xrint("computeBilling error ${response.statusCode}");
        throw Exception(-1); // erreur côté serveur
      }
    } catch (e) {
      xrint("computeBilling exception: $e");
      throw Exception(-1);
    }
  }

  Future<int> launchOrder(
      bool isPayAtDelivery,
      CustomerModel customer,
      List<DeliveryAddressModel> order_address,
      List<Map<String,dynamic>> foods,
      DeliveryAddressModel selectedAddress,
      String mCode,
      String infos,
      VoucherModel voucher,
      bool useKabaPoint,
      int order_type,
      String phone_number,
      String infos_image
      ) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var device;

    String? token = "";
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
    } catch (e) {
      xrint(e);
    }

    // Récupération des infos device
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = {
        "os_version": "${androidInfo.version.baseOS}",
        "build_device": "${androidInfo.device}",
        "version_sdk": "${androidInfo.version.sdkInt}",
        "build_model": "${androidInfo.model}",
        "build_product": "${androidInfo.product}",
        "push_token": "$token"
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = {
        "os_version": "${iosInfo.systemVersion}",
        "build_device": "${iosInfo.utsname.sysname}",
        "version_sdk": "${iosInfo.utsname.version}",
        "build_model": "${iosInfo.utsname.machine}",
        "build_product": "${iosInfo.model}",
        "push_token": "$token"
      };
    }

    xrint("entered launchOrder");

    if (!await Utils.hasNetwork()) {
      throw Exception(-2); // pas de réseau
    }
    var order_adress_ids = <int>[];
    for (DeliveryAddressModel adress in order_address) {
      order_adress_ids.add(adress.id!);
    }
    List<Map<String,dynamic>> formData = [];
    for (var food in foods) {
      formData.add({
        'name': food['name'],
        'price': food['price'].toString(),
        'quantity': food['quantity'].toString(),
        'image': food['image'].toString(),
      });
    }

    // JSON de base
    Map<String,dynamic> requestData = {
      'order_details': formData,
      'order_address': order_adress_ids.isEmpty ? [0] : order_adress_ids,
      'pay_at_delivery': isPayAtDelivery,
      'shipping_address': selectedAddress.id,
      'transaction_password': mCode,
      'infos': infos,
      "infos_image": infos_image,
      'device': device,
      'push_token': token,
      "voucher_id": voucher?.id,
      "use_kaba_point": useKabaPoint,
      "order_type": order_type,
      "phone_number": phone_number,
    };
     var abonnementData ={};
    try {
      var dio = Dio();
      dio.options.headers = Utils.getHeadersWithToken(customer.token!);
      var abonnementResponse = await dio.post(
        ServerRoutes.KABA_ABONNEMENT_GET_BY_USER,
        data: {
          "userId": customer.id!,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (abonnementResponse.statusCode == 200 ||abonnementResponse.statusCode == 201) {
        abonnementData= abonnementResponse.data;
        requestData['user_abonnement'] = abonnementResponse.data;
      } else {
        xrint("KABA_ABONNEMENT_GET_BY_USER failed: ${abonnementResponse.statusCode}");
        requestData['user_abonnement'] = {};
      }
    } catch (e) {
      xrint("KABA_ABONNEMENT_GET_BY_USER exception: $e");
      requestData['user_abonnement'] = {};
    }

    // Encode le JSON final
    var _data = json.encode(requestData);
    xrint("Request data: $_data");

    // === Appel à LINK_OUT_OF_APP_CREATE_COMMAND ===
    try {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 90000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };

      var response = await dio.post(
        Uri.parse(ServerRoutes.LINK_OUT_OF_APP_CREATE_COMMAND).toString(),
        data: _data,
      );

      xrint("Response data: ${response.data}");
      xrint("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        try{
          var sentData ={
            'user_id':customer.id.toString(),
            'subscription_id':abonnementData['pack']['id'].toString(),
            'codeAbo':abonnementData['codeAbonnement'].toString(),
            'command_id':mJsonDecode(response.data)['data']['command_id'].toString()
          };
          debugPrint("sentData $sentData");
          var responseAbo = await dio.post(
            Uri.parse(ServerRoutes.KABA_ABONNEMENT_SAVE_USER_ORDER).toString(),
            data:sentData,
          );
        }catch(_){}
        return mJsonDecode(response.data)["error"];

      } else {
        throw Exception(-1); // erreur côté serveur
      }
    } catch (e) {
      xrint("launchOrder exception: $e");
      throw Exception(-1);
    }
  }


  Future<dynamic> uploadMultipleImages(List<Map<String, dynamic>> formDataList,CustomerModel customer) async {
    try {
      Dio dio = Dio();
dio.options
  ..headers = {
    ...Utils.getHeadersWithToken(customer.token!),
    "Cache-Control": "no-cache, no-store, must-revalidate",
    "Pragma": "no-cache",
    "Expires": "0"
  }
  ..connectTimeout = 10000;

(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    (HttpClient client) {
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    return validateSSL(cert, host, port);
  };
};
      String url = ServerRoutes.LINK_UPLOAD_PRODUCT_IMAGE;
      List<Map<String, dynamic>> orderDetailsWithImages = [];
      for (var i = 0; i < formDataList.length; i++) {
        var order = formDataList[i];


        if(order['image']!=null && order['image'] is File){
          final originalSize = await order['image'].length();
          xrint("Original image size [${order['name']}]: ${(originalSize / (1024 * 1024)).toStringAsFixed(2)} MB");
          XFile? compressedImage  = await compressImage(order['image']);
          Map<String, dynamic> orderDetail = {
            'name': order['name'],
            'price': order['price'].toString(),
            'quantity': order['quantity'].toString(),
            'image':compressedImage==null?await imageToBase64File(order['image']):await imageToBase64XFile(compressedImage)
          };

        orderDetailsWithImages.add(orderDetail);
        }else{
           Map<String, dynamic> orderDetail = {
            'name': order['name'],
            'price': order['price'].toString(),
            'quantity': order['quantity'].toString(),
            'image':""
          };
          orderDetailsWithImages.add(orderDetail);
        }
      }

      xrint("FormData fields: ${orderDetailsWithImages}");

      Response response = await dio.post(
        url,
        data: json.encode({"orderDetails":orderDetailsWithImages}),
      );

      xrint("response.data ${response.data}");
     return response.data['orders'];
    } catch (e, stackTrace) {
      xrint("Error: $e");
      xrint("StackTrace: $stackTrace");

      return "Error: $e\nLine: ${stackTrace.toString().split("\n")[0]}";
    }
  }
  Future<List<Map<String, dynamic>>> fetchDistricts(CustomerModel customer)async {
        try{
          Dio dio = Dio();
          dio.options
            ..headers = {
              ...Utils.getHeadersWithToken(customer.token!),
              "Cache-Control": "no-cache, no-store, must-revalidate",
              "Pragma": "no-cache",
              "Expires": "0"
            }
            ..connectTimeout = 10000;

          (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
              (HttpClient client) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) {
              return validateSSL(cert, host, port);
            };
          };
          String url = ServerRoutes.FETCH_DISTRICTS;
          Response response = await dio.post(url);

          List<Map<String, dynamic>> districts = List<Map<String, dynamic>>.from(
              response.data['districts'].map((item) => Map<String, dynamic>.from(item))
          );
          xrint("response.data ${districts}");
          return districts;
        }catch(e){
          xrint("error $e");
          return [{"name":""}];
  }
  }
  Future<Map<String, dynamic>?> fetchShippingPriceRange(CustomerModel customer)async {
    try{
      Dio dio = Dio();
      dio.options
        ..headers = {
          ...Utils.getHeadersWithToken(customer.token!),
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0"
        }
        ..connectTimeout = 10000;

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      String url = ServerRoutes.FETCH_SHIPPING_PRICE_RANGE;
      Response response = await dio.post(url);

      Map<String, dynamic> range =  response.data['range'];
      xrint("response.data ${range}");
      return range;
    }catch(e){

      xrint("XXX fetchShippingPriceRange error : $e");
    }
  }

}