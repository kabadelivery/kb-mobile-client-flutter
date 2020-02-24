import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';


class RestaurantModel {

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
  String distance;
  String menu_foods;
  int is_open;
  int coming_soon;
  double stars;
  int votes;
  int is_promo;
  int is_new;


//  RestaurantModel({});

  RestaurantModel({this.id, this.name, this.pic, this.contactId, this.email,
    this.distance, this.is_open, this.stars, this.votes, this.theme_pic,
    this.description, this.address, this.main_contact,
    this.working_hour, this.coming_soon, this.is_promo, this.is_new});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
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
    is_promo = json['is_promo'];
    is_new = json['is_new'];
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
    "is_promo" : is_promo,
    "is_new" : is_new,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}
