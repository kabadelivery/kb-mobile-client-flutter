import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/resources/app_api_provider.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/resources/commands_api_provider.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';

import 'models/CustomerModel.dart';

class Repository {

  final appApiProvider = AppApiProvider();
  Future<String> fetchHomeScreenModel() => appApiProvider.fetchHomeScreenModel();
  // Future<List<ShopModel>> fetchRestaurantList(CustomerModel customer, Position position) => appApiProvider.fetchRestaurantList(customer, position);
  // Future<List<ShopModel>> fetchFoodFromRestaurantByName(String desc) => appApiProvider.fetchFoodFromRestaurantByName(desc);
//Future<DeliveryAddressModel> checkLocationDetails (UserTokenModel userToken, Position position) => appApiProvider.checkLocationDetails(userToken, position);


  /* client personal api provider */
  final clientApiProvider = ClientPersonalApiProvider();
  Future<List<CommentModel>> fetchRestaurantComment(ShopModel restaurantModel, UserTokenModel userToken) => clientApiProvider.fetchRestaurantComment(restaurantModel, userToken);
  Future<List<DeliveryAddressModel>> fetchMyAddresses(UserTokenModel userToken) => clientApiProvider.fetchMyAddresses(userToken);
//  Future<int> registerSendingCodeAction(String login) => clientApiProvider.registerSendingCodeAction(login);



  /* restaurant personal api provider */
  final restaurantApiProvider = RestaurantApiProvider();
  Future<List<RestaurantSubMenuModel>> fetchRestaurantMenuList(ShopModel restaurantModel) => restaurantApiProvider.fetchRestaurantMenuList(restaurantModel);

  /* command api provider */
  final commandApiProvider = CommandsApiProvider();
  Future<List<CommandModel>> fetchDailyOrders(CustomerModel customer) => commandApiProvider.fetchDailyOrders(customer);
  Future<List<CommandModel>> fetchLastOrders(CustomerModel customer) => commandApiProvider.fetchLastOrders(customer);


  /* command details provider */
  Future<CommandModel> fetchOrderDetails(CustomerModel customer, int orderId) => commandApiProvider.fetchOrderDetails(customer, orderId);


}