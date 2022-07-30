import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductWithShopDetailsWidget extends StatefulWidget {
  ShopProductModel food;

  GlobalKey key;

  ProductWithShopDetailsWidget({this.food, this.key});

  @override
  _ProductWithShopDetailsWidgetState createState() {
    return _ProductWithShopDetailsWidgetState();
  }
}

class _ProductWithShopDetailsWidgetState
    extends State<ProductWithShopDetailsWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (InkWell(
        child: Container(
            key: widget.key,
            margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(247, 247, 247, 1),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            height: 125,
                            width: 90,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                border: new Border.all(
                                    color: KColors.primaryYellowColor
                                        .withOpacity(0.7),
                                    width: 3),
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        Utils.inflateLink(widget?.food?.pic)))),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: new EdgeInsets.only(
                                                right: 13.0, top: 10),
                                            child: Text(
                                                Utils.capitalize(
                                                    "${widget?.food?.name}"),
                                                maxLines: 3,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                          SizedBox(height: 5),
                                          Row(children: <Widget>[
                                            Text("${widget?.food?.price}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: KColors.primaryColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            SizedBox(width: 3),
                                            (widget?.food.promotion != 0
                                                ? Text(
                                                    "${widget?.food?.promotion_price}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: KColors
                                                            .primaryYellowColor,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough))
                                                : Container()),
                                            Text(
                                                "${AppLocalizations.of(context).translate("currency")}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: KColors.primaryColor,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ]),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              Utils.capitalize(
                                                  "${widget?.food?.restaurant_entity?.name}"),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              // textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                          SizedBox(height: 5),
                                          Row(children: <Widget>[
                                            _getRestaurantStateTag(widget
                                                ?.food?.restaurant_entity),
                                            SizedBox(width: 10),
                                            widget?.food?.restaurant_entity
                                                        ?.distance ==
                                                    null
                                                ? Container()
                                                : Container(
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        color: Colors.white),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            FontAwesomeIcons
                                                                .locationArrow,
                                                            color:
                                                                KColors.mGreen,
                                                            size: 10),
                                                        SizedBox(width: 10),
                                                        Text(
                                                            " ${widget?.food?.restaurant_entity?.distance}${AppLocalizations.of(context).translate('km')}",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                            SizedBox(width: 10),
                                            widget?.food?.restaurant_entity
                                                        ?.distance ==
                                                    null
                                                ? Container()
                                                : widget
                                                            ?.food
                                                            ?.restaurant_entity
                                                            ?.delivery_pricing ==
                                                        "0"
                                                    ? Container()
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                            color:
                                                                Colors.white),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                                FontAwesomeIcons
                                                                    .personBiking,
                                                                color: KColors
                                                                    .primaryColor,
                                                                size: 12),
                                                            SizedBox(width: 5),
                                                            Text(
                                                                (widget?.food?.restaurant_entity
                                                                            ?.delivery_pricing ==
                                                                        "~"
                                                                    ? "${AppLocalizations.of(context).translate('out_of_range')}"
                                                                    : widget
                                                                            ?.food
                                                                            ?.restaurant_entity
                                                                            ?.delivery_pricing +
                                                                        " F"),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        12)),
                                                          ],
                                                        )),
                                          ]),
                                          SizedBox(height: 5),
                                          getRating(
                                              widget?.food?.restaurant_entity)
                                        ],
                                      ),
                                    ]),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _jumpToShopDetails(
                          context, widget?.food?.restaurant_entity),
                      child: Container(
                        child: Center(
                            child: Icon(
                          Icons.other_houses_rounded,
                          size: 20,
                          color: KColors.primaryColor,
                        )),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        padding: EdgeInsets.all(5),
                      ),
                    )),
              ],
            )),
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
        builder: (context) => ShopDetailsPage(
            restaurant: restaurantModel,
            presenter: RestaurantDetailsPresenter()),
      ),
    );
  }

  _getRestaurantStateTag(ShopModel shopModel) {
    String tagText = "-- --";
    Color tagTextColor = Colors.white;

    switch (shopModel?.open_type) {
      case 0: // closed
        tagText = "${AppLocalizations.of(context).translate('t_closed')}";
        tagTextColor = KColors.mBlue;
        break;
      case 1: // open
        tagText = "${AppLocalizations.of(context).translate('t_opened')}";
        tagTextColor = CommandStateColor.delivered;
        break;
      case 2: // paused
        tagText = "${AppLocalizations.of(context).translate('t_paused')}";
        tagTextColor = KColors.mBlue;
        break;
      case 3: // blocked
        tagText = "${AppLocalizations.of(context).translate('t_unavailable')}";
        tagTextColor = KColors.mBlue;
        break;
    }

    return shopModel?.coming_soon == 0
        ? Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white),
            child: Text(tagText?.toUpperCase(),
                style: TextStyle(color: tagTextColor, fontSize: 11)))
        : Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white),
            child: Text(
                "${AppLocalizations.of(context).translate('coming_soon')}"
                    ?.toUpperCase(),
                style: TextStyle(color: Colors.grey, fontSize: 11)));
  }

  getRating(ShopModel shopModel) {
    if (shopModel?.stars?.toInt() != null && shopModel?.stars?.toInt() > 0)
    return Row(
        children: <Widget>[]..addAll(
              List<Widget>.generate(shopModel?.stars?.toInt(), (int index) {
            return Icon(Icons.star,
                color: KColors.primaryYellowColor, size: 20);
          })
                ..add((shopModel.stars * 10) % 10 != 0
                    ? Icon(Icons.star_half,
                        color: KColors.primaryYellowColor, size: 20)
                    : Container())));
    else
     return Container();
  }

  void _jumpToShopDetails(BuildContext context, ShopModel shopModel) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopDetailsPage(  distance: shopModel?.distance,
                shipping_price: shopModel?.delivery_pricing,
                restaurant: shopModel, presenter: RestaurantDetailsPresenter()),
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
}
