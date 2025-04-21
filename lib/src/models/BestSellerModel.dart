import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';


class BestSellerModel {

  /* best seller is a product */
//  int ranking;
//  int rating_quantity;
//  int rating_percentage;
  List<int>? history; /* yest, the day before, the day before before */
//  ShopModel restaurant_entity;
  ShopProductModel? food_entity;

  BestSellerModel({/*this.restaurant_entity,*/ this.food_entity, /*this.ranking, this.rating_quantity, this.rating_percentage,*/ this.history});

  BestSellerModel.fromJson(Map<String, dynamic> json) {

    food_entity = ShopProductModel.fromJson(json['food_entity']);
    Iterable lo = json['history'];
    history = lo?.map((bs) => (bs as int))?.toList();
  }

  Map toJson () => {
    "food_entity" : food_entity,
//    "restaurant_entity" : restaurant_entity,
//    "ranking" : ranking,
//    "rating_quantity" : rating_quantity,
//    "rating_percentage" : rating_percentage,
    "history" : history,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}