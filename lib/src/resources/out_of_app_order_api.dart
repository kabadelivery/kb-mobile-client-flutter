import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/CustomerModel.dart';
import '../models/DeliveryAddressModel.dart';
import '../models/OrderBillConfiguration.dart';
import '../models/VoucherModel.dart';
import '../utils/_static_data/ServerRoutes.dart';
import '../utils/functions/Utils.dart';
import '../utils/ssl/ssl_validation_certificate.dart';
import '../xrint.dart';

class OutOfAppOrderApiProvider{
  Future<OrderBillConfiguration> computeBillingAction(
      CustomerModel customer,
      List<DeliveryAddressModel> order_adress,
      List<Map<String,dynamic>> foods,
      DeliveryAddressModel shipping_adress,
      VoucherModel voucher,
      bool useKabaPoints) async {
      xrint("entered computeBillingAction");
    if (await Utils.hasNetwork()) {
       var order_adress_ids= [];
       if(order_adress!=null){
         for(DeliveryAddressModel adress in order_adress){
           order_adress_ids.add(adress.id);
         }
       }

      var _data = json.encode({
        'order_details': foods,
        'order_address': order_adress_ids.isEmpty?[0]:order_adress_ids,
        'shipping_address': shipping_adress.id,
        "voucher_id": voucher?.id,
        "use_kaba_point": useKabaPoints,
        "pay_at_delivery":true
      });

      xrint(_data.toString());
      var dio = Dio();
      dio.options
      ..headers = {
    ...Utils.getHeadersWithToken(customer?.token),
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
      print("customer?.token ${customer?.token}");
      var response = await dio.post(
          Uri.parse(ServerRoutes.LINK_OUT_OF_APP_COMPUTE_BILLING).toString(),
          data: _data);

      xrint(response.data.toString());
      if (response.statusCode == 200) {
        return OrderBillConfiguration.fromJson(
            mJsonDecode(response.data)["data"]);
      } else {
        xrint("computeBilling error ${response.statusCode}");
        throw Exception(-1); // there is an error in your request
      }
    } else {
      throw Exception(-2); // you have no right to do this
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
      )async{

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    var device;

    String token = "";
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      token = await firebaseMessaging.getToken();
    } catch (e) {
      xrint(e);
    }

    if (Platform.isAndroid) {
      // Android-specific code
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      xrint("Running on ${androidInfo.model}"); // e.g. "Moto G (4)"
      device = {
        "os_version": "${androidInfo.version.baseOS}",
        "build_device": "${androidInfo.device}",
        "version_sdk": "${androidInfo.version.sdkInt}",
        "build_model": "${androidInfo.model}",
        "build_product": "${androidInfo.product}",
        "push_token": "$token"
      };
    }
    else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      xrint("Running on ${iosInfo.utsname.machine}"); // e.g. "iPod7,1"
      device = {
        "os_version": "${iosInfo.systemVersion}",
        "build_device": "${iosInfo.utsname.sysname}",
        "version_sdk": "${iosInfo.utsname.version}",
        'build_model': '${iosInfo.utsname.machine}',
        "build_product": "${iosInfo.model}",
        "push_token": "$token"
      };
    }
    xrint("entered payAtDelivery");
    if (await Utils.hasNetwork()) {
      var order_adress_ids= [];
      if(order_address!=null){
        for(DeliveryAddressModel adress in order_address){
          order_adress_ids.add(adress.id);
        }
      }

      List<Map<String,dynamic>> formData = [];

      for (int i = 0; i < foods.length; i++) {
        formData.add(
            {'name':  foods[i]['name'],
              'price': foods[i]['price'].toString(),
              'quantity': foods[i]['quantity'].toString(),
              'image': foods[i]['image'].toString(),
            }
        );
      }

      var _data = json.encode({
        'order_details': formData,
        'order_address': order_adress_ids.isEmpty?[0]:order_adress_ids,
        'pay_at_delivery': isPayAtDelivery,
        'shipping_address': selectedAddress.id,
        'transaction_password': '$mCode',
        'infos': '$infos',
        "infos_image":infos_image,
        'device': device, // device informations
        'push_token': '$token', // push token
        "voucher_id": voucher?.id,
        "use_kaba_point": useKabaPoint,
        "order_type":order_type,
        "phone_number":phone_number
      });

      xrint("000 _ " + _data.toString());
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer?.token)
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
          data: _data);

      xrint("001 _ " + response.data.toString());
      xrint("002 _status code  " + response.statusCode.toString());

      if (response.statusCode == 200) {
        // if ok, send true or false
        return mJsonDecode(response.data)["error"];
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // you have no right to do this
    }
  }

  Future<dynamic> uploadMultipleImages(List<Map<String, dynamic>> formDataList,CustomerModel customer) async {
    try {
      Dio dio = Dio();
dio.options
  ..headers = {
    ...Utils.getHeadersWithToken(customer?.token),
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
          Map<String, dynamic> orderDetail = {
            'name': order['name'],
            'price': order['price'].toString(),
            'quantity': order['quantity'].toString(),
            'image':await imageToBase64(order['image'])
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
      print("response.data ${response.data}");
     return response.data['orders'];
    } catch (e, stackTrace) {
      print("Error: $e");
      print("StackTrace: $stackTrace");

      return "Error: $e\nLine: ${stackTrace.toString().split("\n")[0]}";
    }
  }
  Future<List<Map<String, dynamic>>> fetchDistricts(CustomerModel customer)async {
        try{
          Dio dio = Dio();
          dio.options
            ..headers = {
              ...Utils.getHeadersWithToken(customer?.token),
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
          print("response.data ${districts}");
          return districts;
        }catch(e){
          xrint("error $e");
          return [{"name":""}];
  }
  }
  Future<Map<String, dynamic>> fetchShippingPriceRange(CustomerModel customer)async {
    try{
      Dio dio = Dio();
      dio.options
        ..headers = {
          ...Utils.getHeadersWithToken(customer?.token),
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
      print("response.data ${range}");
      return range;
    }catch(e){

      xrint("XXX fetchShippingPriceRange error : $e");
    }
  }
  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}