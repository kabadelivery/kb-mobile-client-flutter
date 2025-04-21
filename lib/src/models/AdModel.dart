import 'package:flutter/foundation.dart';
import 'dart:core';

class AdModel {

  static const int TYPE_REPAS = 1;
  static const int TYPE_MENU = 2;
  static const int TYPE_ARTICLE = 3;
  static const int TYPE_RESTAURANT = 5;
  static const int TYPE_ARTICLE_WEB = 6;
  static const int BEST_SELLER = 90;
  static const int EVENEMENT = 91;

  int? id;
  String? name;
  String? link;
  String? description;
  String? pic;
  String? food_json;
  int? type;
  int? entity_id;

  AdModel({this.id, this.name, this.link, this.description, this.pic,
    this.food_json, this.type, this.entity_id});

  AdModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    name = json['name'];
    link = json['link'];
    description = json['description'];
    pic = json['pic'];
    food_json = json['food_json'];
    type = json['type'];
    entity_id = json['entity_id'];
  }

  Map toJson () => {
    "id" : (id as int),
    "name" : name,
    "link" : link,
    "description" : description,
    "pic" : pic,
    "food_json" : food_json,
    "type" : (id as int),
    "entity_id" : entity_id,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}