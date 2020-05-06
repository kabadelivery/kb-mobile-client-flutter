import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';

class RestaurantFoodModel {

    int id;
    String name;
    String price;
    String pic;
    String promotion_price;
    String menu_id;
    int restaurant_id; // we
    String description;
    List<String> food_details_pictures;
    int is_favorite = 0;
    double stars;
    int promotion;
    bool is_addon = false;
    /* restaurant entity */
    RestaurantModel restaurant_entity;

    RestaurantFoodModel({this.id, this.name, this.price, this.pic,
        this.promotion_price, this.menu_id, this.restaurant_id,
        this.description, this.food_details_pictures, this.is_favorite,
        this.stars, this.promotion, this.restaurant_entity});

//    "id": 1810,
//      "name": "Couscous - séparé",
//      "description": "Couscous + lait (emballé dans de sachets différents) ",
//      "priority": 1,
//      "promotion": 0,
//      "promotion_price": null,
//      "pic": "food_pic/SZa8MVNIdcFhKvr.jpg",
//      "food_details_pictures": [
//      "food_pic/D7vHrFywMgasiDy.jpg"
//      ],
//      "price": "300",
//      "menu_id": "261",
//      "is_deleted": 0,
//      "lastupdate": "07-11-2019 15:44:55pm",
//      "rating_quantity": 0,
//      "rating_percentage": 0
//   },

    RestaurantFoodModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        name = json['name'];
        pic = json['pic'];
        promotion_price = json['promotion_price'];
        price = json['price'];
        menu_id = json['menu_id'];
        restaurant_id = json['restaurant_id'];
        description = json['description'];

        l = json["food_details_pictures"];
        food_details_pictures = l?.map((pic_link) => "${pic_link}")?.toList();

        is_favorite = json['is_favorite'];
        stars = json['stars'];
        promotion = json['promotion'];

        try {
            restaurant_entity =
                RestaurantModel.fromJson(json['restaurant_entity']);
        } catch(_){
            debugPrint(_.toString());
        }
    }


    Map toJson () => {
        "id" : (id as int),
        "name" : name,
        "pic" : pic,
        "promotion_price" : promotion_price,
        "price" : price,
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
