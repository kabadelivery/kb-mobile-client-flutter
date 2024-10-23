import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class RestaurantFoodListWidget extends StatefulWidget {

  String text;

  // ignore: non_constant_identifier_names
  Offset basket_offset;

  ShopProductModel food;

  RestaurantFoodListWidget({this.text, this.basket_offset, this.food});

  @override
  _RestaurantFoodListWidgetState createState() {
    // TODO: implement createState
    return _RestaurantFoodListWidgetState(basket_offset: basket_offset, food: food);
  }

}

class _RestaurantFoodListWidgetState extends State<RestaurantFoodListWidget> with SingleTickerProviderStateMixin {

  AnimationController controller;

  Animation<Offset> animation;

  Offset basket_offset;

  ShopProductModel food;

  _RestaurantFoodListWidgetState({this.basket_offset, this.food});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<Offset>(begin: Offset(0, 0), end: Offset(400, -400)).animate(controller);
//    animation.drive(child)
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (InkWell(child:Card(
//          elevation: 8.0,
//          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          margin: EdgeInsets.only(left: 10, right: 70, top: 6, bottom: 6),
          child: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),   boxShadow: [
                BoxShadow(
                  color: Colors.grey..withAlpha(50),
                  offset: new Offset(0.0, 2.0),
                )
              ]),
              child:
              Column(children: <Widget>[
                ListTile(
                    contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                    leading: Stack(
                      children: <Widget>[
                        Container(
                          height:50, width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
                              )
                          ),
                        ),
                        AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Transform.translate(
                              offset: animation.value,
                              child: child,
                            ),
                            child: Container(
                              height:50, width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
                                  )
                              ),
                            )) // invisible view
                      ],
                    ),
                    trailing: IconButton(icon: Icon(Icons.add_shopping_cart, color: KColors.primaryColor), onPressed: (){_addFoodToChart();}),
                    title:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${food?.name.toUpperCase()}", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:KColors.new_black, fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Row(children: <Widget>[
                              Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),

                              (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                                  : Container()),

                              Text("FCFA", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                            ]),
                          ],
                        ),
                      ],
                    )
                )
              ])
          ))
        , onTap: ()=>_jumpToFoodDetails(context, food)));
  }



  void _addFoodToChart() {
    /* besoin de la position de la vue et ensuite de la position de destination */
//    print("basket_offset ${basket_offset}");
    controller.forward();
  }

  /* get position of icon */
  int getImagePosition () {
    return 0;
  }

  _jumpToFoodDetails(BuildContext context, ShopProductModel food) {
   /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food),
      ),
    );
*/
    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            RestaurantFoodDetailsPage (food: food),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }

}