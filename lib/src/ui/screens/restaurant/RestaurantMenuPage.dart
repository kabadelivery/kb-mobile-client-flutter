import 'dart:async';
import 'dart:math';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShippingFeeTag.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/flower/ShopFlowerDetailsPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuDetails.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:toast/toast.dart';

class RestaurantMenuPage extends StatefulWidget {
  static var routeName = "/RestaurantMenuPage";

  ShopModel? restaurant;

  MenuPresenter? presenter;

  int? menuId;

  bool? fromNotification;

  int? highlightedFoodId;

  int? foodId;

  CustomerModel? customer;

  RestaurantMenuPage(
      {Key? key,
      this.presenter,
      this.restaurant = null,
      this.menuId = -1,
      this.foodId = -1,
      this.customer,
      this.highlightedFoodId = -1,
      this.fromNotification = false})
      : super(key: key);

  @override
  _RestaurantMenuPageState createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage>
    with TickerProviderStateMixin
    implements MenuView {
  var _firstTime = true;

  /* app config */
  GlobalKey? _menuBasketKey;
  Offset? _menuBasketOffset;

  final dataKey = new GlobalKey();

  /* add data */
  List<RestaurantSubMenuModel>? data;
  int currentIndex = 0;

  int _foodCount = 0, _addOnCount = 0;
  int FOOD_MAX = 5, ADD_ON_COUNT = 10;

  int ALL = 3, FOOD = 1, ADDONS = 2;

  AnimationController? _controller;

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

  Animation? foodAddAnimation;

  List<String> _chipList = [];

  int MAX_CHIP_FOR_SCREEN = -1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeBasketOffset());
    super.initState();
    _menuBasketKey = GlobalKey();
    widget.presenter!.menuView = this;

    CustomerUtils.getCustomer().then((customer) {
      setState(() {
        widget.customer = customer;
      });
    });

    if (!widget.fromNotification!) {
//      if (widget.menuId == -1)
//        widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant.id);
//      else {
//        /* be able to fetch menu with food_id, and highlight the food with some interesting color. */
//        widget.presenter!.fetchMenuWithMenuId(widget.menuId);
//      }
      if (widget.menuId != -1) {
        widget.presenter!.fetchMenuWithMenuId(widget.menuId!);
      } else if (widget.foodId != -1) {
        widget.presenter!.fetchMenuWithFoodId(widget.foodId!);
      } else {
        widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant!.id!);
      }
    }

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
//    foodAddAnimation = Tween(begin: 1.5, end: 1.0).animate(_controller);
    foodAddAnimation = Tween(begin: 0.0, end: 2 * pi).animate(_controller!);
  }

  @override
  Widget build(BuildContext context) {
    if (MAX_CHIP_FOR_SCREEN < 0) {
      MAX_CHIP_FOR_SCREEN = MediaQuery.of(context).size.width ~/ 50;
    }
    if (widget.fromNotification!) {
      final int args = ModalRoute.of(context)!.settings.arguments as int;
      if (args != null && args != 0) {
        if (args < 0) {
          widget.foodId = -1 * args;
          widget.highlightedFoodId = widget.foodId;
          widget.presenter!.fetchMenuWithFoodId(widget.foodId!);
        } else {
          widget.menuId = args;
          widget.presenter!.fetchMenuWithMenuId(widget.menuId!);
        }
      }
    }

    var appBar = AppBar(
      backgroundColor: KColors.primaryColor,
      titleSpacing: 0,
      title: GestureDetector(
          onTap: () => _jumpToShopDetails(widget.restaurant!),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /*  Icon(Icons.home, color: Colors.white, size: 20),
                SizedBox(width: 10),*/
                Expanded(
                  child: Container(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 10, right: 10),
                      child: Text(
                          widget.restaurant == null
                              ? ""
                              : widget.restaurant!.name!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ),
              ])),
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          }),
      actions: <Widget>[
        GestureDetector(
          onTap: () => _showMenuBottomSheet(ALL),
          child: Row(
            children: <Widget>[
              RotatedBox(
                  child: AnimatedBuilder(
                    animation: foodAddAnimation!,
                    child: Text("${_foodCount}/${FOOD_MAX}",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                          angle: foodAddAnimation!.value, child: child);
                    },
                  ),
                  quarterTurns: 0),
              BouncingWidget(
                duration: Duration(milliseconds: 500),
                scaleFactor: 3,
                onPressed: () {  },
                child: IconButton(
                    key: _menuBasketKey,
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => _showMenuBottomSheet(ALL)),
              ),
            ],
          ),
        )
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            collapsedHeight: 120,
                            leading: null,
                            automaticallyImplyLeading: false,
                            elevation: -10,
                            expandedHeight: 120,
                            backgroundColor: Colors.white,
                            flexibleSpace: SingleChildScrollView(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  height: 120,
                                  child: Column(
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            flex: 8,
                                            child: Text(
                                                "${widget.restaurant?.name == null ? '' : widget.restaurant?.name}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: KColors.new_black,
                                                    fontSize: 15))),
                                        Expanded(flex: 2, child: Container()),
                                        _getRestaurantStateTag(
                                            widget.restaurant)
                                      ]),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(children: [
                                        Icon(
                                          Icons.location_on,
                                          color: KColors.mBlue,
                                          size: 15,
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Text(
                                              "${widget.restaurant?.address == null ? '' : widget.restaurant?.address}",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        )
                                      ]),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          isLoading ||
                                                  StateContainer.of(context)
                                                          .location
                                                          ?.latitude ==
                                                      null
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    widget.restaurant
                                                                ?.distance ==
                                                            null
                                                        ? Container()
                                                        : Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                                color: KColors
                                                                    .new_gray),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                    FontAwesomeIcons
                                                                        .locationArrow,
                                                                    color: KColors
                                                                        .mGreen,
                                                                    size: 10),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                    "${widget.restaurant?.distance} ${AppLocalizations.of(context)!.translate('km')}",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .normal,
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            ),
                                                          ),
                                                    SizedBox(width: 10),
                                                    ShippingFeeTag(widget
                                                        .restaurant!.distance),
                                                  ],
                                                ),
                                          GestureDetector(
                                              onTap: () => _jumpToShopDetails(
                                                  widget.restaurant!),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    top: 15,
                                                    bottom: 10,
                                                    right: 15),
                                                child: Text(
                                                  "${AppLocalizations.of(context)!.translate("more_details")}",
                                                  style: TextStyle(
                                                      color:
                                                          KColors.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ];
                      },
                      body: Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Container(height: 140, width: MediaQuery.of(context).size.width, color: Colors.yellow.withAlpha(20),),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, right: 10, left: 20),
                                  child: Text(
                                      "${Utils.capitalize(AppLocalizations.of(context)!.translate('our_menu'))}",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              child: ChipList(
                                /*   firstLineCount: _chipList?.length > MAX_CHIP_FOR_SCREEN &&
                                        _chipList?.length <= MAX_CHIP_FOR_SCREEN * 2
                                    ? MAX_CHIP_FOR_SCREEN
                                    : (_chipList?.length > MAX_CHIP_FOR_SCREEN * 2
                                        ? _chipList?.length ~/ 2 + 1
                                        : _chipList?.length),*/
                                mainAxisAlignment: MainAxisAlignment.start,
                                style: TextStyle(fontSize: 12),
                                listOfChipNames: _chipList,
                                activeBgColorList: [
                                  Theme.of(context).primaryColor
                                ],
                                inactiveBgColorList: [
                                  KColors.primaryColor.withOpacity(0.1)
                                ],
                                activeTextColorList: [Colors.white],
                                inactiveTextColorList: [KColors.primaryColor],
                                listOfChipIndicesCurrentlySeclected: [
                                  currentIndex
                                ],
                                extraOnToggle: (val) {
                                  this.currentIndex = val;
                                  setState(() {});
                                  /* scroll to top */
                                },
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                  key: PageStorageKey<String>(
                                      "menu_id_${currentIndex}"),
                                  child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: isLoading
                                          ? Center(
                                              child: MyLoadingProgressWidget())
                                          : (hasNetworkError
                                              ? _buildNetworkErrorPage()
                                              : hasSystemError
                                                  ? _buildSysErrorPage()
                                                  : Column(children: <Widget>[
                                                      isLoading
                                                          ? Center(
                                                              child:
                                                                  MyLoadingProgressWidget())
                                                          : (hasNetworkError
                                                              ? ErrorPage(
                                                                  message:
                                                                      "${AppLocalizations.of(context)!.translate('network_error')}",
                                                                  onClickAction:
                                                                      () {
                                                                    if (!widget
                                                                        .fromNotification!) {
                                                                      if (widget
                                                                              .menuId ==
                                                                          -1)
                                                                        widget.presenter!.fetchMenuWithRestaurantId(widget
                                                                            .restaurant
                                                                            !.id!);
                                                                      else
                                                                        widget
                                                                            .presenter
                                                                            !.fetchMenuWithMenuId(widget.menuId!);
                                                                    } else
                                                                      restaurantBloc
                                                                          .fetchRestaurantMenuList(
                                                                              widget.restaurant!);
                                                                  })
                                                              : hasSystemError
                                                                  ? ErrorPage(
                                                                      message:
                                                                          "${AppLocalizations.of(context)!.translate('system_error')}",
                                                                      onClickAction:
                                                                          () {
                                                                        if (!widget
                                                                            !.fromNotification!) {
                                                                          if (widget.menuId ==
                                                                              -1)
                                                                            widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant!.id!);
                                                                          else
                                                                            widget.presenter!.fetchMenuWithMenuId(widget.menuId!);
                                                                        } else
                                                                          restaurantBloc
                                                                              .fetchRestaurantMenuList(widget.restaurant!);
                                                                      })
                                                                  : _buildRestaurantMenu()),
                                                    ])))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _computeBasketOffset() {
    final RenderBox renderBox =
        _menuBasketKey!.currentContext!.findRenderObject() as RenderBox;
    _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
  }

  _buildRestaurantMenu() {
    if (hasSystemError || hasNetworkError) {
      return Container();
    }

    if (data == null || data?.length == 0)
      return Center(
          child: Text("${AppLocalizations.of(context)!.translate('no_data')}"));

    if (_firstTime) {
      _firstTime = false;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
          this?.data = data;
        }));

    return Column(
        children: <Widget>[SizedBox(height: 5)]
          ..addAll(List.generate(data![currentIndex].foods!.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _buildFoodListWidget3(
                    food: data![currentIndex].foods![index],
                    foodIndex: index,
                    menuIndex: currentIndex,
                    highlightedFoodId: widget.highlightedFoodId!),
              ],
            );
          }))
          ..add(SizedBox(height: 30)));
  }

  /* build food list widget */
  Widget _buildFoodListWidget(
      {ShopProductModel? food, int? foodIndex, int? menuIndex}) {
    return InkWell(
      onTap: () => _jumpToFoodDetails(context, food!),
      child: Card(
          elevation: 2.0,
          margin: EdgeInsets.only(left: 10, right: 70, top: 4, bottom: 4),
          child: Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  contentPadding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 10),
                  leading: Stack(
                    // overflow: Overflow.visible,
//                        _keyBox.keys.firstWhere(
//                        (k) => curr[k] == "${menuIndex}-${foodIndex}", orElse: () => null);
                    key: _keyBox["${menuIndex}-${foodIndex}"],
                    /* according to the position of the view, menu - food, we have a key that we store. */
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: KColors.primaryYellowColor, width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    Utils.inflateLink(food!.pic!!)))),
                      ),
                    ],
                  ),
                  title: InkWell(
                    onTap: () => _jumpToShopDetails(widget.restaurant!),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${food!.name?.toUpperCase()}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: KColors.new_black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Row(children: <Widget>[
                              /* Text("${food!.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),
                                        (food.promotion!=0 ? Text("${food!.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                                            : Container()),
                                        */

                              Text("${food!.price}",
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
                              (food.promotion != 0
                                  ? Text("${food!.promotion_price}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: KColors.primaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal))
                                  : Container()),
                              SizedBox(width: 5),
                              Text(
                                  "${AppLocalizations.of(context)!.translate('currency')}",
                                  overflow: TextOverflow.ellipsis,
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
                ),
                SizedBox(height: 20),
                // add-up the buttons at the right side of it
                InkWell(
                  onTap: () {
                    Toast.show(
                        "${AppLocalizations.of(context)!.translate('add_to_chart')}");
                  }, // () => _addFoodToChart(food, foodIndex, menuIndex),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Semantics(
                          button: true,
                          child: InkWell(
                            onTap: () =>
                                _addFoodToChart(food, foodIndex!, menuIndex!),
                            child: Container(
                              child: Row(children: <Widget>[
                                Container(
                                    height: 50,
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.add_shopping_cart,
                                        color: KColors.primaryColor)),
                                Text(
                                    "${AppLocalizations.of(context)!.translate('add_to_basket')}",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: KColors.primaryColor))
                              ]),
                              color: KColors
                                  .primaryColorTransparentADDTOBASKETBUTTON,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<Widget> _buildFoodListWidget2(
      {ShopProductModel? food,
      int? foodIndex,
      int? menuIndex,
      int? highlightedFoodId}) async {
    /*return Expanded(
    child: InkWell(
          onTap: ()=> _jumpToFoodDetails(context, food),
          child: Container(height: 100, color: Colors.yellow, padding: EdgeInsets.all(10),child: Text("You will go ${foodIndex} - $menuIndex", style: TextStyle(color: Colors.red, fontSize: 20),))),
  ); */

    return InkWell(
      onTap: () => _jumpToFoodDetails(context, food!),
      child: Card(
          key: food!.id == highlightedFoodId ? dataKey : null,
          child: Container(
            width: 7 * MediaQuery.of(context).size.width / 11,
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
            color: food!.id == highlightedFoodId
                ? Colors.yellow.withAlpha(50)
                : Colors.white,
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    bottom: -10,
                    child: IconButton(
                        icon: Icon(FontAwesomeIcons.questionCircle,
                            color: KColors.primaryColor),
                        onPressed: () => _showDetails(food!))),
                Column(
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
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: KColors.primaryYellowColor,
                                    width: 2),
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        Utils.inflateLink(food!.pic!!)))),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text("${food!.name?.toUpperCase()}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: KColors.new_black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Text("${food!.price}",
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
                                  (food.promotion != 0
                                      ? Text("${food!.promotion_price}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: KColors.primaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal))
                                      : Container()),
                                  SizedBox(width: 5),
                                  Text(
                                      "${AppLocalizations.of(context)!.translate('currency')}",
                                      overflow: TextOverflow.ellipsis,
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
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () => _addFoodToChart(
                                          food, foodIndex!, menuIndex!),
                                      child: Card(
                                          color: KColors
                                              .primaryColorTransparentADDTOBASKETBUTTON,
                                          child: Row(children: <Widget>[
                                            Container(
                                                height: 40,
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                        Icons.add_shopping_cart,
                                                        color: KColors
                                                            .primaryColor,
                                                        size: 20),
                                                    Text(
                                                        "${AppLocalizations.of(context)!.translate('basket')}",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: KColors
                                                                .primaryColor)),
                                                  ],
                                                )),
                                          ])),
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
              ],
            ),
          )),
    );
  }

  Widget _buildFoodListWidget3(
      {ShopProductModel? food,
      int? foodIndex,
      int? menuIndex,
      int? highlightedFoodId}) {
    return InkWell(
      onTap: () => _jumpToFoodDetails(context, food!),
      child: Container(
          width: MediaQuery.of(context).size.width - 20,
          margin: EdgeInsets.only(bottom: 15, left: 10, right: 10),
          key: food!.id == highlightedFoodId ? dataKey : null,
          child: Container(
            color: food!.id == highlightedFoodId
                ? Colors.yellow.withAlpha(50)
                : Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      color: food!.id == highlightedFoodId
                          ? Colors.yellow.withAlpha(50)
                          : KColors.new_gray),
                  padding: EdgeInsets.all(10),
                  height: 115,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${Utils.capitalize(food!.name!.trim())}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: KColors.new_black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 5),
                            Text(
                                "${Utils.capitalize(Utils.replaceNewLineBy(food!.description!.trim(), " / "))}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // added
                              Row(children: <Widget>[
                                Text("${food!.price}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        decoration: food.promotion != 0
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: KColors.primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(width: 3),
                                (food.promotion != 0
                                    ? Text("${food!.promotion_price}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: KColors.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                    : Container()),
                                SizedBox(width: 2),
                                Text(
                                    "${AppLocalizations.of(context)!.translate('currency')}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KColors.primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ]),

                              GestureDetector(
                                onTap: () =>
                                    _addFoodToChart(food, foodIndex!, menuIndex!),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: KColors.primaryColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(
                                      top: 5, bottom: 5, right: 8, left: 8),
                                  child: Row(children: <Widget>[
                                    Text(
                                        "${AppLocalizations.of(context)!.translate('add_to_basket')}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: KColors.primaryColor)),
                                    SizedBox(width: 5),
                                    Icon(Icons.add_shopping_cart,
                                        color: KColors.primaryColor, size: 12),
                                  ]),
                                ),
                              ),

                              // not added
                            ])
                      ]),
                )),
                Container(
                  color: KColors.new_gray,
                  child: Container(
                    height: 115,
                    width: 115,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                Utils.inflateLink(food!.pic!)))),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  _getRestaurantStateTag(ShopModel? shopModel) {
    String tagText = "-- --";
    Color tagTextColor = Colors.white;
    if(shopModel !=null){
    switch (shopModel!.open_type) {
      case 0: // closed
        tagText = "${AppLocalizations.of(context)!.translate('t_closed')}";
        tagTextColor = KColors.mBlue;
        break;
      case 1: // open
        tagText = "${AppLocalizations.of(context)!.translate('t_opened')}";
        tagTextColor = CommandStateColor.delivered;
        break;
      case 2: // paused
        tagText = "${AppLocalizations.of(context)!.translate('t_paused')}";
        tagTextColor = KColors.mBlue;
        break;
      case 3: // blocked
        tagText = "${AppLocalizations.of(context)!.translate('t_unavailable')}";
        tagTextColor = KColors.mBlue;
        break;
    }
 }
    int? coming_soon = shopModel==null?0:shopModel!.coming_soon;
    return coming_soon== 0
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: tagTextColor),
            child: Text(Utils.capitalize("${tagText}".toUpperCase()),
                style: TextStyle(color: Colors.white, fontSize: 12)))
        : Container();
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

  /* add food to chart */
  _addFoodToChart(ShopProductModel food, int foodIndex, int menuIndex) {
//    Toast.show("ok ${food.toString()}", context);

//    GlobalKey gk = _keyBox["${menuIndex}-${foodIndex}"];
//    RenderBox renderBoxRed = gk.currentContext.findRenderObject();
//    final position = renderBoxRed.localToGlobal(Offset.zero);
//    xrint("POSITION of Red: $position ");

    if (_foodCount < FOOD_MAX) {
      if (food_selected.containsKey(food))
        setState(() {
          food_selected.update(
              food, (int val) => 1 + food_selected[food]!.toInt());
        });
      else {
        setState(() {
          food_selected.putIfAbsent(food, () => 1);
        });
      }
    } else {
      showToast("${AppLocalizations.of(context)!.translate('max_reached')}");
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
        xrint(status);
        if (status == AnimationStatus.completed) {
          if (_controller.upperBound == 1.3)
            _controller.reverse(from: _controller.upperBound);
        }
      });*/

      await _controller!.forward(from: 0.0).orCancel;
    } on TickerCanceled {}
  }

  void showToast(String message) {
    Toast.show(message,
        duration: Toast.lengthLong, gravity: Toast.center);
  }

  int _getQuantity(ShopProductModel food) {
    if (!food.is_addon!) {
      if (food_selected.containsKey(food)) {
        return food_selected[food]!.toInt();
      } else {
        return 0;
      }
    } else {
      if (adds_on_selected.containsKey(food)) {
        return adds_on_selected[food]!.toInt();
      } else {
        return 0;
      }
    }
  }

  _showMenuBottomSheet(int type) async {
    await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuDetails(
                restaurant: widget.restaurant,
                FOOD_MAX: FOOD_MAX,
                type: type,
                food_selected: food_selected,
                adds_on_selected: adds_on_selected),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
              position: tween.animate(curvedAnimation), child: child);
        }));

    /*  await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuDetails(
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
      if (restaurant.max_food == null) restaurant.max_food = "5";
      if (restaurant.max_food != null || int.parse(restaurant.max_food!) > 0)
        FOOD_MAX = int.parse(restaurant.max_food!);
      widget.restaurant = restaurant;

      widget.restaurant?.distance = Utils.locationDistance(
                  StateContainer.of(context).location!, widget.restaurant!) >
              100
          ? "> 100"
          : Utils.locationDistance(
                  StateContainer.of(context).location!, widget.restaurant!)
              ?.toString();

      // according to the distance, we get the matching delivery fees
      // i dont want to make another loop
      widget.restaurant!.delivery_pricing = _getShippingPrice(
          widget.restaurant!.distance!,
          StateContainer.of(context).myBillingArray!);

      /* make sure, the menu_id is selected. */
      this.data = data;

      this.data!.forEach((element) {
        _chipList.add(element.name!);
      });

      currentIndex = this.data!.indexWhere((subMenu) {
        if (subMenu?.id == widget.menuId) return true;
        return false;
      });
      if (currentIndex < 0 || currentIndex > this.data!.length) {
        currentIndex = 0;
      }
    });
    showLoading(false);
    // two seconds after, we jump
    Future.delayed(Duration(seconds: 1), () {
      Scrollable.ensureVisible(dataKey.currentContext!,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });

    String dialogText = "";
    // "working_hour": "07:30-13:00",
    switch (restaurant?.open_type) {
      case 0: // closed
        dialogText =
            "${AppLocalizations.of(context)!.translate('t_closed_shop_long')}"
                .replaceAll("xxx", restaurant.working_hour!)
                .replaceAll("yyy", restaurant.name!)
                .replaceAll("(-)", ".");

        break;
      case 1: // open
        // tagText = "${AppLocalizations.of(context)!.translate('t_opened')}";
        break;
      case 2: // paused
        dialogText =
            "${AppLocalizations.of(context)!.translate('t_paused_shop_long')}"
                .replaceAll("xxx", restaurant.working_hour!)
                .replaceAll("yyy", restaurant.name!)
                .replaceAll("(-)", ".");
        break;
      case 3: // blocked
        dialogText =
            "${AppLocalizations.of(context)!.translate('t_unavailable_shop_long')}"
                .replaceAll("xxx", restaurant.working_hour!)
                .replaceAll("yyy", restaurant.name!)
                .replaceAll("(-)", ".");
        break;
    }
    if (dialogText != "") {
      Future.delayed(Duration(milliseconds: 600), () {
        _comingSoon(context, restaurant, dialogText);
      });
    }
  }

  void _comingSoon(BuildContext context, ShopModel shopModel, String message) {
    /* show the coming soon dialog */
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                content:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          border: new Border.all(
                              color: KColors.primaryYellowColor, width: 2),
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  Utils.inflateLink(shopModel!.pic!))))),
                  SizedBox(height: 10),
                  Text("${message}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KColors.new_black, fontSize: 13))
                ]),
                actions: <Widget>[
                  //
                  OutlinedButton(
                    child: new Text(
                        "${AppLocalizations.of(context)!.translate('ok')}",
                        style: TextStyle(color: KColors.primaryColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]));
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
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          /*  if (widget.menuId == -1)
        widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter!.fetchMenuWithMenuId(widget.menuId);
*/
          if (widget.menuId != -1) {
            widget.presenter!.fetchMenuWithMenuId(widget.menuId!);
          } else if (widget.foodId != -1) {
            widget.presenter!.fetchMenuWithFoodId(widget.foodId!);
          } else {
            widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant!.id!);
          }
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          /*   if (widget.menuId == -1)
        widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant.id);
      else
        widget.presenter!.fetchMenuWithMenuId(widget.menuId);*/

          if (widget.menuId != -1) {
            widget.presenter!.fetchMenuWithMenuId(widget.menuId!);
          } else if (widget.foodId != -1) {
            widget.presenter!.fetchMenuWithFoodId(widget.foodId!);
          } else {
            widget.presenter!.fetchMenuWithRestaurantId(widget.restaurant!.id!);
          }
        });
  }

  @override
  void highLightFood(int menuId, int foodId) {
    widget.menuId = menuId;
    widget.highlightedFoodId = foodId;
  }

  _showDetails(ShopProductModel food) {
    mDialog(food!.description!);
  }

  void mDialog(String message) {
    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String? svgIcons,
      Icon? icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function? actionIfYes}) {
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
                          svgIcons!,
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
                          "${AppLocalizations.of(context)!.translate('refuse')}",
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
                          "${AppLocalizations.of(context)!.translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes!();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context)!.translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
      },
    );
  }

  _jumpToShopDetails(ShopModel shopModel) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopDetailsPage(
                distance: shopModel!.distance,
                shipping_price: shopModel!.delivery_pricing,
                restaurant: shopModel,
                presenter: RestaurantDetailsPresenter(RestaurantDetailsView())),
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

  String _getShippingPrice(
      String distance, Map<String, String> myBillingArray) {
    try {
      int distanceInt = int.parse(
          !distance.contains(".") ? distance : distance.split(".")[0]);
      if (myBillingArray["$distanceInt"] == null) {
        return "~";
      } else {
        return myBillingArray["$distanceInt"]!;
      }
    } catch (_) {
      xrint(_);
      return "~";
    }
  }
}

class CustomAnimatedPosition extends AnimatedPositioned {
  var child;
  double? left;
  double? top;
  double? right;
  double? bottom;
  Duration duration;
  int? serial;
  var context;

  CustomAnimatedPosition(
      {this.context,
      this.right,
      this.bottom,
      this.left,
      this.top,
      required this.duration,
      required this.child})
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
