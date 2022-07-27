import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';


class ShopModel {

  String name;
  int id;
  String pic;
  String theme_pic;
  String description;
  int contactId;
  String address;
  String email;
  String main_contact;
  String working_hour;
  String distance="";
  String menu_foods;
  int is_open;
  int coming_soon;
  double stars;
  int votes;
  int is_promotion;
  int is_new;
  String max_food;
  String delivery_pricing = "";
  int open_type;
  String discount;
  String location;
  String category_id;

  // other
  double distanceBetweenMeandRestaurant = 0;

  ShopModel({this.id, this.name, this.pic, this.contactId, this.email,
    this.distance, this.is_open, this.stars, this.votes, this.theme_pic,
    this.description, this.address, this.main_contact,
    this.working_hour, this.coming_soon,category_id,
    this.is_promotion,
    this.is_new, this.open_type, this.delivery_pricing, this.discount, this.max_food,
  this.location});

  ShopModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pic = json['pic'];
    contactId = json['contactId'];
    email = json['email'];
    distance = json['distance'];
    menu_foods = json['menu_foods'];
    is_open = json['is_open'];
    if (json['stars'] != null)
      stars = double.parse("${json['stars']}");
    votes = json['votes'];
    theme_pic = json['theme_pic'];
    description = json['description'];
    address = json['address'];
    main_contact = json['main_contact'];
    working_hour = json['working_hour'];
    coming_soon = json['coming_soon'];
    is_promotion = json['is_promotion'];
    is_new = json['is_new'];
    discount = json['discount'];
    open_type = json['open_type'];
    delivery_pricing = "${json['delivery_pricing']}";
    max_food = json['max_food'];
    location = json["location"];
    category_id = json["category_id"];
  }


  Map toJson () => {
    "id" : (id as int),
    "name" : name,
    "pic" : pic,
    "contactId" : contactId,
    "email" : email,
    "distance" : distance,
    "menu_foods" : menu_foods,
    "is_open" : is_open,
    "stars" : stars,
    "theme_pic" : theme_pic,
    "description" : description,
    "main_contact" : main_contact,
    "working_hour" : working_hour,
    "coming_soon" : coming_soon,
    "is_promotion" : is_promotion,
    "is_new" : is_new,
    "location": location,
    "category_id": category_id
  };

  @override
  String toString() {
    return toJson().toString();
  }
}
