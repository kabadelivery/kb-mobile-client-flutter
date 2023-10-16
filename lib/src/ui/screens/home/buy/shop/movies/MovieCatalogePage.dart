import 'dart:async';
import 'dart:math';

import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/cinema_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/FlowerWidgetItem.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/movies/MovieWidgetItem.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/ui/customwidgets/BouncingWidget.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

class MovieCatalogePage extends StatefulWidget {
  static var routeName = "/MovieCatalogePage";

  ShopModel cinema;

  CinemaPresenter presenter;

  MovieCatalogePage({
    Key key,
    this.presenter,
    this.cinema = null,
  }) : super(key: key);

  @override
  _MovieCatalogePageState createState() => _MovieCatalogePageState();
}

class _MovieCatalogePageState extends State<MovieCatalogePage>
    with TickerProviderStateMixin
    implements CinemaView {
  /* add data */
  List<RestaurantSubMenuModel> data;

  /* create a presenter for menu page */

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  var _menuChipCurrentIndex = 0;

  List<String> _menuChoices = [];

  @override
  void initState() {
    super.initState();

    widget.presenter.cinemaView = this;

    _menuChoices = ["Up this week", "Today", "Tomorrow", "Thursday"];
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      brightness: Brightness.dark,
      backgroundColor: KColors.primaryColor,
      title: GestureDetector(
          child: Row(children: <Widget>[
        // Text("${AppLocalizations.of(context).translate('menu')}", style: TextStyle(fontSize: 14, color: Colors.white)),
        // SizedBox(width: 10),
        Container(
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(100),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Text("Canal Olympia Godopé",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.white)))
      ])),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          }),
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
          color: Colors.grey.withAlpha(5),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: isLoading
              ? Center(child: MyLoadingProgressWidget())
              : (hasNetworkError
                  ? _buildNetworkErrorPage()
                  : hasSystemError
                      ? _buildSysErrorPage()
                      : Column(children: <Widget>[
                          SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                ChipList(
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                  listOfChipNames: _menuChoices,
                                  activeBgColorList: [
                                    Theme.of(context).primaryColor
                                  ],
                                  inactiveBgColorList: [
                                    KColors.primaryColor.withOpacity(0.15)
                                  ],
                                  activeTextColorList: [Colors.white],
                                  inactiveTextColorList: [
                                    KColors.new_black.withOpacity(0.7)
                                  ],
                                  listOfChipIndicesCurrentlySeclected: [
                                    _menuChipCurrentIndex
                                  ],
                                  extraOnToggle: (val) {
                                    _menuChipCurrentIndex = val;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          isLoading
                              ? Center(child: MyLoadingProgressWidget())
                              : (hasNetworkError
                                  ? ErrorPage(
                                      message:
                                          "${AppLocalizations.of(context).translate('network_error')}",
                                      onClickAction: () {})
                                  : hasSystemError
                                      ? ErrorPage(
                                          message:
                                              "${AppLocalizations.of(context).translate('system_error')}",
                                          onClickAction: () {})
                                      : _buildCinemaCatalog()),
                        ]))),
    );
  }

  _buildCinemaCatalog() {
    if (hasSystemError || hasNetworkError) {
      return Container();
    }

    if (data == null || data?.length == 0)
      return Center(
          child: Text("${AppLocalizations.of(context).translate('no_data')}"));

    this?.data = data;

    return SingleChildScrollView(child: Column(children: []));
  }

  _jumpToMovieDetails(BuildContext context, ShopProductModel food) {
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: food),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopFlowerDetailsPage(food: food),
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

  void showToast(String message) {
    Toast.show(message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      hasNetworkError = false;
      hasSystemError = false;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {});
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {});
  }

  @override
  void networkError() {
    showLoading(false);
    setState(() {
      hasNetworkError = true;
    });
  }

  @override
  void systemError() {
    showLoading(false);
    setState(() {
      hasSystemError = true;
    });
  }

  void _showDialog(
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  @override
  void inflateMovieSchedule(ShopModel cinema, List<MovieModel> data) {}
}
