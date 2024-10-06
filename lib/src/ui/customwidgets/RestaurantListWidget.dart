import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RestaurantListWidget extends StatefulWidget {
  ShopModel restaurantModel;

  RestaurantListWidget({
    Key key,
    this.restaurantModel,
  }) : super(key: key);

  @override
  _RestaurantListWidgetState createState() => _RestaurantListWidgetState();
}

class _RestaurantListWidgetState extends State<RestaurantListWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (InkWell(
        child: Card(
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
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
                                  color: KColors.primaryYellowColor, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      Utils.inflateLink(
                                          widget?.restaurantModel?.pic))))),
                      trailing: widget.restaurantModel.coming_soon == 0
                          ? IconButton(
                              icon: Icon(Icons.home,
                                  size: 30, color: KColors.primaryColor),
                              onPressed: () {
                                _jumpToRestaurantDetails(
                                    context, widget.restaurantModel);
                              })
                          : null,
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${widget?.restaurantModel?.name}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: KColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 10),
                          Text("${widget?.restaurantModel?.address}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: KColors.new_black.withAlpha(150))),
                        ],
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      color: Colors.grey.withAlpha(120),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width, height: 1
                          /* height is max*/
                          )),
                  SizedBox(width: 5),
                  Container(
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
                                            color: Colors.white, fontSize: 12)))
                                : Container()
                            // getRating(widget.restaurantModel)
                          ]),
                          Row(children: <Widget>[
                            widget.restaurantModel?.distance == null
                                ? Container()
                                : widget.restaurantModel?.delivery_pricing ==
                                        "0"
                                    ? Container()
                                    : Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            color: KColors.primaryYellowColor),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.directions_bike,
                                                color: KColors.new_black,
                                                size: 14),
                                            SizedBox(width: 5),
                                            Text(
                                                (widget.restaurantModel
                                                            ?.delivery_pricing ==
                                                        "~"
                                                    ? "${AppLocalizations.of(context).translate('out_of_range')}"
                                                    : widget.restaurantModel
                                                            ?.delivery_pricing +
                                                        " F"),
                                                style: TextStyle(
                                                    color: KColors.new_black,
                                                    fontSize: 12)),
                                          ],
                                        )),
                            SizedBox(width: 10),
                            widget.restaurantModel?.distance == null
                                ? Container()
                                : Text(
                                    "~${widget.restaurantModel?.distance}${AppLocalizations.of(context).translate('km')}",
                                    style: TextStyle(
                                        color: KColors.new_black,
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12))
                          ])
                        ],
                      ))
                ]))),
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
            ShopDetailsPage(
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
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
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
