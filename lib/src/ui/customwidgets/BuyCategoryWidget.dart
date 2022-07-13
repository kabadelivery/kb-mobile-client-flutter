import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/screens/home/restaurant/RestaurantListPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class BuyCategoryWidget extends StatelessWidget {
  ServiceMainEntity entity;

  bool available;

  BuyCategoryWidget(ServiceMainEntity entity, {bool available = true}) {
    this.entity = entity;
    this.available = available;
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: () {
            _jumpToPage(
                context,
                RestaurantListPage(
                    context: context,
                    foodProposalPresenter: RestaurantFoodProposalPresenter(),
                    restaurantListPresenter: RestaurantListPresenter()));
          },
          child: Container(
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            decoration: BoxDecoration(
                color: KColors.new_gray,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Container(width: 45, height: 45, child: getCategoryIcon()),
              SizedBox(width: 20),
              Flexible(
                  child: Text(getCategoryTitle(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black)))
            ]),
          ),
        ),
      ),
    );
  }

  String getCategoryTitle(BuildContext context) {
    String category_name_code = "";
    switch (entity?.category_id) {
      case 1001: // food
        category_name_code = "service_category_food";
        break;
      case 1002: // drinks
        category_name_code = "service_category_drinks";
        break;
      case 1003: // flowers
        category_name_code = "service_category_flower";
        break;
      case 1004: // groceries
        category_name_code = "service_category_groceries";
        break;
      case 1005: // movies
        category_name_code = "service_category_movies";
        break;
      case 1006: // package delivery
        category_name_code = "service_category_package_delivery";
        break;
      case 1007: // shopping
        category_name_code = "service_category_shopping";
        break;
      case 1008: // ticket
        category_name_code = "service_category_ticket";
        break;
    }
    // unknown
    if ("" == category_name_code) {
      category_name_code = "service_category_unknown";
    }

    return "${AppLocalizations.of(context).translate(category_name_code)}";
  }

  getCategoryIcon() {
    String category_icon = "";
    switch (entity?.category_id) {
      case 1001: // food
        category_icon = LottieAssets.food;
        break;
      case 1002: // drinks
        category_icon = LottieAssets.drinks;
        break;
      case 1003: // flowers
        category_icon = LottieAssets.flower;
        break;
      case 1004: // groceries
        category_icon = LottieAssets.groceries;
        break;
      case 1005: // movies
        category_icon = LottieAssets.movie;
        break;
      case 1006: // package
        category_icon = LottieAssets.package_delivery;
        break;
      case 1007: // shopping
        category_icon = LottieAssets.shopping;
        break;
      case 1008: // ticket
        category_icon = LottieAssets.ticket;
        break;
    }
    if ("" == category_icon) {
      return Icon(Icons.not_interested);
    }

    return Lottie.asset(category_icon, animate: available);
  }
}
