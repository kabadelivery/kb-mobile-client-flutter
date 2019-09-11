import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/DialogPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuPage.dart';
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
                        height:45, width: 45,
                        decoration: BoxDecoration(
                            border: new Border.all(color: KColors.primaryYellowColor, width: 2),
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
                        Text(restaurantModel.address, maxLines:3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: Colors.black.withAlpha(150))),
                      ],
                    )
                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right:15),
                    color: Colors.grey.withAlpha(120),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height:1
                      /* height is max*/
                    )),
                SizedBox(width: 5),
                Container(
                    padding: EdgeInsets.all(5),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(children:[
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: restaurantModel.is_open == 1 ? CommandStateColor.delivered : Colors.blueAccent.shade700),
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
                        restaurantModel?.distance == null ? Container() : Text("${restaurantModel?.distance}km", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal, fontSize: 12))
                      ],
                    ))
              ])
          )),
          onTap: (){restaurantModel.coming_soon==0?_jumpToRestaurantDetails(context, restaurantModel):_comingSoon(context, restaurantModel);}));
  }

  void _jumpToRestaurantDetails(BuildContext context, RestaurantModel restaurantModel) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel),
      ),
    );
  }

  void _jumpToRestaurantMenu (BuildContext context, RestaurantModel restaurantModel) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel),
      ),
    );
  }

  void _comingSoon(BuildContext context, RestaurantModel restaurantModel) {
    /* show the coming soon dialog */
    showDialog(context: context, builder: (BuildContext context)=>DialogPage(
        message:"Hello, This restaurant will be soon available on the platform.\n Please remain patient.",
        pic: Utils.inflateLink(restaurantModel.pic),
        nbAction: 1,
        button1Name: "OK",
        onClickAction1: (){print(restaurantModel.name);}
    ));
  }

}