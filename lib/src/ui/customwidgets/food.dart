import 'package:KABA/src/models/ShopModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../localizations/AppLocalizations.dart';
import '../../models/ShopProductModel.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/Utils.dart';
import '../../utils/functions/navigation.dart';

Widget _buildFoodListWidget3(
    {
      required BuildContext context,
      ShopProductModel? food,
      int? foodIndex,
      int? menuIndex,
      int? highlightedFoodId,
      ShopModel ? restaurant,
      }) {
  return InkWell(
    onTap: () => jumpToFoodDetails(context, food!,restaurant!),
    child: Container(
        width: MediaQuery.of(context).size.width - 20,
        margin: EdgeInsets.only(bottom: 15, left: 10, right: 10),

        child: Container(
          color: food!.id == highlightedFoodId
              ? Colors.yellow.withAlpha(50)
              : Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                        color: food!.id == highlightedFoodId
                            ? Colors.yellow.withAlpha(50)
                            : KColors.new_gray),
                    padding: EdgeInsets.all(10),
                    height: 115,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${Utils.capitalize(food!.name!.trim())}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: KColors.new_black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 5),
                              Text(
                                  "${Utils.capitalize(Utils.replaceNewLineBy(food!.description!.trim(), " / "))}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // added
                                Row(children: <Widget>[
                                  Text("${food!.price}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          decoration: food.promotion != 0
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: KColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(width: 3),
                                  (food.promotion != 0
                                      ? Text("${food!.promotion_price}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: KColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal))
                                      : Container()),
                                  SizedBox(width: 2),
                                  Text(
                                      "${AppLocalizations.of(context)!.translate('currency')}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: KColors.primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                ]),



                                // not added
                              ])
                        ]),
                  )),
              Container(
                color: KColors.new_gray,
                child: Container(
                  height: 115,
                  width: 115,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Utils.inflateLink(food!.pic!)))),
                ),
              ),
            ],
          ),
        )),
  );
}