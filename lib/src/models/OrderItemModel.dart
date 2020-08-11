

import 'package:KABA/src/models/HomeScreenModel.dart';

class OrderItemModel {

   int id;
   String name;
   String price;
   int promotion;
   String promotion_price;
   String pic;
   String details;
   int quantity;
   int menu_id;
   int restaurant_id;
   String food_description;
   List<String> food_details_pictures;
   double stars;

   OrderItemModel({this.id, this.name, this.price, this.promotion,
      this.promotion_price, this.pic, this.details, this.quantity,
      this.menu_id, this.restaurant_id, this.food_description,
      this.food_details_pictures, this.stars});


   OrderItemModel.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      name = json['name'];
      price = json['price'];
      promotion_price = json['promotion_price'];
      quantity = json['quantity'];
      pic = json['pic'];
      details = json['details'];
      promotion = json['promotion'];

      try {
         menu_id = int.parse(json['menu_id']);
         restaurant_id = json['restaurant_id'];
         l = json["food_details_pictures"];
         food_details_pictures = l?.map((f) => "${f}")?.toList();
         food_description = json['food_description'];
         stars = json['stars'];
      } catch(e){
         print(e);
      }
   }

   Map toJson () => {
      "id" : (id as int),
      "name" : name,
      "pic" : pic,
      "details" : details,
      "promotion_price" : promotion_price,
      "price" : price,
      "quantity" : quantity,
      "menu_id" : menu_id,
      "restaurant_id" : restaurant_id,
      "food_details_pictures" : food_details_pictures,
      "stars" : stars,
      "promotion" : promotion,
      "food_description" : food_description,
   };

   @override
   String toString() {
      return toJson().toString();
   }

}