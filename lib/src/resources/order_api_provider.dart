import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/OrderBillConfiguration.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class OrderApiProvider {

  Client client = Client();


  Future<OrderBillConfiguration> computeBillingAction (CustomerModel customer,Map<RestaurantFoodModel, int> foods, DeliveryAddressModel address) async {

    DebugTools.iPrint("entered computeBillingAction");
    if (await Utils.hasNetwork()) {

      List<Object> food_quantity = List();
      foods.forEach((food_item, quantity) => {
        food_quantity.add({'food_id': food_item.id, 'quantity' : quantity})
      });

      final response = await client
          .post(ServerRoutes.LINK_COMPUTE_BILLING,
        body:  json.encode({'food_command': food_quantity, 'restaurant_id': foods.keys.elementAt(0).restaurant_id, 'shipping_address': address.id}),
          headers: Utils.getHeadersWithToken(customer.token)
      )
          .timeout(const Duration(seconds: 10));

//      jsonObject.put("food_id", entity.id);
//      jsonObject.put("quantity", quantity);

//      main_object.put("food_command", dataArray);
//      main_object.put( "restaurant_id", restaurantEntity.id);
//      main_object.put("shipping_address", deliveryAddress.id);


      print(response.body.toString());
      if (response.statusCode == 200) {

      } else
        throw Exception(-1); // there is an error in your request
    } else {
//      throw Exception(response.statusCode); // you have no right to do this
    }
  }

}
