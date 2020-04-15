import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/CommentModel.dart';
import 'package:kaba_flutter/src/models/DeliveryAddressModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/resources/app_api_provider.dart';
import 'package:kaba_flutter/src/resources/client_personal_api_provider.dart';
import 'package:kaba_flutter/src/resources/commands_api_provider.dart';
import 'package:kaba_flutter/src/resources/restaurant_api_provider.dart';

import 'models/CustomerModel.dart';

class Repository {

  final appApiProvider = AppApiProvider();
  Future<String> fetchHomeScreenModel() => appApiProvider.fetchHomeScreenModel();
  Future<List<RestaurantModel>> fetchRestaurantList(Position position) => appApiProvider.fetchRestaurantList(position);
Future<DeliveryAddressModel> checkLocationDetails (UserTokenModel userToken, Position position) => appApiProvider.checkLocationDetails(userToken, position);


  /* client personal api provider */
  final clientApiProvider = ClientPersonalApiProvider();
  Future<List<CommentModel>> fetchRestaurantComment(RestaurantModel restaurantModel, UserTokenModel userToken) => clientApiProvider.fetchRestaurantComment(restaurantModel, userToken);
  Future<List<DeliveryAddressModel>> fetchMyAddresses(UserTokenModel userToken) => clientApiProvider.fetchMyAddresses(userToken);
//  Future<int> registerSendingCodeAction(String login) => clientApiProvider.registerSendingCodeAction(login);



  /* restaurant personal api provider */
  final restaurantApiProvider = RestaurantApiProvider();
  Future<List<RestaurantSubMenuModel>> fetchRestaurantMenuList(RestaurantModel restaurantModel) => restaurantApiProvider.fetchRestaurantMenuList(restaurantModel);

  /* command api provider */
  final commandApiProvider = CommandsApiProvider();
  Future<List<CommandModel>> fetchDailyOrders(CustomerModel customer) => commandApiProvider.fetchDailyOrders(customer);
  Future<List<CommandModel>> fetchLastOrders(CustomerModel customer) => commandApiProvider.fetchLastOrders(customer);


  /* command details provider */
  Future<CommandModel> fetchOrderDetails(CustomerModel customer, int orderId) => commandApiProvider.fetchOrderDetails(customer, orderId);


}