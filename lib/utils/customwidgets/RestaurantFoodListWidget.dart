import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';

class RestaurantFoodListWidget extends StatefulWidget {

  String text;

  RestaurantFoodListWidget({this.text});

  @override
  _RestaurantFoodListWidgetState createState() {
    // TODO: implement createState
    return _RestaurantFoodListWidgetState();
  }

}

class _RestaurantFoodListWidgetState extends State<RestaurantFoodListWidget> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (InkWell(child:Card(
          elevation: 8.0,
//          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          margin: EdgeInsets.only(left: 10, right: 70, top: 6, bottom: 6),
          child: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),   boxShadow: [
                new BoxShadow(
                  color: Colors.grey..withAlpha(50),
                  offset: new Offset(0.0, 2.0),
                )
              ]),
              child:
              Column(children: <Widget>[
                ListTile(
                    contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                    leading: Container(
                        height:50, width: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider("https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png")
                            )
                        )
                    ),
                    trailing: IconButton(icon: Icon(Icons.add_shopping_cart, color: KColors.primaryColor), onPressed: (){_addFoodToChart();}),
                    title:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("SPAGHETTI DOSÉ ROUGE", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(height: 5),
                        Row(children: <Widget>[
                          Text("300", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                          Text("FCFA", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                        ]),
                      ],
                    )
                )
              ])
          ))
        , onTap: _jumpToRestaurantDetails,));
  }

  void _jumpToRestaurantDetails() {
    Navigator.pushNamed(context, RestaurantDetailsPage.routeName);
  }

  void _addFoodToChart() {
    /* besoin de la position de la vue et ensuite de la position de destination */

  }

}