import 'dart:async';

import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/resources/app_api_provider.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';

class Repository {

  final appApiProvider = AppApiProvider();

  Future<HomeScreenModel> fetchHomeScreenModel() => appApiProvider.fetchHomeScreenModel();
  Future<List<RestaurantModel>> fetchRestaurantList() => appApiProvider.fetchRestaurantList();


  /* client personal api provider */

  final clientApiProvider = ClientPersonalApiProvider();

  Future<List<CommentModel>> fetchRestaurantComment(RestaurantModel restaurantModel) => clientApiProvider.fetchRestaurantComment(restaurantModel);

}