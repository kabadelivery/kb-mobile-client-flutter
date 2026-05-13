import 'dart:async';
import 'dart:math';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/microservices/expedition/presentation/widget/popAnimation.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopCategoryModelModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/resources/restaurant_api_provider.dart';
import 'package:KABA/src/ui/customwidgets/FloatingCartButton/FloatingCartButton.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

import '../../../utils/functions/show_tutorials.dart';
import '../../customwidgets/notation.dart';
import '../../customwidgets/promotion_banner.dart';
import '../../customwidgets/shimmer.dart';
import '../newAuth/colors.dart';
import '../rating/article_review.dart';

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
  List<Map<String,dynamic>> shippingPromotion =[];
  int MAX_CHIP_FOR_SCREEN = -1;
  final OutlineInputBorder commonBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
      width: 1,
      color: AuthColors.inputBorder,
    ),
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  bool isTherePromotion=false;
  bool isThereShippingPromotion=false;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  bool _notificationHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.fromNotification == true && !_notificationHandled) {
      _notificationHandled = true;

      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is int && args != 0) {
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
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('shippingPromotions ${shippingPromotion}');

    if (MAX_CHIP_FOR_SCREEN < 0) {
      MAX_CHIP_FOR_SCREEN = MediaQuery.of(context).size.width ~/ 50;
    }

    var appBar = AppBar(
      toolbarHeight: 130,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      backgroundColor: KColors.primaryColor,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () => _jumpToShopDetails(widget.restaurant!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.restaurant?.name ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      if (widget.restaurant?.is_certified == true) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            showCertificationTutorial(context: context);
                          },
                          child: Image.asset(
                            "assets/images/png/certif_white.png",
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                _getRestaurantStateTag(widget.restaurant),
              ],
            ),
            const SizedBox(height: 3),

            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 13,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    widget.restaurant?.address ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLoading &&
                      StateContainer.of(context).location?.latitude != null &&
                      widget.restaurant?.distance != null)
                    _RestaurantInfoChip(
                      icon: FontAwesomeIcons.locationArrow,
                      text:
                      "${widget.restaurant?.distance} ${AppLocalizations.of(context)!.translate('km')}",
                      iconColor: KColors.mGreen,
                    ),

                  const SizedBox(width: 8),

                  if (widget.restaurant != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: KColors.new_gray,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ShippingFeeTag(widget.restaurant!.distance),
                    ),
                  SizedBox(width: 10,),
                  GestureDetector(
                    onTap: () => _jumpToShopDetails(widget.restaurant!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                        color: KColors.primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.translate("more_details"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Center(

          ),
        ),
      ],
    );
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingCartButton(
        itemCount: _foodCount, onPressed: () { _showMenuBottomSheet(ALL);  },
     // dynamic number

  ),
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
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 10),
                          ),
                        ];
                      },
                      body: Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Column(
                          children: [
                            isTherePromotion ||isThereShippingPromotion
                                ? PopInWidget(
                              duration: const Duration(seconds: 2),
                              child: PromotionCarousel(
                                merchantName: widget.restaurant!.name!,
                                foodPromotion: isTherePromotion?{
                                  "title": "Promo spéciale",
                                  "message": "Profite d’une offre gourmande chez ${widget.restaurant!.name!}",
                                  "type": "food",
                                }:null,
                                deliveryPromotions: isThereShippingPromotion?shippingPromotion:[],
                                onTap: () {
                                  setState(() {
                                    currentIndex = -1;
                                  });
                                },
                              ),
                            )
                            : const SizedBox(),
                            SizedBox(height: 8,),
                            PopInWidget(
                              duration: Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 8.0),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.trim().toLowerCase();
                                    });
                                  },
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    filled: true,
                                    fillColor: AuthColors.inputBackground,
                                    errorStyle: const TextStyle(
                                      fontSize: 11,
                                      height: 1,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 12,
                                    ),
                                    hintText:
                                    AppLocalizations.of(context)!
                                        .translate('search_article'),

                                    hintStyle: const TextStyle(fontSize: 14),

                                    border: commonBorder,
                                    enabledBorder: commonBorder,
                                    focusedBorder: commonBorder,
                                  ),

                                ),
                              ),
                            ),
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
                            ),Row(
                              children: [
                                isTherePromotion?  GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex = -1; // -1 = mode promo
                                      _searchQuery = "";
                                      _searchController.clear();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 8, right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: currentIndex == -1
                                          ? KColors.primaryColor
                                          : KColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: KColors.primaryColor.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_offer_rounded,
                                          size: 15,
                                          color: currentIndex == -1
                                              ? Colors.white
                                              : KColors.primaryColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Promos",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: currentIndex == -1
                                                ? Colors.white
                                                : KColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ):Container(),

                                Expanded(
                                  child: ChipList(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    style: const TextStyle(fontSize: 12),
                                    listOfChipNames: _chipList,
                                    activeBgColorList: [
                                      Theme.of(context).primaryColor,
                                    ],
                                    inactiveBgColorList: [
                                      KColors.primaryColor.withOpacity(0.1),
                                    ],
                                    activeTextColorList: [Colors.white],
                                    inactiveTextColorList: [KColors.primaryColor],
                                    listOfChipIndicesCurrentlySeclected:
                                    _searchQuery.trim().isNotEmpty || currentIndex == -1
                                        ? [-1]
                                        : [currentIndex],
                                    extraOnToggle: (val) {
                                      setState(() {
                                        currentIndex = val;
                                        _searchQuery = "";
                                        _searchController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                  key: PageStorageKey<String>(
                                      "menu_id_${currentIndex}"),
                                  child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: isLoading
                                          ? Column(
                                        children: [
                                          Container(
                                            height: 40,
                                            margin: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: 10,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  child: chipListShimmer(context),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: 10,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                child: foodListShimmer(context),
                                              );
                                            },
                                          )
                                        ],
                                      )
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
                                                                            .restaurant!
                                                                            .id!);
                                                                      else
                                                                        widget
                                                                            .presenter!
                                                                            .fetchMenuWithMenuId(widget.menuId!);
                                                                    } else {
                                                                      restaurantBloc
                                                                          .fetchRestaurantMenuList(
                                                                              widget.restaurant!);
                                                                    }
                                                                  })
                                                              : hasSystemError
                                                                  ? ErrorPage(
                                                                      message:
                                                                          "${AppLocalizations.of(context)!.translate('system_error')}",
                                                                      onClickAction:
                                                                          () {
                                                                        if (!widget!
                                                                            .fromNotification!) {
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

  void _computeBasketOffset() {
    final context = _menuBasketKey!.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final renderBox = renderObject as RenderBox;

    setState(() {
      _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
    });
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

    final query = _searchQuery.trim().toLowerCase();

    final List<Map<String, dynamic>> displayedFoods = [];



    if (query.isNotEmpty) {
      for (int menuIndex = 0; menuIndex < data!.length; menuIndex++) {
        final foods = data![menuIndex].foods ?? [];

        for (int foodIndex = 0; foodIndex < foods.length; foodIndex++) {
          final food = foods[foodIndex];

          final name = "${food.name}".toLowerCase();
          final description = "${food.description ?? ""}".toLowerCase();

          if (name.contains(query) || description.contains(query)) {
            displayedFoods.add({
              "food": food,
              "foodIndex": foodIndex,
              "menuIndex": menuIndex,
            });
          }
        }
      }
    }
    else if (currentIndex == -1) {
      for (int menuIndex = 0; menuIndex < data!.length; menuIndex++) {
        final foods = data![menuIndex].foods ?? [];

        for (int foodIndex = 0; foodIndex < foods.length; foodIndex++) {
          final food = foods[foodIndex];

          if (food.promotion != 0) {
            displayedFoods.add({
              "food": food,
              "foodIndex": foodIndex,
              "menuIndex": menuIndex,
            });
          }
        }
      }
    }
    else {
      final foods = data![currentIndex].foods ?? [];

      for (int foodIndex = 0; foodIndex < foods.length; foodIndex++) {
        displayedFoods.add({
          "food": foods[foodIndex],
          "foodIndex": foodIndex,
          "menuIndex": currentIndex,
        });
      }
    }
    return Column(
      children: <Widget>[const SizedBox(height: 5)]
        ..addAll(List.generate(displayedFoods.length, (index) {
          final item = displayedFoods[index];

          return Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildFoodListWidget3(
                food: item["food"],
                foodIndex: item["foodIndex"],
                menuIndex: item["menuIndex"],
                highlightedFoodId: widget.highlightedFoodId!,
              ),
            ],
          );
        }))
        ..add(const SizedBox(height: 30)),
    );
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
      int? highlightedFoodId})
  {
    final double oldPrice = double.tryParse("${food?.price}") ?? 0;
    final double newPrice = double.tryParse("${food?.promotion_price}") ?? 0;

    final int discountPercent =
    oldPrice > 0
        ? (((oldPrice - newPrice) / oldPrice) * 100).round()
        : 0;
    return InkWell(
      onTap: () => _jumpToFoodDetails(context, food!),
      child: Container(
          width: MediaQuery.of(context).size.width - 20,
          margin: EdgeInsets.only(bottom: 15, left: 10, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1,color: AuthColors.inputBorder.withOpacity(.8)),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                spreadRadius: 10,
                blurRadius: 20,
                color: Colors.grey.withOpacity(.05)
              )
            ]
          ),
          padding: EdgeInsets.all(15),
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
                      borderRadius: BorderRadius.circular(20),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text("${Utils.capitalize(food!.name!.trim())}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ),


                              ],
                            ),
                           
                            Text(
                                "${Utils.capitalize(Utils.replaceNewLineBy(food!.description!.trim(), " / "))}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                        GestureDetector(
                            onTap: ()async{
                              if(food!.review_count!.toInt() <1){

                              }else{
                               Map? result =await showReviewDialog(context,RatingReview(food:food!));
                               if(result!=null){
                                 if(result['add_to_basket']){
                                   _addFoodToChart(
                                       food, foodIndex!, menuIndex!);
                                 }
                               }
                              }
                            },
                            child: Notation(text: "${food!.rating}",count: food!.review_count,food: food)),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // added
                              Row(
                                children: [
                                  if (food.promotion != 0) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE5EA),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        "-${discountPercent}%",
                                        style: TextStyle(
                                          color: KColors.primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),
                                  ],

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (food.promotion != 0)
                                        Text(
                                          "${food.price} ${AppLocalizations.of(context)!.translate('currency')}",
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey.shade500,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                      Row(
                                        children: [
                                          Text(
                                            "${food.promotion != 0 ? food.promotion_price : food.price}",
                                            style: TextStyle(
                                              color: KColors.primaryColor,
                                              fontSize: food.promotion != 0 ? 15 : 13,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),

                                          const SizedBox(width: 4),

                                          Text(
                                            AppLocalizations.of(context)!.translate('currency'),
                                            style: TextStyle(
                                              color: KColors.primaryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => _addFoodToChart(
                                    food, foodIndex!, menuIndex!),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: KColors.primaryColor.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, right: 8, left: 8),
                                  child: Row(children: <Widget>[
                                    Text(
                                        "${AppLocalizations.of(context)!.translate('add_to_basket')}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: KColors.primaryColor)),
                                    SizedBox(width: 5),
                                    Icon(Icons.shopping_cart_checkout,
                                        color: KColors.primaryColor, size: 14),
                                  ]),
                                ),
                              ),

                              // not added
                            ])
                      ]),
                )),
                SizedBox(width: 5,),
                Container(
                  color: KColors.new_gray,
                  child: Container(
                    height: 115,
                    width: 115,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
    if (shopModel != null) {
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
          tagText =
              "${AppLocalizations.of(context)!.translate('t_unavailable')}";
          tagTextColor = KColors.mBlue;
          break;
      }
    }
    int? coming_soon = shopModel == null ? 0 : shopModel!.coming_soon;
    return coming_soon == 0
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
    Toast.show(message, duration: Toast.lengthLong, gravity: Toast.center);
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
  void inflateMenu(ShopModel restaurant, List<RestaurantSubMenuModel> data) async{
    RestaurantApiProvider rp =RestaurantApiProvider();
    List<dynamic>  dataJson =[];
    List<Map<String,dynamic>>  finalPromo =[];
    try{
      dataJson = await rp.fetchRestaurantPromotion(widget.restaurant!.id!);
      for(var promo in dataJson){
        finalPromo.add(promo);
      }
    }catch(e){
      debugPrint("dataJson error $e");
    }
    setState(() {
      if(dataJson.isNotEmpty){
        shippingPromotion =finalPromo;
        isThereShippingPromotion = true;
      }
      if (restaurant.max_food == null) restaurant.max_food = "5";
      if (restaurant.max_food != null || int.parse(restaurant.max_food!) > 0)
        FOOD_MAX = int.parse(restaurant.max_food!);
      widget.restaurant = restaurant;

      Position? currentLocation = StateContainer.of(context).location;

      if (currentLocation == null && widget.restaurant?.location != null) {
        var parts = widget.restaurant!.location!.split(":");
        if (parts.length == 2) {
          double latitude = double.tryParse(parts[0]) ?? 0.0;
          double longitude = double.tryParse(parts[1]) ?? 0.0;
          currentLocation = Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0, altitudeAccuracy: 5, headingAccuracy: 1,
            // Since Position requires these fields, just set dummy values if needed
          );
        }
      }

      if (currentLocation != null && widget.restaurant != null) {
        double distance =
            Utils.locationDistance(currentLocation, widget.restaurant!);
        widget.restaurant?.distance =
            distance > 100 ? "100" : distance.toString();
      }
      // according to the distance, we get the matching delivery fees
      // i dont want to make another loop
      widget.restaurant!.delivery_pricing = _getShippingPrice(
          widget.restaurant!.distance!,
          StateContainer.of(context).myBillingArray ?? {});

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

        isTherePromotion = _hasPromotion(data);
        if(isTherePromotion)currentIndex=-1;
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
          xrint('entered error network for fetchMenuWithMenuId');
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
  bool _hasPromotion(List<RestaurantSubMenuModel>? menus) {
    if (menus == null || menus.isEmpty) return false;

    for (final menu in menus) {
      final foods = menu.foods ?? [];

      for (final food in foods) {
        if ((food.promotion ?? 0) != 0) {
          return true;
        }
      }
    }

    return false;
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
class _RestaurantInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _RestaurantInfoChip({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: KColors.new_gray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 10,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
