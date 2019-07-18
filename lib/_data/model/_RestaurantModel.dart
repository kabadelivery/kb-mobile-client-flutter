import 'package:flutter/foundation.dart';

class _RestaurantModel {
  
  final String name;
  final int id;
  final String pic;
  final String theme_pic;
  final String description;
  final int contactId;
  final String address;
  final String email;
  final String main_contact;
  final String working_hour;
  final String distance;
  final int is_open;
  final int coming_soon;
  final double stars;
  final int votes;


  _RestaurantModel({this.id, this.name, this.pic, this.contactId, this.email,
    this.distance, this.is_open, this.stars, this.votes, this.theme_pic,
    this.description, this.address, this.main_contact,
    this.working_hour, this.coming_soon});

  _RestaurantModel copyWith ({int id, String name, String pic, int contactId, String email, String distance, int is_open, double stars, int votes}) {
    return _RestaurantModel (
        id: id ?? this.id,
      name: name ?? this.name,
      pic: pic ?? this.pic,
      contactId: contactId ?? this.contactId,
      email: email ?? this.email,
      distance: distance ?? this.distance,
      is_open: is_open ?? this.is_open,
      stars: stars ?? this.stars,
      votes: votes ?? this.votes,
      theme_pic: this.theme_pic,
      description: this.description,
      address: this.address,
      main_contact: this.main_contact,
      working_hour: this.working_hour,
      coming_soon: this.coming_soon,
    );
  }

  Map toJson () => {
    "id" : (id as int),
    "name" : name,
    "pic" : pic,
    "contactId" : contactId,
    "email" : email,
    "distance" : distance,
    "is_open" : is_open,
    "stars" : stars,
    "theme_pic" : theme_pic,
    "description" : description,
    "main_contact" : main_contact,
    "working_hour" : working_hour,
    "coming_soon" : coming_soon,
  };

  @override
  String toString() {
    return toJson().toString();
  }


}