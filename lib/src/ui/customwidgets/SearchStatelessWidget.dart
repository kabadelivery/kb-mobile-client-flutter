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

class SearchStatelessWidget extends StatelessWidget {
  String title;

  bool isFillAble;

  Function callback;

  TextEditingController _searchFieldController = new TextEditingController();

  /* we filter on shops,
  and search dynamically on products */
  bool searchProduct;

  SearchStatelessWidget(
      {this.title,
      this.isFillAble = false,
      this.callback,
      this.searchProduct = false});

  /*void _jumpToPage(BuildContext context, page) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ));
  }*/

  @override
  Widget build(BuildContext context) {
    // have to types, the one
    // type fill-able, we put in

    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5)),
//            border: new Border.all(color: Colors.white),
                  color: KColors.primaryColor.withAlpha(30)),
              padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
              margin: EdgeInsets.only(top: 10, bottom: 8, left: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        style: TextStyle(color: KColors.new_black, fontSize: 14),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration.collapsed(
                            hintText: title,
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: KColors.new_black)),
                        enabled: false),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
              child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5)),
                color: KColors.primaryColor),
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(top: 9, bottom: 9, right: 10, left: 10),
            child: Icon(Icons.search, color: Colors.white, size: 30),
          ))
        ],
      ),
    );

    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 6),
        padding: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(5),
            color: KColors.primaryColor.withAlpha(25)),
        child: Row(children: [
          searchProduct
              ? InkWell(
                  child: Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.grey.withAlpha(50),
                      child: Icon(Icons.search, color: KColors.primaryColor)),
                  onTap: () => callback(_searchFieldController.text),
                )
              : Container(),
          SizedBox(width: 12),
          this.isFillAble
              ? Expanded(
                  child: TextField(
                  controller: _searchFieldController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: KColors.new_black.withAlpha(75)),
                      hintText: "${title}"),
                ))
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Text("${title}",
                        style: TextStyle(color: KColors.new_black.withAlpha(75))),
                  ),
                ),
        ]));
  }
}
