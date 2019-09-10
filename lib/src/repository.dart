import 'dart:async';

import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/resources/app_api_provider.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/resources/commands_api_provider.dart';
import 'package:kaba_flutter/src/resources/restaurant_api_provider.dart';

class Repository {

  final appApiProvider = AppApiProvider();
  Future<HomeScreenModel> fetchHomeScreenModel() => appApiProvider.fetchHomeScreenModel();
  Future<List<RestaurantModel>> fetchRestaurantList() => appApiProvider.fetchRestaurantList();


  /* client personal api provider */
  final clientApiProvider = ClientPersonalApiProvider();
  Future<List<CommentModel>> fetchRestaurantComment(RestaurantModel restaurantModel, UserTokenModel userToken) => clientApiProvider.fetchRestaurantComment(restaurantModel, userToken);

  /* restaurant personal api provider */
  final restaurantApiProvider = RestaurantApiProvider();
  Future<List<RestaurantSubMenuModel>> fetchRestaurantMenuList(RestaurantModel restaurantModel) => restaurantApiProvider.fetchRestaurantMenuList(restaurantModel);

  /* command api provider */
  final commandApiProvider = CommandsApiProvider();
  Future<List<CommandModel>> fetchDailyOrders(UserTokenModel userToken) => commandApiProvider.fetchDailyOrders(userToken);
  /* command details provider */
  Future<CommandModel> fetchOrderDetails(UserTokenModel userToken, int orderId) => commandApiProvider.fetchOrderDetails(userToken, orderId);


}