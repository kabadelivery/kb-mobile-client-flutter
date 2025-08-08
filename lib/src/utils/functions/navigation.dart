import 'package:flutter/cupertino.dart';

import '../../models/ShopModel.dart';
import '../../models/ShopProductModel.dart';
import '../../ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';

jumpToFoodDetails(BuildContext context, ShopProductModel food,ShopModel restaurant) {
  food.restaurant_entity = restaurant;
  /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: food),
      ),
    );*/

  Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShopFlowerDetailsPage(food: food),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation =
        CurvedAnimation(parent: animation, curve: curve);
        return SlideTransition(
            position: tween.animate(curvedAnimation), child: child);
      }));
}