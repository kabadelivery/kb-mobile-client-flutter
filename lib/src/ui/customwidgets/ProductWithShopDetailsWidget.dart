import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

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
                      color: KColors.new_gray,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            height: 115,
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
                                    image: OptimizedCacheImageProvider(
                                        Utils.inflateLink(widget?.food?.pic)))),
                          ),
                          SizedBox(width: 18),
                          Container(
                            height: 115,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
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
                                              child: Text(
                                                  Utils.capitalize(
                                                      "${widget?.food?.name}"),
                                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: KColors.new_black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                           width: MediaQuery.of(context).size.width-200, ),
                                           SizedBox(height: 5,),
                                            Row(children: <Widget>[
                                              Text(
                                                  "${widget?.food?.price}",
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: widget?.food
                                                                  .promotion ==
                                                              1
                                                          ? KColors.new_black
                                                          : KColors.primaryColor,
                                                      fontSize: widget?.food
                                                                  .promotion ==
                                                              1
                                                          ? 12
                                                          : 14,
                                                      decoration: widget?.food
                                                                  .promotion ==
                                                              1
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              SizedBox(width: 3),
                                              (widget?.food.promotion == 1
                                                  ? Text(
                                                      "${widget?.food?.promotion_price}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: KColors
                                                            .primaryYellowColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ))
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
                                                          FontWeight.w600)),
                                            ]),
                                          ],
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  Utils.capitalize(
                                                      "${widget?.food?.restaurant_entity?.name}"),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  // textAlign: TextAlign.left,
                                                  style: TextStyle(fontWeight: FontWeight.w500,
                                                      color: KColors.new_black,
                                                      fontSize: 14)),
                                              SizedBox(height: 5),
                                              Row(children: <Widget>[
                                                _getRestaurantStateTag(widget
                                                    ?.food?.restaurant_entity),
                                                SizedBox(width: 5),
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
                                                            SizedBox(width: 5),
                                                            Text(
                                                                "${widget?.food?.restaurant_entity?.distance}${AppLocalizations.of(context).translate('km')}",
                                                                style: TextStyle(
                                                                    color:
                                                                        Colors.grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    fontSize: 12)),
                                                          ],
                                                        ),
                                                      ),
                                                SizedBox(width: 5),
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
                                                                            .grey,fontWeight: FontWeight.w500,
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
                                        ),
                                      ]),
                                ),
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
            padding: EdgeInsets.only(left:5, right: 5, top: 2, bottom: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white),
            child: Text(tagText?.toUpperCase(),
                style: TextStyle(color: tagTextColor, fontWeight: FontWeight.w600, fontSize: 12)))
        : Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white),
            child: Text(
                "${AppLocalizations.of(context).translate('coming_soon')}"
                    ?.toUpperCase(),
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 11)));
  }

  getRating(ShopModel shopModel) {
    if (shopModel?.stars?.toInt() != null && shopModel?.stars?.toInt() > 0)
      return Row(
          children: <Widget>[]..addAll(
                List<Widget>.generate(shopModel?.stars?.toInt(), (int index) {
              return Icon(FontAwesomeIcons.solidStar,
                  color: KColors.primaryYellowColor, size: 15);
            })
                  ..add((shopModel.stars * 10) % 10 != 0
                      ? Icon(FontAwesomeIcons.solidStarHalf,
                          color: KColors.primaryYellowColor, size: 15)
                      : Container())));
    else
      return Container();
  }

  void _jumpToShopDetails(BuildContext context, ShopModel shopModel) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopDetailsPage(
                distance: shopModel?.distance,
                shipping_price: shopModel?.delivery_pricing,
                restaurant: shopModel,
                presenter: RestaurantDetailsPresenter()),
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
