import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';

class RestaurantFoodModel {

    int id;
    String name;
    String price;
    String pic;
    String details;
    String promotion_price;
    int menu_id;
    int restaurant_id;
    String description;
    List<String> food_details_pictures;
    int is_favorite = 0;
    double stars;
    int promotion;
    /* restaurant entity */
    RestaurantModel restaurant_entity;

    RestaurantFoodModel({this.id, this.name, this.price, this.pic, this.details,
        this.promotion_price, this.menu_id, this.restaurant_id,
        this.description, this.food_details_pictures, this.is_favorite,
        this.stars, this.promotion, this.restaurant_entity});


    RestaurantFoodModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        name = json['name'];
        pic = json['pic'];
        details = json['details'];
        promotion_price = json['promotion_price'];
        menu_id = json['menu_id'];
        restaurant_id = json['restaurant_id'];
        description = json['description'];
        food_details_pictures = json['food_details_pictures'];
        is_favorite = json['is_favorite'];
        stars = json['stars'];
        promotion = json['promotion'];
        restaurant_entity = json['restaurant_entity'];
    }


    Map toJson () => {
        "id" : (id as int),
        "name" : name,
        "pic" : pic,
        "details" : details,
        "promotion_price" : promotion_price,
        "menu_id" : menu_id,
        "restaurant_id" : restaurant_id,
        "description" : description,
        "food_details_pictures" : food_details_pictures,
        "is_favorite" : is_favorite,
        "stars" : stars,
        "promotion" : promotion,
        "restaurant_entity" : restaurant_entity,
    };

    @override
    String toString() {
        return toJson().toString();
    }

}
