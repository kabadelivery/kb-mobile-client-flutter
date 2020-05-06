import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/AdModel.dart';



class EvenementModel extends AdModel {

 String category;
 int created_at;

 EvenementModel(int id, String name, String link, String description, String pic, String food_json, int type, int entity_id,this.category, this.created_at) :
       super(id:id, name:name, link:link, description:description, pic:pic, food_json:food_json, type:type, entity_id:entity_id);

 EvenementModel.fromJson(Map<String, dynamic> json) {

   id = json['id'];
   name = json['name'];
   link = json['link'];
   description = json['description'];
   pic = json['pic'];
   food_json = json['food_json'];
   type = json['type'];
   entity_id = json['entity_id'];
   category = json['category'];
   created_at = json['created_at'] as int;
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
   "category" : category,
   "created_at" : created_at as int,
 };


 @override
 String toString() {
   return toJson().toString();
 }



}