import 'dart:async';
import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/TransactionModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';



class AddressApiProvider {

  Client client = Client();

  /*Future<RestaurantModel> fetchRestaurantHomeList() async {

    print("entered");
    final response = await client
        .get("http://api.themoviedb.org/3/movie/popular?api_key=$_apiKey");
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return RestaurantModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }*/
//  }



}
