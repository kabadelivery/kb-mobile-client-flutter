import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:http/http.dart' show Client;
import 'dart:convert';

import 'package:kaba_flutter/src/models/TransactionModel.dart';
import 'package:kaba_flutter/src/utils/_static_data/ServerRoutes.dart';
import 'package:kaba_flutter/src/utils/functions/DebugTools.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
//import '../models/RestaurantModel.dart';

class RestaurantApiProvider {

  Client client = Client();
//  final _apiKey = 'your_api_key';

 /* Future<_RestaurantModel> fetchRestaurantHomeList() async {

    print("entered");
    final response = await client
        .get("http://api.themoviedb.org/3/movie/popular?api_key=$_apiKey");
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return _RestaurantModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }*/

  Future<List<TransactionModel>> fetchTransactionHistory() async {

    /* we also need the token of the user for him to be identified! */
    DebugTools.iPrint("entered fetchTransactionHistory");
    final response = await client
//    .get(ServerRoutes.LINK_GET_TRANSACTION_HISTORY);
        .post(ServerRoutes.LINK_GET_TRANSACTION_HISTORY,
        headers: Utils.getHeaders());
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      int errorCode = json.decode(response.body)["error"];
//      return List<TransactionModel>.fromJson(json.decode(response.body)["data"]);
      List rawList = json.decode(response.body)["data"];
      List<TransactionModel> transactions =
      rawList.map((model) => TransactionModel.fromJson(model)).toList();
    } else if (response.statusCode == 403) {
      /* sends a forbidden when the user account has expired or anything else.  */
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
