import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/restaurant_list_contract.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ServiceMainEntity.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopListPageRefined.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/out_of_app.dart';
import 'package:KABA/src/ui/screens/out_of_app_orders/shipping_package.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyCategoryWidget extends StatefulWidget {
  ServiceMainEntity entity;

  bool available;

  bool isNew;

  Function mDialog;

  Function showPlacePicker;

  BuyCategoryWidget(ServiceMainEntity entity,
      {this.available = true, this.mDialog, this.showPlacePicker}) {
    this.entity = entity;
    this.available = available;
    this.isNew = (entity?.is_new == 1);
  }

  @override
  State<BuyCategoryWidget> createState() => _BuyCategoryWidgetState();
}

class _BuyCategoryWidgetState extends State<BuyCategoryWidget> {
  void _jumpToPage(BuildContext context) {
    if (StateContainer.of(context).location?.latitude == null &&
        StateContainer.of(context).hasAskedLocation == false) {
      StateContainer.of(context).hasAskedLocation = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${AppLocalizations.of(context).translate('info')}"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: new AssetImage(ImageAssets.address),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate('request_location_permission')}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14))
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('refuse')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                  // if no, let me do my thing
                  var page;
                  if (!widget.available) {
                    // dialog, this service is coming soon
                    widget.mDialog(
                        "${AppLocalizations.of(context).translate('coming_soon_dialog')}");
                  } else {
                    
                    page =
                    ShopListPageRefined(
                        context: context,
                        type: widget.entity?.key,
                        foodProposalPresenter:
                            RestaurantFoodProposalPresenter(),
                        restaurantListPresenter: RestaurantListPresenter());
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            page,
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end);
                          var curvedAnimation =
                              CurvedAnimation(parent: animation, curve: curve);
                          return SlideTransition(
                              position: tween.animate(curvedAnimation),
                              child: child);
                        }));
                  }
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('accept')}"),
                onPressed: () {
                  /* */
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  SharedPreferences.getInstance().then((value) async {
                    SharedPreferences prefs = value;
                    String _has_accepted_gps =
                        prefs.getString("_has_accepted_gps");
                    prefs.setString("_has_accepted_gps", "ok");
                    Navigator.of(context).pop();
                    // call get location again...
                    widget.showPlacePicker(context);
                  });
                },
              )
            ],
          );
        },
      );
    } else {
      // if no, let me do my thing
      var page;
      if (!widget.available) {
        // dialog, this service is coming soon
        widget.mDialog(
            "${AppLocalizations.of(context).translate('coming_soon_dialog')}");
      } else {
        print('key ${widget.key}');
        page =widget.entity.key=="packages"?ShippingPackageOrderPage():
        widget.entity.key=="out of app"? OutOfAppOrderPage():
        ShopListPageRefined(
            context: context,
            type: widget.entity?.key,
            foodProposalPresenter: RestaurantFoodProposalPresenter(),
            restaurantListPresenter: RestaurantListPresenter());
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
          _jumpToPage(context);
        },
        child: Container(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 2, top: 4, bottom: 4),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    child: getCategoryIcon()),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text(getCategoryTitle(context),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: KColors.new_black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)))
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              widget.isNew
                  ? Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.only(
                            top: 4, bottom: 4, right: 4, left: 4),
                        decoration: BoxDecoration(
                            color: KColors.primaryYellowColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  String getCategoryTitle(BuildContext context) {
    /* get language of phone */
    try {
      Locale myLocale = Localizations.localeOf(context);
      String name = widget.entity.name[myLocale?.languageCode];
      if (name != null)
        return name;
      else
        return getCategoryTitleOld(context);
    } catch (e) {
      return getCategoryTitleOld(context);
    }
  }

  String getCategoryTitleOld(BuildContext context) {
    String category_name_code = "";
    switch (widget.entity?.key) {
      case "food": // food
        category_name_code = "service_category_food";
        break;
      case "drink": // drinks
        category_name_code = "service_category_drinks";
        break;
      case "flower": // flowers
        category_name_code = "service_category_flower";
        break;
      case "grocery": // groceries
        category_name_code = "service_category_groceries";
        break;
      case "book": // groceries
        category_name_code = "service_category_book";
        break;
      //   case 1005: // movies
      //     category_name_code = "service_category_movies";
      //     break;
      //   case 1006: // package delivery
      //     category_name_code = "service_category_package_delivery";
      //     break;
      case "shop": // shopping
        category_name_code = "service_category_shopping";
        break;
      case "drugstore": // shopping
        category_name_code = "service_category_drugstore";
        break;
      case "ticket": // ticket
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
    /*
     String category_icon = "";
    switch (widget.entity?.key) {
      case "food": // food
        category_icon = LottieAssets.food;
        break;
      case "drink": // drinks
        category_icon = LottieAssets.drinks;
        break;
      case "flower": // flowers
        category_icon = LottieAssets.flower;
        break;
      case "grocery": // groceries
        category_icon = LottieAssets.groceries;
        break;
      case "book":
        category_icon = LottieAssets.books;
        break;
      // case 1005: // movies
      //   category_icon = LottieAssets.movie;
      //   break;
      // case 1006: // package
      //   category_icon = LottieAssets.package_delivery;
      //   break;
      case "shop": // shopping
        category_icon = LottieAssets.shopping;
        break;
      case "ticket": // ticket
        category_icon = LottieAssets.ticket;
        break;
      case "drugstore": // ticket
        category_icon = LottieAssets.drugstore;
        break;
    }
    if ("" == category_icon) {
      return Icon(Icons.not_interested);
    }
*/

    return widget.entity.is_lottie_file == 1
        ? Lottie.network(widget.entity.file_link)
        : CachedNetworkImage(
            imageUrl: widget.entity.file_link,
            errorWidget: (context, url, error) => Icon(Icons.not_interested),
          );
  }
}

class MyLottie extends StatefulWidget {
  String path;

  MyLottie({Key key, this.path}) : super(key: key);

  @override
  State<MyLottie> createState() => _MyLottieState();
}

class _MyLottieState extends State<MyLottie> {
  Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();

    _composition = _loadComposition();
  }

  Future<LottieComposition> _loadComposition() async {
    var assetData = await rootBundle.load('${widget.path}');
    return await LottieComposition.fromByteData(assetData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: _composition,
      builder: (context, snapshot) {
        var composition = snapshot.data;
        if (composition != null) {
          return Lottie(composition: composition);
        } else {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        }
      },
    );
  }
}
