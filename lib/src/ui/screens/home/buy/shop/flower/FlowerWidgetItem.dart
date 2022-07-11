import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlowerWidgetItem extends StatelessWidget {
  ShopProductModel food;
  Function jumpToFoodDetails;

  var foodIndex;

  int menuIndex;

  int highlightedFoodId;

  GlobalKey dataKey;
  Map<String, GlobalKey> _keyBox = Map();

  Function showDetails;

  Function addFoodToChart;

  FlowerWidgetItem(
      {this.dataKey,
      this.food,
      this.foodIndex,
      this.menuIndex,
      this.highlightedFoodId,
      this.showDetails,
      this.addFoodToChart,
      this.jumpToFoodDetails});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => jumpToFoodDetails(context, food),
      child: Container(
          key: food?.id == highlightedFoodId ? dataKey : null,
          color: food?.id == highlightedFoodId
              ? Colors.yellow.withAlpha(50)
              : Colors.white,
          child: Column(
            children: [
              Container(
                height:MediaQuery.of(context).size.width/2,
                child: Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Stack(children: [
                            Positioned(child:    InkWell(
                              onTap: () => addFoodToChart(
                                  food, foodIndex, menuIndex),
                              child: Row(children: <Widget>[
                                Container(
                                    height: 50,
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                            Icons.add_shopping_cart,
                                            color: KColors
                                                .primaryColor)
                                      ],
                                    )),
                              ]),
                            ), right:0, bottom:0)
                          ]),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              // shape: BoxShape.rectangle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: CachedNetworkImageProvider(
                                      Utils.inflateLink(food?.pic)))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            /*  Positioned(
                  left: 0,
                  bottom: -10,
                  child: IconButton(
                      icon: Icon(FontAwesomeIcons.questionCircle,
                          color: KColors.primaryColor),
                      onPressed: () => showDetails(food))),*/
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text("${food?.name?.toUpperCase()}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: <Widget>[
                  Row(children: <Widget>[
                    Text("${food?.price}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: food.promotion != 0
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: KColors.primaryYellowColor,
                            fontSize: 20,
                            fontWeight: FontWeight.normal)),
                    SizedBox(width: 5),
                    (food.promotion != 0
                        ? Text("${food?.promotion_price}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: KColors.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.normal))
                        : Container()),
                    SizedBox(width: 5),
                    Text(
                        "${AppLocalizations.of(context).translate('currency')}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: KColors.primaryYellowColor,
                            fontSize: 10,
                            fontWeight: FontWeight.normal)),
                  ]),
                ],
              ),
              SizedBox(height: 5),

            ],
          )),
    );
  }
}
