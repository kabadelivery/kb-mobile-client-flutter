import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';

class ShopProductModel {
  int? id;
  String? name;
  String? price;
  String? pic;
  String? promotion_price;
  String? menu_id;
  int? restaurant_id; // we
  String? description;
  List<String>? food_details_pictures;
  int? is_favorite = 0;
  double? stars;
  int? promotion;
  bool? is_addon = false;
  double? rating=3;
  List<Map>? food_review_array = [];
  int?review_count;
  /* restaurant entity */
  ShopModel? restaurant_entity;


  ShopProductModel(
      {this.id,
      this.name,
      this.price,
      this.pic,
      this.promotion_price,
      this.menu_id,
      this.restaurant_id,
      this.description,
      this.food_details_pictures,
      this.is_favorite,
      this.stars,
      this.promotion,
      this.restaurant_entity,
      this.rating,
      this.food_review_array,
        this.review_count
      });

  ShopProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pic = json['pic'];

    // supposed to be an hint, issue to solve
    promotion_price =
        "${json['promotion_price'] == null ? "" : json['promotion_price']}";

    price = json['price'];
    menu_id = json['menu_id'];
    restaurant_id = json['restaurant_id'];
    description = json['description'];
    review_count = json['review_count'];
    l = json["food_details_pictures"];
    food_details_pictures = l?.map((pic_link) => "${pic_link}")?.toList();
    // food_details_pictures = []..add(pic);
    is_favorite = json['is_favorite'];
    stars = json['stars'];
    promotion = json['promotion'];
    rating = (json['rating'] != null) ? double.parse("${json['rating']}") : 3;
    try {
      restaurant_entity = ShopModel.fromJson(json['restaurant_entity']);
    } catch (_) {
      debugPrint(_.toString());
    }
    try {
      food_review_array = (json['food_review_array'] as List?)
          ?.map((e) => e as Map)
          .toList();
    } catch (_) {
      debugPrint(_.toString());
    }
  }

  Map toJson() => {
        "id": (id as int),
        "name": name,
        "pic": pic,
        "promotion_price": promotion_price,
        "price": price,
        "menu_id": menu_id,
        "restaurant_id": restaurant_id,
        "description": description,
        "food_details_pictures": food_details_pictures,
        "is_favorite": is_favorite,
        "stars": stars,
        "promotion": promotion,
        "restaurant_entity": restaurant_entity,
        "rating": rating,
        "food_review_array": food_review_array,
        "review_count":review_count
      };

  @override
  String toString() {
    return toJson().toString();
  }

  static ShopProductModel randomFood() {
    ShopProductModel food = ShopProductModel();

    food.id = 999;
    food.name = "ATTIEKE + POULET + ALLOCO";
    food.price = "1500";
    food.menu_id = "89";
    food.restaurant_id = 17;
    food.description = "Something worth it";
    food.is_favorite = 0;
    food.stars = 3;
    return food;
  }
}
