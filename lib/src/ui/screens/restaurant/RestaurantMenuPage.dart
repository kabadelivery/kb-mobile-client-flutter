import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/blocs/RestaurantBloc.dart';
import 'package:kaba_flutter/src/contracts/menu_contract.dart';
import 'package:kaba_flutter/src/locale/locale.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/MessagePage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantMenuDetails.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantFoodListWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
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

//  final _controllers = <AnimationController>[];

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<
      InnerDrawerState>();

  var _firstTime = true;

  /* app config */
  GlobalKey _menuBasketKey;
  Offset _menuBasketOffset;

  /* add data */
  List<RestaurantSubMenuModel> data;
  int currentIndex = 0;

  int _foodCount = 0,
      _addOnCount = 0;
  int FOOD_MAX = 30,
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
      backgroundColor: KColors.primaryColor,
      title: GestureDetector(child: Row(children: <Widget>[
        Text("MENU", style: TextStyle(fontSize: 14, color: Colors.white)),
        SizedBox(width: 10),
        Expanded(
          child: Container(decoration: BoxDecoration(color: Colors.white.withAlpha(100),
              borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Text(widget.restaurant == null ? "" : widget.restaurant.name, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.white))),
        )
      ]), onTap: _openDrawer),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
        Navigator.pop(context);
      }),
      actions: <Widget>[
        IconButton(key: _menuBasketKey,
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => _showMenuBottomSheet(ALL))
      ],
    );

    return InnerDrawer(
        key: _innerDrawerKey,
//        position: InnerDrawerPosition.start, // required
//        onTapClose: true, // default false
//        offset: 0.1, // default 0.4
//        animationType: InnerDrawerAnimation.quadratic, // default static
//        innerDrawerCallback: (a) => print(a), // return bool
        leftChild: data?.length == null ? Container() : Material(
            child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(child: Padding(padding: EdgeInsets.all(10),child: Text("Veuillez selectionner le menu de votre choix", style: TextStyle(color: Colors.grey, fontSize: 14),textAlign: TextAlign.center,))),
                        ],
                      ),
                      SizedBox(height: 5),
                      /*  ListView.separated(
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.withAlpha(150), height: 1),
                          itemCount: data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _innerDrawerKey.currentState.toggle();
                                    this.currentIndex = index;
                                  });
                                },
                                child: index == this.currentIndex ?
                                Container(
                                    color: KColors.primaryColor,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 8, right: 8),
                                    child: Text(data[index].name?.toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white),
                                        textAlign: TextAlign.center)) :
                                Container(
                                    color: data[index].promotion != 0 ? KColors
                                        .primaryYellowColor : Colors.transparent,
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 8, right: 8),
                                    child: Text(data[index].name?.toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: data[index].promotion == 0 ? Colors
                                                .black : KColors.primaryColor),
                                        textAlign: TextAlign.center)));
                          }),*/
                    ]..addAll(
                        List.generate(data?.length, (index){
                          return Row(mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _innerDrawerKey.currentState.toggle();
                                      this.currentIndex = index;
                                    });
                                  },
                                  child: index == this.currentIndex ?
                                  Container(
                                      color: KColors.primaryColor,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 8, right: 8),
                                      child: Text(data[index].name?.toUpperCase(),
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white),
                                          textAlign: TextAlign.center)) :
                                  Container(
                                      color: data[index].promotion != 0 ? KColors
                                          .primaryYellowColor : Colors.transparent,
                                      padding: EdgeInsets.only(
                                          top: 10, bottom: 10, left: 8, right: 8),
                                      child: Text(data[index].name?.toUpperCase(),
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: data[index].promotion == 0 ? Colors
                                                  .black : KColors.primaryColor),
                                          textAlign: TextAlign.center))),
                            ],
                          );
                        })
                    ),
                  ),
                )
            )
        ),
        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Scaffold(
                  appBar: appBar,
                  body: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : (hasNetworkError ? ErrorPage(
                            message: "hasNetworkError", onClickAction: () {
                          restaurantBloc.fetchRestaurantMenuList(
                              widget.restaurant);
                        })
                            : hasSystemError ? ErrorPage(
                            message: "hasSystemError", onClickAction: () {
                          restaurantBloc.fetchRestaurantMenuList(
                              widget.restaurant);
                        }) : _buildRestaurantMenu()),
                        Positioned(
                          right: 15,
                          top: 10,
                          child: Column(children: <Widget>[
                            SizedBox(height: 10),
                            RotatedBox(child: FlatButton.icon(onPressed: () {
                              _showMenuBottomSheet(1);
                            },
                                icon: Icon(Icons.fastfood, color: Colors.white),
                                label: Row(
                                  children: <Widget>[
                                    Text("REPAS",
                                        style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 5),
                                    RotatedBox(
                                        child:
                                        AnimatedBuilder(
                                          animation: foodAddAnimation,
                                          child: Text("${_foodCount}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18)),
                                          builder: (BuildContext context, Widget child) {
                                            return Transform.rotate(angle: foodAddAnimation.value, child: child);
                                          },
                                        ),
                                        quarterTurns: 1)
                                  ],
                                ),
                                color: KColors.primaryYellowColor,
                                splashColor: KColors.primaryYellowColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                              quarterTurns: -1,
                            ),
                            /*SizedBox(height: 10),
                            RotatedBox(child: FlatButton.icon(onPressed: () {
                              _showMenuBottomSheet(2);
                            },
                                icon: Icon(Icons.fastfood, color: Colors.white),
                                label: Row(
                                  children: <Widget>[
                                    Text("SUPP.",
                                        style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 5),
                                    RotatedBox(
                                      child: Text("${_addOnCount}",
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 18)),
                                      quarterTurns: 1,
                                    )
                                  ],
                                ),
                                color: Colors.blue,
                                splashColor: KColors.primaryYellowColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                              quarterTurns: -1,
                            ),*/
                          ]),
                        ),
                        /* list of views that i create and remove programmatically. */
                      ]
                  ),
                ),
                /* ajouter dynamiquemnt des vues qui s'animeront uniquement sur la duree de leur vie. */
//                _dynamicAnimatedFood == null || _dynamicAnimatedFood?.length == 0 ? Container() : Stack(children: _dynamicAnimatedFood)
              ],
            ),
            floatingActionButton: this.data != null ? RotatedBox(
              child: FlatButton.icon(onPressed: () {
                _openDrawer();
              },
                  icon: Icon(Icons.fastfood, color: Colors.white),
                  label: Text("MENU", style: TextStyle(color: Colors.white)),
                  color: KColors.primaryColor,
                  splashColor: KColors.primaryYellowColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius
                      .circular(20))),
              quarterTurns: -1,
            ) : Container()
        )
    );
  }

  void _openDrawer() {
    if (_innerDrawerKey.currentState != null)
      _innerDrawerKey.currentState.open();
  }

  void _closeDrawer() {
    if (_innerDrawerKey.currentState != null)
      _innerDrawerKey.currentState.close();
  }

  Widget getRow(int i) {
    return new GestureDetector(
      child: new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//        color: index == i ? YColors.color_F9F9F9 : Colors.white,
        color: Colors.white,
        child: new Text("text $i",
            style: TextStyle(
                color: Colors.black,
//                color: index == i ? textColor : YColors.color_666,
//                fontWeight: index == i ? FontWeight.w600 : FontWeight.w400,
                fontSize: 16)),
      ),
      onTap: () {
        setState(() {
//          index = i; //记录选中的下标
//          textColor = YColors.colorPrimary;
        });
      },
    );
  }

  _computeBasketOffset() {
    final RenderBox renderBox = _menuBasketKey.currentContext
        .findRenderObject();
    _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
  }

  _buildRestaurantMenu() {

    if (data == null || data.length == 0)
      return Center(child:Text("No data"));

    if (_firstTime) {
      _openDrawer();
      _firstTime = false;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        setState(() {
          this.data = data;
        }));

    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      child: SingleChildScrollView(
        child:
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: data[currentIndex].foods.length,
          itemBuilder: (BuildContext context, int index) {
            /* create the key*/
//            _keyBox["${currentIndex}-${index}"] = GlobalKey();
            _keyBox.putIfAbsent("${currentIndex}-${index}", () => GlobalKey());

//          return RestaurantFoodListWidget(basket_offset: _menuBasketOffset, food: data[currentIndex].foods[index]);
            return _buildFoodListWidget(food: data[currentIndex].foods[index], foodIndex: index, menuIndex: currentIndex);
          },
          key: new Key(new DateTime.now().toIso8601String()),
        ),
      ),
    );
  }

  /* build food list widget */
  Widget _buildFoodListWidget({RestaurantFoodModel food, int foodIndex, int menuIndex}) {
    return Card(
        elevation: 2.0,
        margin: EdgeInsets.only(left: 10, right: 70, top: 4, bottom: 4),
        child: InkWell(
            child: Container(
              child: ListTile(
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

                          Text("FCFA", overflow: TextOverflow.ellipsis,
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
                trailing: InkWell(
                  child: Container(width: 50,
                      height: 50,
//                      color: Colors.grey.withAlpha(80),
                      padding: EdgeInsets.all(2),
                      child:
                      Icon(Icons.add_shopping_cart, color: KColors.primaryColor)
                  ),
                  onTap: () {
                    _addFoodToChart(food, foodIndex, menuIndex);
                  },
                ),
              ),
            )
            , onTap: () => _jumpToFoodDetails(context, food))
    );
  }

  _jumpToFoodDetails(BuildContext context, RestaurantFoodModel food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage(food: food),
      ),
    );
  }

  /* add food to chart */
  _addFoodToChart(RestaurantFoodModel food, int foodIndex, int menuIndex) {

    GlobalKey gk = _keyBox["${menuIndex}-${foodIndex}"];
    RenderBox renderBoxRed = gk.currentContext.findRenderObject();
    final position = renderBoxRed.localToGlobal(Offset.zero);
    print("POSITION of Red: $position ");

    if (!food.is_addon) {
      if (food_selected.containsKey(food)) {
        if (_foodCount < FOOD_MAX) {
          _launchAddToBasketAnimation(position, food);
          setState(() {
            food_selected.update(
                food, (int val) => 1 + food_selected[food].toInt());
          });
        }
        else {
          showToast("MAX REACHEAD");
        }
      } else {
        _launchAddToBasketAnimation(position, food);
        setState(() {
          food_selected.putIfAbsent(food, () => 1);
        });
      }
    } else {
      if (!food.is_addon) {
        if (adds_on_selected.containsKey(food)) {
          if (_addOnCount < ADD_ON_COUNT) {
            _launchAddToBasketAnimation(position, food);
            setState(() {
              adds_on_selected.update(
                  food, (int val) => 1 + adds_on_selected[food].toInt());
            });
          }
          else {
            showToast("MAX REACHEAD");
          }
        } else {
          _launchAddToBasketAnimation(position, food);
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
        builder: (context) => RestaurantMenuDetails(type: type,
            food_selected: food_selected,
            adds_on_selected: adds_on_selected),
      ),
    );
    _updateCounts();
  }

  /*void _launchAddToBasketAnimation(RestaurantFoodModel food) {
    var animationController = _createAnimationController();
    _animationController.add(animationController);
    _dynamicAnimatedFood.add(_createAnimatedFoodWidgetToDrop(food, animationController));
  }*/

  void _launchAddToBasketAnimation(Offset position, RestaurantFoodModel food) {

    return;
    /* var vView = CustomAnimatedPosition(
      context: context,
      left: position.dx,
      top: position.dy,
      duration: Duration(seconds: 10),
      child: Container(
          height: 50, width: 50,
          decoration: BoxDecoration(
              border: new Border.all(
                  color: KColors.primaryYellowColor, width: 2),
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
              )
          )),
    );*/


    /*Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        vView.addToBasket();

      });
    });*/

    var _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    var _offsetAnimation = Tween<Offset>(
      begin: position,
//      end: Offset(MediaQuery.of(context).size.width-100, 40),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));

    var vView = SlideTransition(
      position: _offsetAnimation,
      child: Container(
          height: 50, width: 50,
          decoration: BoxDecoration(
              border: new Border.all(
                  color: KColors.primaryYellowColor, width: 2),
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
              )
          )),
    );

//    _dynamicAnimatedFood.add(vView);
  }

  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  @override
  void inflateMenu(RestaurantModel restaurant, List<RestaurantSubMenuModel> data) {
    setState(() {
      widget.restaurant = restaurant;
      this.data = data;
    });
    showLoading(false);
  }

  @override
  void networkError() {
    showLoading(false);
  }

  @override
  void systemError() {
    showLoading(false);
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


//  static CustomAnimatedPosition of(BuildContext context, AnimatedPositioned aspect) {
//    return InheritedModel.inheritFrom<CustomAnimatedPosition>(context, aspect: aspect);
//  }

//  ABModel({ this.a, this.b, Widget child }) : super(child: child);

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