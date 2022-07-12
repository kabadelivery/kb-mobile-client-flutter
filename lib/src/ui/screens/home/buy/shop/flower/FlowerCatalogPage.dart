import 'dart:async';
import 'dart:math';

import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/FlowerWidgetItem.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

class FlowerCatalogPage extends StatefulWidget {
  static var routeName = "/FlowerCatalogPage";

  ShopModel restaurant;

  MenuPresenter presenter;

  int menuId;

  bool fromNotification;

  int highlightedFoodId;

  int foodId;

  FlowerCatalogPage(
      {Key key,
      this.presenter,
      this.restaurant = null,
      this.menuId = -1,
      this.foodId = -1,
      this.highlightedFoodId = -1,
      this.fromNotification = false})
      : super(key: key);

  @override
  _FlowerCatalogPageState createState() => _FlowerCatalogPageState();
}

class _FlowerCatalogPageState extends State<FlowerCatalogPage>
    with TickerProviderStateMixin
    implements MenuView {
  var _firstTime = true;

  /* app config */
  GlobalKey _menuBasketKey;
  Offset _menuBasketOffset;

  final dataKey = new GlobalKey();

  /* add data */
  List<RestaurantSubMenuModel> data;

  // int currentIndex = 0;

  int _foodCount = 0, _addOnCount = 0;
  int FOOD_MAX = 5, ADD_ON_COUNT = 10;

  int ALL = 3, FOOD = 1, ADDONS = 2;

  AnimationController _controller;

  /* selected foods */
  Map<ShopProductModel, int> food_selected = Map();
  Map<ShopProductModel, int> adds_on_selected = Map();

//  List<Widget> _dynamicAnimatedFood;
//  List<AnimationController> _animationController;

  /* create a presenter for menu page */

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  Map<String, GlobalKey> _keyBox = Map();

  Animation foodAddAnimation;

  var _menuChipCurrentIndex = 0;

  List<String> _menuChoices = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeBasketOffset());
    super.initState();
    _menuBasketKey = GlobalKey();
    widget.presenter.menuView = this;

    if (!widget.fromNotification) {
//      if (widget.menuId == -1)
//        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
//      else {
//        /* be able to fetch menu with food_id, and highlight the food with some interesting color. */
//        widget.presenter.fetchMenuWithMenuId(widget.menuId);
//      }

      if (widget.menuId != -1) {
        widget.presenter.fetchMenuWithMenuId(widget?.menuId);
      } else if (widget.foodId != -1) {
        widget.presenter.fetchMenuWithFoodId(widget?.foodId);
      } else {
        widget.presenter.fetchMenuWithRestaurantId(widget?.restaurant?.id);
      }
    }

    // TODO when we open menu with a food id, or menu id, we should set it at the top, and maybe highlight the choosen item

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
//    foodAddAnimation = Tween(begin: 1.5, end: 1.0).animate(_controller);
    foodAddAnimation = Tween(begin: 0.0, end: 2 * pi).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fromNotification) {
      final int args = ModalRoute.of(context).settings.arguments;
      if (args != null && args != 0) {
        if (args < 0) {
          widget.foodId = -1 * args;
          widget.highlightedFoodId = widget.foodId;
          widget.presenter.fetchMenuWithFoodId(widget.foodId);
        } else {
          widget.menuId = args;
          widget.presenter.fetchMenuWithMenuId(widget.menuId);
        }
      }
    }

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
            child: Text(
                widget?.restaurant == null ? "" : widget?.restaurant?.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.white)))
      ])),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          }),
      actions: <Widget>[
        Row(
          children: <Widget>[
            RotatedBox(
                child: AnimatedBuilder(
                  animation: foodAddAnimation,
                  child: Text("${_foodCount}/${FOOD_MAX}",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  builder: (BuildContext context, Widget child) {
                    return Transform.rotate(
                        angle: foodAddAnimation.value, child: child);
                  },
                ),
                quarterTurns: 0),
            BouncingWidget(
              duration: Duration(milliseconds: 500),
              scaleFactor: 3,
              child: IconButton(
                  key: _menuBasketKey,
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () => _showMenuBottomSheet(ALL)),
            ),
          ],
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
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
                                SizedBox(height: 5),
                                ChipList(
                                  style: TextStyle(fontSize: 12),
                                  listOfChipNames: _menuChoices,
                                  activeBgColorList: [
                                    Theme.of(context).primaryColor
                                  ],
                                  inactiveBgColorList: [
                                    KColors.primaryColor.withOpacity(0.2)
                                  ],
                                  activeTextColorList: [Colors.white],
                                  inactiveTextColorList: [
                                    Colors.black.withOpacity(0.7)
                                  ],
                                  listOfChipIndicesCurrentlySeclected: [
                                    _menuChipCurrentIndex
                                  ],
                                  extraOnToggle: (val) {
                                    _menuChipCurrentIndex = val;
                                    setState(() {});
                                  },
                                ),
                              ] /*..addAll(List.generate(data?.length, (index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  this.currentIndex = index;
                                                });
                                              },
                                              child: index == this.currentIndex
                                                  ? Container(
                                                      color: KColors
                                                          .primaryColor,
                                                      padding: EdgeInsets.only(
                                                          top: 10,
                                                          bottom: 10,
                                                          left: 8,
                                                          right: 8),
                                                      child: Text(data[index]?.name?.toUpperCase(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .white),
                                                          textAlign: TextAlign
                                                              .center))
                                                  : Container(
                                                      color: data[index]?.promotion != 0
                                                          ? KColors
                                                              .primaryYellowColor
                                                          : Colors
                                                              .transparent,
                                                      padding:
                                                          EdgeInsets.only(
                                                              top: 10,
                                                              bottom: 10,
                                                              left: 8,
                                                              right: 8),
                                                      child: Text(data[index]?.name?.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: data[index]?.promotion == 0 ? Colors.black : KColors.primaryColor), textAlign: TextAlign.center))),
                                        ),
                                      ),
                                    ],
                                  );
                                }))*/
                              ,
                            ),
                          ),
                          isLoading
                              ? Center(child: MyLoadingProgressWidget())
                              : (hasNetworkError
                                  ? ErrorPage(
                                      message:
                                          "${AppLocalizations.of(context).translate('network_error')}",
                                      onClickAction: () {
                                        if (!widget.fromNotification) {
                                          if (widget.menuId == -1)
                                            widget.presenter
                                                .fetchMenuWithRestaurantId(
                                                    widget.restaurant.id);
                                          else
                                            widget.presenter
                                                .fetchMenuWithMenuId(
                                                    widget.menuId);
                                        } else
                                          restaurantBloc
                                              .fetchRestaurantMenuList(
                                                  widget?.restaurant);
                                      })
                                  : hasSystemError
                                      ? ErrorPage(
                                          message:
                                              "${AppLocalizations.of(context).translate('system_error')}",
                                          onClickAction: () {
                                            if (!widget.fromNotification) {
                                              if (widget.menuId == -1)
                                                widget.presenter
                                                    .fetchMenuWithRestaurantId(
                                                        widget.restaurant.id);
                                              else
                                                widget.presenter
                                                    .fetchMenuWithMenuId(
                                                        widget.menuId);
                                            } else
                                              restaurantBloc
                                                  .fetchRestaurantMenuList(
                                                      widget?.restaurant);
                                          })
                                      : _buildFlowerCatalog()),
                        ]))),
    );
  }

  _computeBasketOffset() {
    final RenderBox renderBox =
        _menuBasketKey.currentContext.findRenderObject();
    _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
  }

  _buildFlowerCatalog() {
    if (hasSystemError || hasNetworkError) {
      return Container();
    }

    if (data == null || data?.length == 0)
      return Center(
          child: Text("${AppLocalizations.of(context).translate('no_data')}"));

    if (_firstTime) {
//      _openDrawer();
      _firstTime = false;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
          this?.data = data;
        }));

    /*return SingleChildScrollView(
      child: Column(
          children: <Widget>[SizedBox(height: 5)]
            ..addAll(List.generate(data[_menuChipCurrentIndex]?.foods?.length, (index) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildFoodListWidget2(
                      food: data[_menuChipCurrentIndex]?.foods[index],
                      foodIndex: index,
                      menuIndex: _menuChipCurrentIndex,
                      highlightedFoodId: widget.highlightedFoodId),
                ],
              );
            }))),
    );*/

    // return Text("Kodjo");

    return Expanded(
      child: GridView.builder(
        itemCount: data[_menuChipCurrentIndex]?.foods?.length,
        itemBuilder: (context, index) => FlowerWidgetItem(
            dataKey: dataKey,
            jumpToFoodDetails: _jumpToFoodDetails,
            showDetails: _showDetails,
            addFoodToChart: _addFoodToChart,
            food: data[_menuChipCurrentIndex]?.foods[index],
            foodIndex: index,
            menuIndex: _menuChipCurrentIndex,
            highlightedFoodId: widget.highlightedFoodId),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.70,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
      ),
    );
  }

  _jumpToFoodDetails(BuildContext context, ShopProductModel food) {
    food.restaurant_entity = widget.restaurant;
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: food),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantFoodDetailsPage(food: food),
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

  /* add food to chart */
  _addFoodToChart(ShopProductModel food, int foodIndex, int menuIndex) {
//    Toast.show("ok ${food.toString()}", context);

//    GlobalKey gk = _keyBox["${menuIndex}-${foodIndex}"];
//    RenderBox renderBoxRed = gk.currentContext.findRenderObject();
//    final position = renderBoxRed.localToGlobal(Offset.zero);
//    print("POSITION of Red: $position ");

    if (_foodCount < FOOD_MAX) {
      if (food_selected.containsKey(food))
        setState(() {
          food_selected.update(
              food, (int val) => 1 + food_selected[food].toInt());
        });
      else {
        setState(() {
          food_selected.putIfAbsent(food, () => 1);
        });
      }
    } else {
      showToast("${AppLocalizations.of(context).translate('max_reached')}");
    }
    _updateCounts();
  }

  void _updateCounts() {
    int fc = 0;
    food_selected.forEach((ShopProductModel food, int quantity) {
      fc += quantity;
    });
    int adc = 0;
    adds_on_selected.forEach((ShopProductModel food, int quantity) {
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
    } on TickerCanceled {}
  }

  void showSnack(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showToast(String message) {
    Toast.show(message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  int _getQuantity(ShopProductModel food) {
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
    /* await Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            FlowerCatalogDetails(
                restaurant: widget.restaurant,
                FOOD_MAX: FOOD_MAX,
                type: type,
                food_selected: food_selected,
                adds_on_selected: adds_on_selected),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));*/

    /*  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlowerCatalogDetails(
            restaurant: widget.restaurant,
            FOOD_MAX: FOOD_MAX,
            type: type,
            food_selected: food_selected,
            adds_on_selected: adds_on_selected),
      ),
    );*/
    _updateCounts();
  }

  void _launchAddToBasketAnimation(Offset position, ShopProductModel food) {
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
  void inflateMenu(ShopModel restaurant, List<RestaurantSubMenuModel> data) {
    setState(() {
      _menuChoices = [];
      data.forEach((element) {
        _menuChoices.add(Utils.capitalize(element.name));
      });

      if (restaurant.max_food != null || int.parse(restaurant.max_food) > 0)
        FOOD_MAX = int.parse(restaurant.max_food);
      widget.restaurant = restaurant;
      /* make sure, the menu_id is selected. */
      this.data = data;

      _menuChipCurrentIndex = this.data.indexWhere((subMenu) {
        if (subMenu?.id == widget.menuId) return true;
        return false;
      });
      if (_menuChipCurrentIndex < 0 ||
          _menuChipCurrentIndex > this.data.length) {
        _menuChipCurrentIndex = 0;
      }
    });
    showLoading(false);
    // two seconds after, we jump
    Future.delayed(Duration(seconds: 1), () {
      Scrollable.ensureVisible(dataKey.currentContext);
    });
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
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          /*  if (widget.menuId == -1)
        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter.fetchMenuWithMenuId(widget.menuId);
*/
          if (widget.menuId != -1) {
            widget.presenter.fetchMenuWithMenuId(widget?.menuId);
          } else if (widget.foodId != -1) {
            widget.presenter.fetchMenuWithFoodId(widget?.foodId);
          } else {
            widget.presenter.fetchMenuWithRestaurantId(widget?.restaurant?.id);
          }
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          /*   if (widget.menuId == -1)
        widget.presenter.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter.fetchMenuWithMenuId(widget.menuId);*/

          if (widget.menuId != -1) {
            widget.presenter.fetchMenuWithMenuId(widget?.menuId);
          } else if (widget.foodId != -1) {
            widget.presenter.fetchMenuWithFoodId(widget?.foodId);
          } else {
            widget.presenter.fetchMenuWithRestaurantId(widget?.restaurant?.id);
          }
        });
  }

  @override
  void highLightFood(int menuId, int foodId) {
    widget.menuId = menuId;
    widget.highlightedFoodId = foodId;
  }

  _showDetails(ShopProductModel food) {
    mDialog(food?.description);
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
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
                  style: TextStyle(color: Colors.black, fontSize: 13))
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

  CustomAnimatedPosition(
      {this.context,
      this.right,
      this.bottom,
      this.left,
      this.top,
      this.duration,
      this.child})
      : super(
            child: child,
            right: right,
            bottom: bottom,
            left: left,
            top: top,
            duration: duration);

  bool isAdded = false;

  addToBasket() {
    isAdded = true;
    if (isAdded) {
      this.left = MediaQuery.of(context).size.width - 100;
      this.top = 40;
    }
  }
}
