import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
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

class FoodWithRestaurantDetailsWidget extends StatefulWidget {
  ShopProductModel food;

  GlobalKey key;

  FoodWithRestaurantDetailsWidget({this.food, this.key});

  @override
  _FoodWithRestaurantDetailsWidgetState createState() {
    return _FoodWithRestaurantDetailsWidgetState();
  }
}

class _FoodWithRestaurantDetailsWidgetState
    extends State<FoodWithRestaurantDetailsWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (InkWell(
        child: Card(
            key: widget.key,
//          elevation: 8.0,
//          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            margin: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
            child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey..withAlpha(50),
                        offset: new Offset(0.0, 2.0),
                      )
                    ]),
                child: Column(children: <Widget>[
                  ListTile(
                      contentPadding:
                          EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      leading: Stack(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        Utils.inflateLink(widget?.food?.pic)))),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        Utils.inflateLink(widget?.food.pic)))),
                          )
                        ],
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${widget?.food?.name.toUpperCase()}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 5),
                          Row(
                            children: <Widget>[
                              Row(children: <Widget>[
                                Text("${widget?.food?.price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryYellowColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal)),
                                (widget?.food.promotion != 0
                                    ? Text("${widget?.food?.promotion_price}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: KColors.primaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            decoration:
                                                TextDecoration.lineThrough))
                                    : Container()),
                                Text(
                                    "${AppLocalizations.of(context).translate("currency")}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryYellowColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal)),
                              ]),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(height: 5),
                  Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey..withAlpha(50),
                              offset: new Offset(0.0, 2.0),
                            )
                          ]),
                      child: Column(children: <Widget>[
                        ListTile(
                            contentPadding:
                                EdgeInsets.only(top: 10, bottom: 10, left: 10),
                            leading: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                    border: new Border.all(
                                        color: KColors.primaryYellowColor,
                                        width: 2),
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            Utils.inflateLink(widget?.food
                                                ?.restaurant_entity?.pic))))),
                            trailing:
                                widget?.food?.restaurant_entity?.coming_soon ==
                                        0
                                    ? IconButton(
                                        icon: Icon(Icons.home,
                                            size: 30,
                                            color: KColors.primaryColor),
                                        onPressed: () {
                                          _jumpToRestaurantDetails(context,
                                              widget?.food?.restaurant_entity);
                                        })
                                    : null,
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("${widget?.food?.restaurant_entity?.name}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: KColors.primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(height: 10),
                                Text(
                                    "${widget?.food?.restaurant_entity?.address}",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withAlpha(150))),
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            color: Colors.grey.withAlpha(120),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 1
                                /* height is max*/
                                )),
                        SizedBox(width: 5),
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(children: [
                                  _getRestaurantStateTag(
                                      widget?.food?.restaurant_entity),
                                  SizedBox(width: 5),
                                  widget?.food?.restaurant_entity
                                              ?.coming_soon ==
                                          1
                                      ? Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color: KColors.primaryColor),
                                          child: Text(
                                              "${AppLocalizations.of(context).translate('coming_soon')}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)))
                                      : Container(),
                                ]),
                                Row(children: <Widget>[
                                  widget?.food?.restaurant_entity?.distance ==
                                          null
                                      ? Container()
                                      : Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color:
                                                  KColors.primaryYellowColor),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.directions_bike,
                                                  color: Colors.black,
                                                  size: 14),
                                              SizedBox(width: 5),
                                              Text(
                                                  "${widget?.food?.restaurant_entity?.delivery_pricing == "0" ? "${AppLocalizations.of(context).translate('out_of_range')}" : widget?.food?.restaurant_entity?.delivery_pricing + " F"}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ],
                                          )),
                                  SizedBox(width: 10),
                                  widget?.food?.restaurant_entity?.distance ==
                                          null
                                      ? Container()
                                      : Text(
                                          "${widget?.food?.restaurant_entity?.distance}${AppLocalizations.of(context).translate('km')}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12))
                                ])
                              ],
                            ))
                      ]))
                ]))),
        onTap: () => _jumpToFoodDetails(context, widget?.food)));
  }

  /* get position of icon */
  int getImagePosition() {
    return 0;
  }

  _jumpToFoodDetails(BuildContext context, ShopProductModel food) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage (presenter: MenuPresenter(), menuId: int.parse(food.menu_id), highlightedFoodId: food?.id),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                presenter: MenuPresenter(),
                menuId: int.parse(food.menu_id),
                highlightedFoodId: food?.id),
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
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food),
      ),
    );*/
  }

  void _jumpToRestaurantDetails(
      BuildContext context, ShopModel restaurantModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(
            restaurant: restaurantModel,
            presenter: RestaurantDetailsPresenter()),
      ),
    );
  }

  _getRestaurantStateTag(ShopModel restaurantModel) {
    String tagText = "-- --";
    Color tagTextColor = Colors.white;
    Color tagColor = KColors.primaryColor;

    switch (restaurantModel.open_type) {
      case 0: // closed
        tagText =
            "${AppLocalizations.of(context).translate('r_closed_preorder')}";
        tagColor = KColors.mBlue;
        break;
      case 1: // open
        tagText = "${AppLocalizations.of(context).translate('r_opened')}";
        tagColor = CommandStateColor.delivered;
        break;
      case 2: // paused
        tagText =
            "${AppLocalizations.of(context).translate('r_pause_preorder')}";
        tagColor = KColors.mBlue;
        break;
      case 3: // blocked
        tagText =
            "${AppLocalizations.of(context).translate('r_blocked_preorder')}";
        tagColor = KColors.primaryColor;
        break;
    }

    return restaurantModel.coming_soon == 0
        ? Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: tagColor),
            child: Text(tagText,
                style: TextStyle(color: tagTextColor, fontSize: 12)))
        : Container();
  }
}
