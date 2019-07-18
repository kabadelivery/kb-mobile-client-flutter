import 'package:flutter/foundation.dart';
import 'dart:core';

class _AdModel {

  final int TYPE_REPAS = 1;
  final int TYPE_MENU = 2;
  final int TYPE_ARTICLE = 3;
  final int TYPE_RESTAURANT = 5;
  final int BEST_SELLER = 90;
  final int EVENEMENT = 91;

  int id;
  String name;
  String link;
  String description;
  String pic;
  String food_json;
  int type;
  int entity_id;

  _AdModel({this.id, this.name, this.link, this.description, this.pic,
    this.food_json, this.type, this.entity_id});

  _AdModel copyWith ({int id, String name, String link, String description, String pic,
    String food_json, int type, int entity_id}) {

    return _AdModel (
      id: id ?? this.id,
      name: name ?? this.name,
      link: link ?? this.link,
      description: description ?? this.description,
      pic: pic ?? this.pic,
      food_json: food_json ?? this.food_json,
      type: type ?? this.type,
      entity_id: entity_id ?? this.entity_id,
    );
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