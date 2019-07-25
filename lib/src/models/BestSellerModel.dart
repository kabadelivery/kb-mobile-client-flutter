import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';


class BestSellerModel {

  /* best seller is a product */
  int ranking;
  int rating_quantity;
  int rating_percentage;
  List<int> history; /* yest, the day before, the day before before */
  RestaurantModel restaurant_entity;
  RestaurantFoodModel food_entity;

  BestSellerModel({this.restaurant_entity, this.food_entity, this.ranking, this.rating_quantity, this.rating_percentage, this.history});

  BestSellerModel.fromJson(Map<String, dynamic> json) {

    restaurant_entity = json['restaurant_entity'];
    food_entity = json['food_entity'];
    ranking = json['ranking'];
    rating_quantity = json['rating_quantity'];
    rating_percentage = json['rating_percentage'];
    history = json['history'];
  }

  Map toJson () => {
    "restaurant_entity" : restaurant_entity,
    "food_entity" : food_entity,
    "ranking" : ranking,
    "rating_quantity" : rating_quantity,
    "rating_percentage" : rating_percentage,
    "history" : history,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}