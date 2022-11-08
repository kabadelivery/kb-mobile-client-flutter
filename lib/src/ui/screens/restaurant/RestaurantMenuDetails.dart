import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage.old';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:iphone_has_notch/iphone_has_notch.dart';
import 'package:toast/toast.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class RestaurantMenuDetails extends StatefulWidget {
  static var routeName = "/RestaurantMenuDetails";

  Map<ShopProductModel, int> food_selected, adds_on_selected;

  /* 1 - food, 2- addons, 3 - all */
  int type;

  int FOOD_MAX;

  ShopModel restaurant;

  RestaurantMenuDetails(
      {Key key,
      this.FOOD_MAX = 5,
      this.type,
      this.food_selected,
      this.adds_on_selected,
      this.restaurant})
      : super(key: key);

  @override
  _RestaurantMenuDetailsState createState() =>
      _RestaurantMenuDetailsState(type, food_selected, adds_on_selected);
}

class _RestaurantMenuDetailsState extends State<RestaurantMenuDetails> {
  Map<ShopProductModel, int> food_selected, adds_on_selected;

  /* 1 - food, 2- addons, 3 - all */
  int type;

  int _foodCount = 0;

//  , ADD_ON_COUNT = 10;
  int totalPrice = 0;

  _RestaurantMenuDetailsState(
      this.type, this.food_selected, this.adds_on_selected);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('my_basket')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
              color: Colors.white,
              child: _showMenuBottomSheet(context, type),
              height: MediaQuery.of(context).size.height),
        ],
      ),
    );
  }

/* build bottom_sheet_items_widget */
/*  Widget _buildBottomSheetFoodListWidget({ShopProductModel food}) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${food?.name.toUpperCase()}", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:KColors.new_black, fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  */ /*prix*/ /*
                  Row(children: <Widget>[
                    Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                    (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                        : Container()),
                    Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                  ]),
                  */ /* add buttons */ /*
                  Row(
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.remove_circle, color: KColors.new_black), onPressed: () => _decreaseQuantity(food)),
                        SizedBox(width: 2),
                        Container(margin: EdgeInsets.only(top:0),child: Text("${food.is_addon ? adds_on_selected[food].toInt() : food_selected[food].toInt()}", style: TextStyle(color: KColors.new_black, fontSize: 18))),
                        SizedBox(width: 2),
                        IconButton(icon: Icon(Icons.add_circle, color: KColors.new_black), onPressed: () => _increaseQuantity(food)),
                        SizedBox(width: 10),
                        IconButton(icon:Icon(Icons.delete_forever, color: KColors.primaryColor,), onPressed: () {_removeFood(food);}),
                      ]
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }  */

  Widget _buildBottomSheetFoodListWidget({ShopProductModel food}) {
    return GestureDetector(
      onTap: () => _jumpToFoodDetails(context, food),
      child: Container(
          decoration: BoxDecoration(
              color: KColors.new_gray,
              borderRadius: BorderRadius.all(Radius.circular(3))),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        shape: BoxShape.rectangle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                Utils.inflateLink(food?.pic)))),
                  ),
                  SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: MediaQuery.of(context).size.width-160,
                      child: Text("${Utils.capitalize(food?.name)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: KColors.new_black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(height: 2),
                    Container(
                      width: 1 * MediaQuery.of(context).size.width / 2,
                      child: Text("${Utils.capitalize(food?.description)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal)),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                                child: Container(decoration: BoxDecoration(color: KColors.primaryColor.withAlpha(30), shape: BoxShape.circle), padding: EdgeInsets.all(5),
                                  child: Icon(Icons.remove,
                                      color: KColors.primaryColor, size: 10),
                                ),
                                onTap: () => _decreaseQuantity(food)),
                            Container(
                                margin: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                    "${food.is_addon ? adds_on_selected[food].toInt() : food_selected[food].toInt()}",
                                    style: TextStyle(
                                        color: KColors.new_black, fontWeight: FontWeight.w600, fontSize: 15))),
                            InkWell(
                                child: Icon(Icons.add_circle,
                                    size: 23, color: KColors.primaryColor),
                                onTap: () => _increaseQuantity(food)),
                          ]),
                    ),
                  ])
                ],
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                      child: Container(
                          child: Icon(FontAwesome.remove,
                              size: 15, color: KColors.new_black),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          padding: EdgeInsets.all(5)),
                      onTap: () {
                        _removeFood(food);
                      })),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: KColors.primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  padding: EdgeInsets.only(top:5, bottom: 5, left: 10,right: 10),
                  child: Row(children: <Widget>[
                    SizedBox(width: 2),
                    Text("${food?.price}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: KColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: food.promotion != 0
                                ? TextDecoration.lineThrough
                                : TextDecoration.none)),
                    SizedBox(width: 2),
                    (food.promotion != 0
                        ? Text("${food?.promotion_price}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: KColors.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.normal))
                        : Container()),
                    SizedBox(width: 3),
                    Text("${AppLocalizations.of(context).translate('currency')}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: KColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
            ],
          )),
    );
  }

  /* we have different types: food, supplement, all */
  _showMenuBottomSheet(context, int type) {
    List<Widget> bottomSheetView = <Widget>[
      SizedBox(height: 10),
      false
          ? Center(
              child: Container(
                  decoration: BoxDecoration(
                      color: KColors.primaryYellowColor,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: EdgeInsets.only(top: 10),
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  child: Text(
                      "${AppLocalizations.of(context).translate('all')}"
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center)))
          : Container(),
      SizedBox(height: 10),
    ];

    if (type == 1 || type == 3) {
      /* generate the food views */
      if (food_selected != null && food_selected.length > 0)
        bottomSheetView
          ..addAll(food_selected.keys
              .map((mfood) => _buildBottomSheetFoodListWidget(food: mfood))
              .toList());
      bottomSheetView.add(SizedBox(height: 10));
    }

    if (type == 2 || type == 3) {
      /* generate the food views */
      if (adds_on_selected != null && adds_on_selected.length > 0)
        bottomSheetView
          ..addAll(adds_on_selected.keys
              .map((mfood) => _buildBottomSheetFoodListWidget(food: mfood))
              .toList());
      bottomSheetView.add(SizedBox(height: 10));
    }

    bottomSheetView.add(SizedBox(height: 140));

    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 0),
              child: Wrap(children: bottomSheetView)),
        ),
        Positioned(
          bottom: 35,
          child: Container(width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding:
                          EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "${AppLocalizations.of(context).translate('total')}"
                                  .toUpperCase(),
                              style: TextStyle(color: Colors.grey)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("${totalPrice}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: KColors.primaryColor)),
                              SizedBox(width: 5),
                              Text(
                                  "${AppLocalizations.of(context).translate('currency')}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: KColors.primaryColor)),
                            ],
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: _foodCount == 0
                      ? Container()
                      : Container(margin: EdgeInsets.only(right: 20),
                          height: 50,
                          // width: 0.9 * MediaQuery.of(context).size.width / 2,
                          padding: EdgeInsets.all(5),
                          color: Colors.white,
                          child: GestureDetector(
                            onTap: () {
                              _continuePurchase();
                            },
                            child: Container(

                              decoration: BoxDecoration(
                                  color: KColors.primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Center(
                                child: Text(
                                    "${AppLocalizations.of(context).translate('buy')}"
                                        ?.toUpperCase(),
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          )),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  _decreaseQuantity(ShopProductModel food) {
    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        if (food_selected[food].toInt() > 1)
          food_selected.update(
              food, (int val) => food_selected[food].toInt() - 1);
        else {
          showToast("${AppLocalizations.of(context).translate('min_reached')}");
        }
      } else {
        food_selected.putIfAbsent(food, () => 1);
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          if (adds_on_selected[food].toInt() > 1)
            adds_on_selected.update(
                food, (int val) => adds_on_selected[food].toInt() - 1);
          else {
            showToast(
                "${AppLocalizations.of(context).translate('min_reached')}");
          }
        } else {
          adds_on_selected.putIfAbsent(food, () => 1);
        }
      }
    }
    _updateCounts();
  }

  _increaseQuantity(ShopProductModel food) {
    if (_foodCount >= widget.FOOD_MAX) {
      showToast("${AppLocalizations.of(context).translate('max_reached')}");
      return;
    } else {
      /* if max is reached, we dont increase */
      if (!food.is_addon) {
        if (food_selected.containsKey(food)) {
          food_selected.update(
              food, (int val) => 1 + food_selected[food].toInt());
        } else {
          food_selected.putIfAbsent(food, () => 1);
        }
      } else {
        if (!food.is_addon) {
          if (adds_on_selected.containsKey(food)) {
            adds_on_selected.update(
                food, (int val) => 1 + adds_on_selected[food].toInt());
          } else {
            adds_on_selected.putIfAbsent(food, () => 1);
          }
        }
      }
      _updateCounts();
    }
  }

  void _updateCounts() {
    int tp = 0;
    int fc = 0;
    food_selected.forEach((ShopProductModel food, int quantity) {
      fc += quantity;
      tp +=
          (int.parse(food.promotion == 0 ? food.price : food.promotion_price) *
              quantity);
    });
    int adc = 0;
    adds_on_selected.forEach((ShopProductModel food, int quantity) {
      adc += quantity;
      tp +=
          (int.parse(food.promotion == 0 ? food.price : food.promotion_price) *
              quantity);
    });
    setState(() {
      _foodCount = fc;
//      _addOnCount = adc;
      totalPrice = tp;
    });
  }

  void showToast(String message) {
    Toast.show(message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  void _removeFood(ShopProductModel food) {
    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        food_selected.removeWhere((ShopProductModel mFood, int value) {
          return (mFood == food);
        });
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          adds_on_selected.removeWhere((ShopProductModel mFood, int value) {
            return (mFood == food);
          });
        }
      }
    }
    _updateCounts();
  }

  void _continuePurchase() {
    /* data */
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage2(restaurant: widget.restaurant,presenter: OrderConfirmationPresenter(), foods: food_selected, addons: adds_on_selected),
      ),
    );*/

    if (StateContainer.of(context).loggingState == 0) {
      // not logged in... show dialog and also go there
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "${AppLocalizations.of(context).translate('please_login_before_going_forward_title')}"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  /* add an image*/
                  // location_permission
                  Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          image: new DecorationImage(
                            fit: BoxFit.fitHeight,
                            image:
                                new AssetImage(ImageAssets.login_description),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate("please_login_before_going_forward_description_place_order")}",
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                    "${AppLocalizations.of(context).translate('not_now')}"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text("${AppLocalizations.of(context).translate('login')}"),
                onPressed: () {
                  /* */
                  /* jump to login page... */
                  Navigator.of(context).pop();

                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage(
                          presenter: LoginPresenter(),
                          fromOrderingProcess: true)));
                },
              )
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OrderConfirmationPage2(
                  restaurant: widget.restaurant,
                  presenter: OrderConfirmationPresenter(),
                  foods: food_selected,
                  addons: adds_on_selected),
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
  }

  _jumpToFoodDetails(BuildContext context, ShopProductModel food) {
    food.restaurant_entity = widget.restaurant;
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

}
