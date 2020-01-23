import 'package:flutter/foundation.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';


class MyAddressModel {


  int id = 0;
  String name;
  String location = "";
  String phone_number;
  String user_id;
  String description;
  List<String> picture;
  String quartier;
  String near;
  String updated_at; /* last update date - time stamp */


  MyAddressModel({
    this.name, this.location, this.phone_number, this.user_id,
    this.description, this.quartier, this.near, this.updated_at,
    this.picture
  });

  MyAddressModel.fromJson(Map<String, dynamic> json) {

    id = int.parse(json['id']);
    name = json['name'];
    location = json['location'];
    phone_number = json['phone_number'];
    user_id = json['user_id'];
    description = json['description'];
    quartier = json['quartier'];
    near = json['near'];
    updated_at = json['updated_at'];

    var l = json["picture"];
    picture = l?.map((String pic) => (pic))?.toList();
  }

  Map toJson () => {
    "id" : id,
    "name" : name,
    "location" : location,
    "phone_number" : phone_number,
    "user_id" : user_id,
    "description" : description,
    "quartier" : quartier,
    "near" : near,
    "updated_at" : updated_at,
    "picture" : picture,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  static MyAddressModel fake() {

    MyAddressModel m = MyAddressModel();
    m.name = "Chez Ida";
    m.location = "6,1434:1.20013";
    m.phone_number = "90628725";
    m.description = "Immeuble de 4 etages situeé au fond du deuxieme virage juste apreès la montee de paveés d'agbalepedogan"
        " en allant de vers GTA";
    m.near = "Gare routière d'Agbalepedogan";
    m.user_id="9";
    m.quartier = "Agbalepedogan";
    m.updated_at = "";
    return m;
  }

} 
