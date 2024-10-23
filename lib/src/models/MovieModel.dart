import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopModel.dart';

class MovieModel {
  int id;

  String name;
  String description;
  String movie_type;

  String pic;
  String adult_ticket_price;
  String kid_ticket_price;

  int shop_id; // we
  String age_limit;
  int is_premiere;

  int is_favorite = 0;
  double stars;
  int promotion;
  bool is_addon = false;

  /* restaurant entity */
  ShopModel shop_entity;

  MovieModel(
      {this.id,
      this.name,
      this.movie_type,
      this.is_premiere,
      this.pic,
      this.shop_id,
      this.age_limit,
      this.description /*, this.food_details_pictures */,
      this.is_favorite,
      this.stars,
      this.promotion,
      this.shop_entity});

  MovieModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pic = json['pic'];
    shop_id = json['shop_id'];
    description = json['description'];
    l = json["food_details_pictures"];
    is_favorite = json['is_favorite'];
    stars = json['stars'];
    promotion = json['promotion'];
    try {
      shop_entity = ShopModel.fromJson(json['restaurant_entity']);
    } catch (_) {
      debugPrint(_.toString());
    }

    // to add
    age_limit = json['age_limit'];
    is_premiere = json['is_premiere'];
    movie_type = json['movie_type'];
  }

  Map toJson() => {
        "id": (id as int),
        "name": name,
        "pic": pic,
        "movie_type": movie_type,
        "age_limit": age_limit,
        "is_premiere": is_premiere,
        "description": description,
        "is_favorite": is_favorite,
        "stars": stars,
        "promotion": promotion,
        "shop_entity": shop_entity,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  static MovieModel random() {
    final MovieModel md = MovieModel(
        id: 0,
        name: "Last of us",
        pic: "",
        description: "THe last of us, meilleur film 2021",
        age_limit: "Age limit");
    return md;
  }
}
