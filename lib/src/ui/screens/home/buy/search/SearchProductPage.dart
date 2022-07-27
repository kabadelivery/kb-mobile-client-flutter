import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/SearchStatelessWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShopListWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chip_list/chip_list.dart';
import 'package:toast/toast.dart' as to;


class SearchProductPage extends StatefulWidget {
  static var routeName = "/SearchProductPage";

  int searchType;

  Key key;

  SearchProductPage({this.key, this.searchType}) : super(key: key);

  @override
  SearchProductPageState createState() => SearchProductPageState();
}

/* we show categories */

class SearchProductPageState extends State<SearchProductPage> {
  bool isLoading;

  bool hasNetworkError;

  bool hasSystemError;

  int _chipCurrentIndex = 0;

  List<String> _searchChoices = [];


  @override
  void initState() {
    super.initState();
    hasSystemError = false;
    hasNetworkError = false;
    isLoading = false;
    // according to the type, we have different names
    _searchChoices = ["Shop", "Product"];
    switch (widget.searchType) {
      case 0:
        // all : shop , product
        // _searchChoices = ["Shop", "Product"];
        // "${AppLocalizations.of(context).translate("what_want_buy")}");
        break;
      case 1:
      // food: restaurant, food
      case 2:
      // drink: shop, drink
      case 3:
      // cinema: cinema, movie
      case 4:
      // flowers: shop,flowers
      // case 5:
      // // tickets: event, activity
      //
      // case 6:
      // // groceries: shop, product
      // case 7:
      // // supermarket: shop, product
      // case 8:
      // library: library, books
      default:
      // gaz / package delivery
    }

    // then according to product, we can have adapt-a_t_i_v_e design to show products.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: SafeArea(
              top: true,
              child: Container(
                child: Container(
                    child: isLoading
                        ? Center(child: MyLoadingProgressWidget())
                        : (hasNetworkError
                            ? _buildNetworkErrorPage()
                            : hasSystemError
                                ? _buildSysErrorPage()
                                : _buildSearchPage())),
              ),
            )));
  }

  _buildSysErrorPage() {
    return Center(child: Text("sys error"));
  }

  _buildNetworkErrorPage() {
    return Center(child: Text("network error"));
  }

  _buildSearchPage() {
    return SingleChildScrollView(
      child: Column(children: [
        SearchStatelessWidget(
            searchProduct: false,
            isFillAble: true,
            callback: _searchRequest,
            // input a function that will be triggered if if
            // the customer presses on search
            title:
                "${AppLocalizations.of(context).translate("what_want_buy")}"),
        // chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipList(
              listOfChipNames: _searchChoices,
              activeBgColorList: [Theme.of(context).primaryColor],
              inactiveBgColorList: [Colors.grey.withOpacity(0.4)],
              activeTextColorList: [Colors.white],
              inactiveTextColorList: [Colors.black.withOpacity(0.5)],
              listOfChipIndicesCurrentlySeclected: [_chipCurrentIndex],
              extraOnToggle: (val) {
                _chipCurrentIndex = val;
                setState(() {});
              },
            ),
          ],
        ),
     /* list of shops or results */
        ShopListWidget()
      ]),
    );
  }


  /**
   * Function will search for
   */
  void _searchRequest (String searchContent) {
    mToast("search -- ${searchContent}");
  }

  void mToast(String message) {
    to.Toast.show(message, context, duration: to.Toast.LENGTH_LONG);
  }

}
