import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';


 class DeliveryAddressModel {

  int id = 0;
  String name;
  String location = "";
  String phone_number;
  String user_id;
  String description;
  List<String> picture;
  String quartier;
  String near;
  String updated_at;

  DeliveryAddressModel({this.id, this.name, this.location, this.phone_number,
      this.user_id, this.description, this.picture, this.quartier, this.near,
      this.updated_at});

  DeliveryAddressModel.fromJson(Map<String, dynamic> json) {

   id = json['id'];
   name = json['name'];
   location = json['location'];
   phone_number = json['phone_number'];
   user_id = json['user_id'];
   description = json['description'];

   l = json["picture"];
   picture = l?.map((f) => "${f}")?.toList();

   quartier = json['quartier'];
   near = json['near'];
   updated_at = json['updated_at'];
  }

  Map toJson () => {
   "id" : (id as int),
   "name" : name,
   "location" : location,
   "phone_number" : phone_number,
   "user_id" : user_id,
   "description" : description,
   "picture" : picture,
   "quartier" : quartier,
   "near" : near,
   "updated_at" : updated_at,
  };

  @override
  String toString() {
   return toJson().toString();
  }

}