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

  loadVouchers(CustomerModel customer) async {

    return List.generate(3, (index) => VoucherModel.randomRestaurant()).toList()..addAll(
        List.generate(3, (index) => VoucherModel.randomBoth()).toList()
    )..addAll(
        List.generate(3, (index) => VoucherModel.randomDelivery()).toList()
    );

    /*DebugTools.iPrint("entered loadVouchers");
    if (await Utils.hasNetwork()) {
      final response = await client
          .post(ServerRoutes.LINK_GET_LOCATION_DETAILS,
          body: json.encode({"coordinates": '${position.latitude}:${position.longitude}'}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 30));
      print(response.body.toString());
      if (response.statusCode == 200) {
        int errorCode = json.decode(response.body)["error"];
        if (errorCode == 0) {
          String description_details = json.decode(response.body)["data"]["display_name"];
          String suburb = json.decode(response.body)["data"]["address"]["suburb"];
          var m = Map();
          m.putIfAbsent("suburb", ()=>suburb);
          m.putIfAbsent("description_details", ()=>description_details);
          return m;

        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }*/
  }

}
