import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPage.dart';
import 'package:KABA/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class BuyCategoryWidget extends StatelessWidget {

  ServiceMainEntity entity;

  bool available;

  bool isNew;

  Function mDialog;

  BuyCategoryWidget(ServiceMainEntity entity,
      {this.available = true, this.isNew = false, this.mDialog}) {
    this.entity = entity;
    this.available = available;
  }

  void _jumpToPage(BuildContext context) {
    var page;

    if (!available) {
      // dialog, this service is coming soon
      mDialog("${AppLocalizations.of(context).translate('coming_soon_dialog')}");
    } else {

      page = ShopListPage(
          context: context,
          type: entity?.key,
          foodProposalPresenter: RestaurantFoodProposalPresenter(),
          restaurantListPresenter: RestaurantListPresenter());

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: KColors.buy_category_button_bg,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: InkWell(
        onTap: () {
          _jumpToPage(
              context);
        },
        child: Container(
          child: Stack(
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.only(left: 8, right: 2, top: 4, bottom: 4),
                          child: Row(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Container(width: 40, height: 40, child: getCategoryIcon()),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text(getCategoryTitle(context),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: KColors.new_black, fontSize: 14, fontWeight: FontWeight.w500)))
                          ]),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
         isNew
                  ? Positioned(right: 0, top: 0,
                    child: Container(
                    padding: EdgeInsets.only(top: 2, bottom: 2, right: 5, left: 5),
                    decoration: BoxDecoration(
                        color: KColors.primaryYellowColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            topRight: Radius.circular(5))),
                    child: Text(
                        // "${AppLocalizations.of(context).translate('new')}",
                    "NEW",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))),
                  )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  String getCategoryTitle(BuildContext context) {
    String category_name_code = "";
    switch (entity?.key) {
      case "food": // food
        category_name_code = "service_category_food";
        break;
    //   case "drink": // drinks
    //     category_name_code = "service_category_drinks";
    //     break;
    case "flower": // flowers
        category_name_code = "service_category_flower";
        break;
    //   case 1004: // groceries
    //     category_name_code = "service_category_groceries";
    //     break;
    //   case 1005: // movies
    //     category_name_code = "service_category_movies";
    //     break;
    //   case 1006: // package delivery
    //     category_name_code = "service_category_package_delivery";
    //     break;
      case "shop": // shopping
        category_name_code = "service_category_shopping";
        break;
     //  case 1008: // ticket
     //    category_name_code = "service_category_ticket";
     // break;
    }
    // unknown
    if ("" == category_name_code) {
      category_name_code = "service_category_unknown";
    }

    return "${AppLocalizations.of(context).translate(category_name_code)}";
  }

  getCategoryIcon() {
    String category_icon = "";
    switch (entity?.key) {
      case "food": // food
        category_icon = LottieAssets.food;
        break;
      // case 1002: // drinks
      //   category_icon = LottieAssets.drinks;
      //   break;
      case "flower": // flowers
        category_icon = LottieAssets.flower;
        break;
      // case 1004: // groceries
      //   category_icon = LottieAssets.groceries;
      //   break;
      // case 1005: // movies
      //   category_icon = LottieAssets.movie;
      //   break;
      // case 1006: // package
      //   category_icon = LottieAssets.package_delivery;
      //   break;
      case "shop": // shopping
        category_icon = LottieAssets.shopping;
        break;
      // case 1008: // ticket
      //   category_icon = LottieAssets.ticket;
      //   break;
    }
    if ("" == category_icon) {
      return Icon(Icons.not_interested);
    }

    return Lottie.asset(category_icon, animate: available);
  }


}
