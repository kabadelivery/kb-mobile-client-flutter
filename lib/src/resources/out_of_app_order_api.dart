import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

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
      for(DeliveryAddressModel adress in order_adress){
        order_adress_ids.add(adress.id);
      }

      var _data = json.encode({
        'order_details': foods,
        'order_address': order_adress_ids,
        'shipping_address': shipping_adress.id,
        "voucher_id": voucher?.id,
        "use_kaba_point": useKabaPoints
      });

      xrint(_data.toString());
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

}