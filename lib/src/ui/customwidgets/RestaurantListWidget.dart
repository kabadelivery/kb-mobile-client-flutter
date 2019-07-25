import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class RestaurantListWidget extends StatelessWidget {


  RestaurantModel restaurantModel;

  RestaurantListWidget({
    Key key,
    this.restaurantModel,
  }): super(key:key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (InkWell(child:Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                                image: CachedNetworkImageProvider(Utils.inflateLink(restaurantModel.pic))
                            )
                        )
                    ),
                    trailing: restaurantModel.coming_soon == 0 ? IconButton(icon: Icon(Icons.menu, color: KColors.primaryColor,), onPressed: (){_jumpToRestaurantMenu(context, restaurantModel);}) : null,
                    title:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(restaurantModel.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: TextStyle(color:KColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w500)),
                        SizedBox(height:10),
                        Text(restaurantModel.description, maxLines:3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: Colors.black.withAlpha(150))),
                      ],
                    )
                ),
                Container(
                    padding: EdgeInsets.all(5),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(children:[
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: restaurantModel.is_open == 1 ? Colors.greenAccent.shade700 : Colors.blueAccent.shade700),
                              child:Text(
                                  restaurantModel.is_open == 1 ? "Open":"Closed",
                                  style: TextStyle(color: Colors.white, fontSize: 12)
                              )),
                          SizedBox(width: 5),
                          restaurantModel.coming_soon == 1 ?
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: KColors.primaryColor),
                              child:Text(
                                  "Coming Soon",
                                  style: TextStyle(color: Colors.white, fontSize: 12)
                              )) : SizedBox(width: 0),
                        ]),
                        Text("2.15km", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 12))
                      ],
                    ))
              ])
          )),
          onTap: (){restaurantModel.coming_soon==0?_jumpToRestaurantDetails(context, restaurantModel):_comingSoon();}));
  }

  void _jumpToRestaurantDetails(BuildContext context, RestaurantModel restaurantModel) {
    Navigator.pushNamed(context, RestaurantDetailsPage.routeName);
  }

  _comingSoon() {
    /* show the coming soon dialog */
  }

  void _jumpToRestaurantMenu(BuildContext context,  RestaurantModel restaurantModel) {}

}