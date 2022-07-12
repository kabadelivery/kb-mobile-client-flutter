import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShopListWidget extends StatefulWidget {
  ShopModel restaurantModel = ShopModel(
      name: "Quartier des fleurs",
      address: "6381 Elgin St. Celina, Delaware 10299");

  ShopListWidget({
    Key key,
    this.restaurantModel,
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
        /*  color: Colors.green,
          padding: const EdgeInsets.only(top: 30.0),*/
          child: Stack(
            children: [
              Container(
                  color: Colors.grey,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(241, 241, 241, 1.0),
                      ),
                      child: Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                          child: Row(
                            children: [
                              // ListTile(
                              /* contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                                leading: */
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      border: new Border.all(color: KColors.primaryColor.withOpacity(0.7), width: 2),
                                      /*borderRadius:
                                          BorderRadius.all(Radius.circular(2)),*/
                                      // border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              Utils.inflateLink(widget
                                                  .restaurantModel?.pic))))),
                              /*title:*/
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("${widget?.restaurantModel?.name}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 5),
                                    Text("${widget?.restaurantModel?.address}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black.withAlpha(150))),
                                    SizedBox(height: 5),
                                    /* kilometers and shipping fees */
                                    Row(children: <Widget>[
                                      widget.restaurantModel?.distance == null
                                          ? Container()
                                          : Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(5)),
                                                  color: Colors.white),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                      FontAwesomeIcons
                                                          .locationArrow,
                                                      color: KColors.mGreen,
                                                      size: 14),
                                                  Text(
                                                      "~${widget.restaurantModel?.distance}${AppLocalizations.of(context).translate('km')}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                      SizedBox(width: 10),
                                      widget.restaurantModel?.distance == null
                                          ? Container()
                                          : widget.restaurantModel
                                                      ?.delivery_pricing ==
                                                  "0"
                                              ? Container()
                                              : Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(5)),
                                                      color: Colors.white),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                          FontAwesomeIcons
                                                              .moneyBill,
                                                          color: KColors
                                                              .primaryYellowColor,
                                                          size: 14),
                                                      SizedBox(width: 5),
                                                      Text(
                                                          (widget.restaurantModel
                                                                      ?.delivery_pricing ==
                                                                  "~"
                                                              ? "${AppLocalizations.of(context).translate('out_of_range')}"
                                                              : widget?.restaurantModel
                                                                      ?.delivery_pricing +
                                                                  " F"),
                                                          style: TextStyle(
                                                              color: Colors.grey,
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
                  top: -15,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(children: [
                            _getRestaurantStateTag(widget?.restaurantModel),
                            SizedBox(width: 5),
                            widget?.restaurantModel?.coming_soon == 1
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
                                : Container()
                            // getRating(widget.restaurantModel)
                          ]),
                        ],
                      ))),
            ],
          ),
        ),
        onTap: () {
          widget?.restaurantModel?.coming_soon == 0
              ? _jumpToRestaurantMenu(context, widget.restaurantModel)
              : _comingSoon(context, widget.restaurantModel);
        }));
  }

  void _jumpToRestaurantDetails(
      BuildContext context, ShopModel restaurantModel) {
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel, presenter: RestaurantDetailsPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantDetailsPage(
                restaurant: restaurantModel,
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

  void _jumpToRestaurantMenu(BuildContext context, ShopModel restaurantModel) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                restaurant: restaurantModel, presenter: MenuPresenter()),
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
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel, presenter: MenuPresenter()),
      ),
    );*/
  }

  void _comingSoon(BuildContext context, ShopModel restaurantModel) {
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
                                  Utils.inflateLink(restaurantModel?.pic))))),
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

  _getRestaurantStateTag(ShopModel restaurantModel) {
    String tagText = "-- --";
    Color tagTextColor = Colors.white;
    Color tagColor = KColors.primaryColor;

    switch (restaurantModel?.open_type) {
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

    return restaurantModel?.coming_soon == 0
        ? Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: tagColor),
            child: Text(tagText,
                style: TextStyle(color: tagTextColor, fontSize: 12)))
        : Container();
  }

  getRating(ShopModel restaurantModel) {
    /* return Row(children: <Widget>[]
      ..addAll(
          List<Widget>.generate(restaurantModel.stars.toInt(), (int index) {
            return Icon(Icons.star, color: KColors.primaryYellowColor, size: 14);
          })
            ..add((restaurantModel.stars*10)%10 != 0 ? Icon(Icons.star_half, color: KColors.primaryYellowColor, size: 14) : Container())
      ));*/
  }
}
