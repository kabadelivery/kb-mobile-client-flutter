import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';


class Restaurant_SubMenuEntity {

   int id;
   String name;
   int restaurant_id;
   String description;
   int promotion = 0;
   List<RestaurantFoodModel> foods;

   Restaurant_SubMenuEntity({this.id, this.name, this.restaurant_id, this.description, this.promotion,
      this.foods});

   Restaurant_SubMenuEntity.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      name = json['name'];
      restaurant_id = json['restaurant_id'];
      description = json['description'];
      promotion = json['promotion'];
      foods = json['foods'];
   }

   Map toJson () => {
      "id" : (id as int),
      "name" : name,
      "restaurant_id" : restaurant_id,
      "description" : description,
      "promotion" : promotion,
      "foods" : foods,
   };

   @override
   String toString() {
      return toJson().toString();
   }

}