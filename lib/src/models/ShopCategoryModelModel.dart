import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';


class RestaurantSubMenuModel {

   int id;
   String name;
   int restaurant_id;
   String description;
   int promotion = 0;
   List<ShopProductModel> foods;

   RestaurantSubMenuModel({this.id, this.name, this.restaurant_id, this.description, this.promotion,
      this.foods});

   RestaurantSubMenuModel.fromJson(Map<String, dynamic> json) {


      id = json['id'];
      name = json['name'];
      restaurant_id = json['restaurant_id'];
      description = json['description'];
      promotion = json['promotion'];

      l = json["foods"];


      foods = l?.map((food) => ShopProductModel.fromJson(food))?.toList();
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