import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FlowerWidgetItem extends StatelessWidget {
  ShopProductModel? food;
  Function? jumpToFoodDetails;

  var foodIndex;

  int? menuIndex;

  int? highlightedFoodId;

  GlobalKey? dataKey;
  Map<String, GlobalKey>? _keyBox = Map();

  Function? showDetails;

  Function? addFoodToChart;

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
      onTap: () => jumpToFoodDetails!(context, food),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: food?.id == highlightedFoodId
                  ? Colors.yellow.withAlpha(50)
                  : Colors.white),
          key: food?.id == highlightedFoodId ? dataKey : null,
          child: Column(
            children: [
              Container(
                child: Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Stack(children: [
                            Positioned(
                                child: InkWell(
                                  onTap: () => addFoodToChart!(
                                      food, foodIndex, menuIndex),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      height: 30,
                                      width: 30,
                                      padding:
                                          EdgeInsets.only(left: 5, right: 5),
                                      child: Icon(Icons.add_shopping_cart,
                                          size: 15,
                                          color: KColors.primaryColor)),
                                ),
                                right: 8,
                                bottom: 8)
                          ]),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              // shape: BoxShape.rectangle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: CachedNetworkImageProvider(
                                      Utils.inflateLink(food!.pic!)))),
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
                padding: EdgeInsets.only(left: 10, right: 5, top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Text("${Utils.capitalize(food!.name!)}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
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
                                  decoration: food!.promotion != 0
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: KColors.new_black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          (food!.promotion != 0
                              ? Text("${food?.promotion_price}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: KColors.primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700))
                              : Container()),
                          SizedBox(width: 2),
                          Text(
                              "${AppLocalizations.of(context)!.translate('currency')}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: KColors.new_black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
