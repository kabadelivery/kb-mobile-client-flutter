import 'dart:async';
import 'dart:math';

import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/RestaurantSubMenuModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuDetails.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:toast/toast.dart';

class RestaurantMenuPage extends StatefulWidget {

  static var routeName = "/RestaurantMenuPage";

  RestaurantModel restaurant;

  MenuPresenter presenter;

  int menuId;

  bool fromNotification;

  RestaurantMenuPage({Key key, this.presenter, this.restaurant = null, this.menuId = -1, this.fromNotification=false}) : super(key: key);

  @override
  _RestaurantMenuPageState createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage>  with TickerProviderStateMixin implements MenuView {

  var _firstTime = true;

  /* app config */
  GlobalKey _menuBasketKey;
  Offset _menuBasketOffset;

  /* add data */
  List<RestaurantSubMenuModel> data;
  int currentIndex = 0;

  int _foodCount = 0,
      _addOnCount = 0;
  int FOOD_MAX = 5,
      ADD_ON_COUNT = 10;

  int ALL = 3,
      FOOD = 1,
      ADDONS = 2;

  AnimationController _controller;

  /* selected foods */
  Map<RestaurantFoodModel, int> food_selected = Map();
  Map<RestaurantFoodModel, int> adds_on_selected = Map();

//  List<Widget> _dynamicAnimatedFood;
//  List<AnimationController> _animationController;

  /* create a presenter for menu page */

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  Map<String, GlobalKey> _keyBox = Map();

  Animation foodAddAnimation;


  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _computeBasketOffset());
    super.initState();
    _menuBasketKey = GlobalKey();
    widget.presenter.menuView = this;

    if (!widget.fromNotification) {
      if (widget.menuId == -1)
        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter.fetchMenuWithMenuId(widget.menuId);
    }

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 700));
//    foodAddAnimation = Tween(begin: 1.5, end: 1.0).animate(_controller);
    foodAddAnimation = Tween(begin: 0.0, end: 2*pi).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {

    if (widget.fromNotification) {
      final int args = ModalRoute.of(context).settings.arguments;
      if (args != null && args != 0)
        widget.menuId = args;
      widget.presenter.fetchMenuWithMenuId(widget.menuId);
    }

    var appBar = AppBar(
      brightness: Brightness.dark,
      backgroundColor: KColors.primaryColor,
      title: GestureDetector(child: Row(children: <Widget>[
        Text("${AppLocalizations.of(context).translate('menu')}", style: TextStyle(fontSize: 14, color: Colors.white)),
        SizedBox(width: 10),
        Expanded(
          child: Container(decoration: BoxDecoration(color: Colors.white.withAlpha(100),
              borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Text(widget?.restaurant == null ? "" : widget?.restaurant?.name, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.white))),
        )
      ])),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
        Navigator.pop(context);
      }),
      actions: <Widget>[
        Row(
          children: <Widget>[
            RotatedBox(
                child:
                AnimatedBuilder(
                  animation: foodAddAnimation,
                  child: Text("${_foodCount}/${FOOD_MAX}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18)),
                  builder: (BuildContext context, Widget child) {
                    return Transform.rotate(angle: foodAddAnimation.value, child: child);
                  },
                ),
                quarterTurns: 0),
            IconButton(key: _menuBasketKey,
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => _showMenuBottomSheet(ALL)),
          ],
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
          child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
          Row(children: <Widget>[
            Expanded(flex:4,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 5),
                    ]..addAll(
                        List.generate(data?.length, (index){
                          return Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          this.currentIndex = index;
                                        });
                                      },
                                      child: index == this.currentIndex ?
                                      Container(
                                          color: KColors.primaryColor,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 8, right: 8),
                                          child: Text(data[index]?.name?.toUpperCase(),
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white),
                                              textAlign: TextAlign.center)) :
                                      Container(
                                          color: data[index]?.promotion != 0 ? KColors
                                              .primaryYellowColor : Colors.transparent,
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 8, right: 8),
                                          child: Text(data[index]?.name?.toUpperCase(),
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: data[index]?.promotion == 0 ? Colors
                                                      .black : KColors.primaryColor),
                                              textAlign: TextAlign.center))),
                                ),
                              ),
                            ],
                          );
                        })
                    ),
                  ),
                ),
              ),
            ),
            Expanded(flex: 8, child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : (hasNetworkError ? ErrorPage(
                message: "${AppLocalizations.of(context).translate('network_error')}", onClickAction: () {
              if (!widget.fromNotification) {
                if (widget.menuId == -1)
                  widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
                else
                  widget.presenter.fetchMenuWithMenuId(widget.menuId);
              } else
                restaurantBloc.fetchRestaurantMenuList(
                    widget?.restaurant);
            })
                : hasSystemError ? ErrorPage(
                message: "${AppLocalizations.of(context).translate('system_error')}", onClickAction: () {
              if (!widget.fromNotification) {
                if (widget.menuId == -1)
                  widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
                else
                  widget.presenter.fetchMenuWithMenuId(widget.menuId);
              } else
                restaurantBloc.fetchRestaurantMenuList(
                    widget?.restaurant);
            }) : _buildRestaurantMenu())),
          ])
          )
      ),
    );
  }



  _computeBasketOffset() {
    final RenderBox renderBox = _menuBasketKey.currentContext
        .findRenderObject();
    _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
  }

  _buildRestaurantMenu() {

    if (hasSystemError || hasNetworkError){
      return Container();
    }

    if (data == null || data?.length == 0)
      return Center(child:Text("${AppLocalizations.of(context).translate('no_data')}"));

    if (_firstTime) {
//      _openDrawer();
      _firstTime = false;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        setState(() {
          this?.data = data;
        }));

    return SingleChildScrollView(
      child: Column(children: <Widget>[SizedBox(height: 5)]..addAll(
          List.generate(data[currentIndex]?.foods?.length, (index){
            return Row(mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _buildFoodListWidget2(food: data[currentIndex]?.foods[index], foodIndex: index, menuIndex: currentIndex),
              ],
            );
          })
      )),
    );
  }

  /* build food list widget */
  Widget _buildFoodListWidget({RestaurantFoodModel food, int foodIndex, int menuIndex}) {
    return InkWell(
      onTap: () => _jumpToFoodDetails(context, food),
      child: Card(
          elevation: 2.0,
          margin: EdgeInsets.only(left: 10, right: 70, top: 4, bottom: 4),
          child: Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.only(
                      top: 10, bottom: 10, left: 10),
                  leading: Stack(
                    overflow: Overflow.visible,
//                        _keyBox.keys.firstWhere(
//                        (k) => curr[k] == "${menuIndex}-${foodIndex}", orElse: () => null);
                    key: _keyBox["${menuIndex}-${foodIndex}"],
                    /* according to the position of the view, menu - food, we have a key that we store. */
                    children: <Widget>[
                      Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: KColors.primaryYellowColor,
                                width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(Utils
                                    .inflateLink(food.pic))
                            )
                        ),
                      ),
                    ],
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${food?.name?.toUpperCase()}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Row(children: <Widget>[
                            /* Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                                      (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                                          : Container()),
                                      */

                            Text("${food?.price}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    decoration: food.promotion != 0
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: KColors.primaryYellowColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(width: 5),
                            (food.promotion != 0 ? Text(
                                "${food?.promotion_price}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: KColors.primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal))
                                : Container()),
                            SizedBox(width: 5),

                            Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: KColors.primaryYellowColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal)),
                          ]),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // add-up the buttons at the right side of it
                InkWell(onTap: () {Toast.show("${AppLocalizations.of(context).translate('add_to_chart')}", context);}, // () => _addFoodToChart(food, foodIndex, menuIndex),
                  child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Semantics(button: true,
                          child: InkWell(onTap: () => _addFoodToChart(food, foodIndex, menuIndex),
                            child: Container(child: Row(children: <Widget>[Container(height: 50, padding: EdgeInsets.all(2),
                                child: Icon(Icons.add_shopping_cart, color: KColors.primaryColor)),
                              Text("${AppLocalizations.of(context).translate('add_to_basket')}", style: TextStyle(fontSize: 14, color: KColors.primaryColor))]),
                              color: KColors.primaryColorTransparentADDTOBASKETBUTTON,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }


  Widget _buildFoodListWidget2({RestaurantFoodModel food, int foodIndex, int menuIndex}) {

    /*return Expanded(
    child: InkWell(
          onTap: ()=> _jumpToFoodDetails(context, food),
          child: Container(height: 100, color: Colors.yellow, padding: EdgeInsets.all(10),child: Text("You will go ${foodIndex} - $menuIndex", style: TextStyle(color: Colors.red, fontSize: 20),))),
  ); */

    return InkWell(  onTap: ()=> _jumpToFoodDetails(context, food),
      child: Card(
//          margin: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          child: Container(width: 7*MediaQuery.of(context).size.width/11,
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  // picture first
                  Stack(
//                        overflow: Overflow.visible,
//                        _keyBox.keys.firstWhere(
//                        (k) => curr[k] == "${menuIndex}-${foodIndex}", orElse: () => null);
                    key: _keyBox["${menuIndex}-${foodIndex}"],
                    /* according to the position of the view, menu - food, we have a key that we store. */
                    children: <Widget>[
                      Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: KColors.primaryYellowColor,
                                width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(Utils
                                    .inflateLink(food?.pic))
                            )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(padding: EdgeInsets.all(5),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text("${food?.name?.toUpperCase()}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
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
                              (food.promotion != 0 ? Text(
                                  "${food?.promotion_price}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: KColors.primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal))
                                  : Container()),
                              SizedBox(width: 5),
                              Text("${AppLocalizations.of(context).translate('currency')}", overflow: TextOverflow.ellipsis,
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
                        Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Row(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(onTap:  () => _addFoodToChart(food, foodIndex, menuIndex),
                                  child: Card(color: KColors.primaryColorTransparentADDTOBASKETBUTTON,
                                      child: Row(children: <Widget>[Container(height: 50, padding: EdgeInsets.only(left: 10, right: 10),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.add_shopping_cart, color: KColors.primaryColor),
                                              Text("${AppLocalizations.of(context).translate('basket')}", style: TextStyle(fontSize: 12, color: KColors.primaryColor)),
                                            ],
                                          )),
                                      ])
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
                // add-up the buttons at the right side of it
              ],
            ),
          )
      ),
    );
  }

  _jumpToFoodDetails(BuildContext context, RestaurantFoodModel food) {

    food.restaurant_entity = widget.restaurant;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: food),
      ),
    );
  }

  /* add food to chart */
  _addFoodToChart(RestaurantFoodModel food, int foodIndex, int menuIndex) {

//    Toast.show("ok ${food.toString()}", context);

//    GlobalKey gk = _keyBox["${menuIndex}-${foodIndex}"];
//    RenderBox renderBoxRed = gk.currentContext.findRenderObject();
//    final position = renderBoxRed.localToGlobal(Offset.zero);
//    print("POSITION of Red: $position ");

    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        if (_foodCount < FOOD_MAX) {
//          _launchAddToBasketAnimation(position, food);
          setState(() {
            food_selected.update(
                food, (int val) => 1 + food_selected[food].toInt());
          });
        }
        else {
          showToast("${AppLocalizations.of(context).translate('max_reached')}");
        }
      } else {
//        _launchAddToBasketAnimation(position, food);
        setState(() {
          food_selected.putIfAbsent(food, () => 1);
        });
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          if (_addOnCount < ADD_ON_COUNT) {
//            _launchAddToBasketAnimation(position, food);
            setState(() {
              adds_on_selected.update(
                  food, (int val) => 1 + adds_on_selected[food].toInt());
            });
          }
          else {
            showToast("${AppLocalizations.of(context).translate('max_reached')}");
          }
        } else {
//          _launchAddToBasketAnimation(position, food);
          setState(() {
            adds_on_selected.putIfAbsent(food, () => 1);
          });
        }
      }
    }
    _updateCounts();
  }

  void _updateCounts() {
    int fc = 0;
    food_selected.forEach((RestaurantFoodModel food, int quantity) {
      fc += quantity;
    });
    int adc = 0;
    adds_on_selected.forEach((RestaurantFoodModel food, int quantity) {
      adc += quantity;
    });
    setState(() {
      _foodCount = fc;
      _addOnCount = adc;
    });
    _playAnimation();
  }

  Future<Null> _playAnimation() async {
    try {

      /*  _controller.addStatusListener((AnimationStatus status){
        print(status);
        if (status == AnimationStatus.completed) {
          if (_controller.upperBound == 1.3)
            _controller.reverse(from: _controller.upperBound);
        }
      });*/

      await _controller.forward(from: 0.0).orCancel;

    } on TickerCanceled {
    }
  }

  void showSnack(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showToast(String message) {
    Toast.show(
        message, context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  int _getQuantity(RestaurantFoodModel food) {
    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        return food_selected[food].toInt();
      } else {
        return 0;
      }
    } else {
      if (adds_on_selected.containsKey(food)) {
        return adds_on_selected[food].toInt();
      } else {
        return 0;
      }
    }
  }

  _showMenuBottomSheet(int type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuDetails(
            restaurant: widget.restaurant,
            FOOD_MAX: FOOD_MAX,
            type: type,
            food_selected: food_selected,
            adds_on_selected: adds_on_selected),
      ),
    );
    _updateCounts();
  }

  void _launchAddToBasketAnimation(Offset position, RestaurantFoodModel food) {

    return;
  }

  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      hasNetworkError = false;
      hasSystemError = false;
    });
  }

  @override
  void inflateMenu(RestaurantModel restaurant, List<RestaurantSubMenuModel> data) {
    setState(() {
      if (restaurant.max_food != null || int.parse(restaurant.max_food) > 0)
        FOOD_MAX = int.parse(restaurant.max_food);
      widget.restaurant = restaurant;
      this.data = data;
    });
    showLoading(false);
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

  _buildSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){
      if (widget.menuId == -1)
        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter.fetchMenuWithMenuId(widget.menuId);
    });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){
      if (widget.menuId == -1)
        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter.fetchMenuWithMenuId(widget.menuId);
    });
  }
}


class CustomAnimatedPosition extends AnimatedPositioned {

  var child;
  double left;
  double top;
  double right;
  double bottom;
  Duration duration;
  int serial;
  var context;

  CustomAnimatedPosition({this.context, this.right, this.bottom, this.left, this.top, this.duration, this.child}) : super(
      child: child, right:right, bottom:bottom, left:left, top:top, duration:duration);

  bool isAdded = false;

  addToBasket () {
    isAdded = true;
    if (isAdded) {
      this.left = MediaQuery.of(context).size.width-100;
      this.top = 40;
    }
  }

}