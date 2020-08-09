import 'dart:convert';

import 'package:KABA/src/models/VoucherModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
import 'package:KABA/src/utils/functions/DebugTools.dart';
import 'package:KABA/src/utils/functions/Utils.dart';



class VoucherApiProvider {

  Client client = Client();

  loadVouchers({CustomerModel customer, int restaurantId = -1, List<int> foodsId, bool pick = false}) async {
/*
    return List.generate(3, (index) => VoucherModel.randomRestaurant()).toList()..addAll(
        List.generate(3, (index) => VoucherModel.randomBoth()).toList()
    )..addAll(
        List.generate(3, (index) => VoucherModel.randomDelivery()).toList()
    );
*/
    DebugTools.iPrint("entered loadVouchers");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_MY_VOUCHERS,
          body: restaurantId == -1 ? "" : json.encode({"restaurant_id": '${restaurantId}', 'foods': foodsId}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      String resp = response.body.toString();
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          Iterable lo = json.decode(response.body)["data"];
          if (lo == null) {
            return [];
          } else {
            List<VoucherModel> vouchers = lo?.map((voucher) =>
                VoucherModel.fromJson(voucher))?.toList();
            return vouchers;
          }
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    } /**/
  }

  subscribeVoucher(CustomerModel customer, String promoCode,
      {bool isQrCode = false}) async {
    DebugTools.iPrint("entered subscribeVoucher");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_SUBSCRIBE_VOUCHERS,
          body: json.encode(isQrCode ? {"qr_code": "${promoCode}"} : {
            "code": "${promoCode}"
          }),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          // rfeturn voucher , with instance of .
          return VoucherModel.fromJson(json.decode(response.body)["data"]);
        } else {
          // -1, -2,
          return errorCode;
        }
      } else
        throw Exception(-1); // there is an error in your request
    } else {
      throw Exception(-2); // you have no network
    }
  }
}