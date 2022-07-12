import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShopListWidget extends StatefulWidget {
  ShopModel shopModel = ShopModel(
      name: "Quartier des fleurs",
      address: "6381 Elgin St. Celina, Delaware 10299");

  ShopListWidget({
    Key key,
    this.shopModel,
  }) : super(key: key);

  @override
  _ShopListWidgetState createState() => _ShopListWidgetState();
}

class _ShopListWidgetState extends State<ShopListWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (InkWell(
        child: Container(
          margin: new EdgeInsets.symmetric(horizontal: 10.0),
          /*  color: Colors.green,
          padding: const EdgeInsets.only(top: 30.0),*/
          child: Stack(
            children: [
              Container(
                  color: Colors.grey,
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(241, 241, 241, 1.0),
                      ),
                      child: Column(children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.only(top: 10, bottom: 10, left: 10),
                          child: Row(
                            children: [
                              // ListTile(
                              /* contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                                leading: */
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      border: new Border.all(
                                          color: KColors.primaryColor
                                              .withOpacity(0.7),
                                          width: 2),
                                      /*borderRadius:
                                          BorderRadius.all(Radius.circular(2)),*/
                                      // border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              Utils.inflateLink(widget
                                                  .shopModel?.pic))))),
                              /*title:*/
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "${Utils.capitalize(widget?.shopModel?.name)}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 5),
                                    Text("${widget?.shopModel?.address}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                            fontSize: 13,
                                            color:
                                                Colors.black.withAlpha(150))),
                                    SizedBox(height: 5),
                                    /* kilometers and shipping fees */
                                    Row(children: <Widget>[
                                      _getRestaurantStateTag(
                                          widget?.shopModel),
                                      SizedBox(width: 10),
                                      widget.shopModel?.distance == null
                                          ? Container()
                                          : Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.white),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      FontAwesomeIcons
                                                          .locationArrow,
                                                      color: KColors.mGreen,
                                                      size: 10),
                                                  Text(
                                                      " ${widget.shopModel?.distance}${AppLocalizations.of(context).translate('km')}",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                      SizedBox(width: 10),
                                      widget.shopModel?.distance == null
                                          ? Container()
                                          : widget.shopModel
                                                      ?.delivery_pricing ==
                                                  "0"
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
                                                    children: <Widget>[
                                                      Icon(
                                                          FontAwesomeIcons
                                                              .biking,
                                                          color: KColors
                                                              .primaryColor,
                                                          size: 12),
                                                      SizedBox(width: 5),
                                                      Text(
                                                          (widget.shopModel
                                                                      ?.delivery_pricing ==
                                                                  "~"
                                                              ? "${AppLocalizations.of(context).translate('out_of_range')}"
                                                              : widget?.shopModel
                                                                      ?.delivery_pricing +
                                                                  " F"),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12)),
                                                    ],
                                                  )),
                                    ])
                                  ],
                                ),
                              )
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                      ]))),
              Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(onTap: ()=>_jumpToShopDetails(context, widget.shopModel),
                    child: Container(
                      child: Center(
                          child:   Icon(
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
          ),
        ),
        onTap: () {
          widget?.shopModel?.coming_soon == 0
              ? _jumpToRestaurantMenu(context, widget.shopModel)
              : _comingSoon(context, widget.shopModel);
        }));
  }

  void _jumpToShopDetails(
      BuildContext context, ShopModel shopModel) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(restaurant: shopModel, presenter: RestaurantDetailsPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopDetailsPage(
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

  void _jumpToRestaurantMenu(BuildContext context, ShopModel shopModel) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                restaurant: shopModel, presenter: MenuPresenter()),
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

    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: shopModel, presenter: MenuPresenter()),
      ),
    );*/
  }

  void _comingSoon(BuildContext context, ShopModel shopModel) {
    /* show the coming soon dialog */
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                content:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          border: new Border.all(
                              color: KColors.primaryYellowColor, width: 2),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  Utils.inflateLink(shopModel?.pic))))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate('coming_soon_dialog')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]),
                actions: <Widget>[
                  //
                  OutlinedButton(
                    child: new Text(
                        "${AppLocalizations.of(context).translate('ok')}",
                        style: TextStyle(color: KColors.primaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]));
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
    /* return Row(children: <Widget>[]
      ..addAll(
          List<Widget>.generate(shopModel.stars.toInt(), (int index) {
            return Icon(Icons.star, color: KColors.primaryYellowColor, size: 14);
          })
            ..add((shopModel.stars*10)%10 != 0 ? Icon(Icons.star_half, color: KColors.primaryYellowColor, size: 14) : Container())
      ));*/
  }
}
