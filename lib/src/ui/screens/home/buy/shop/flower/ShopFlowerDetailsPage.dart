import 'dart:collection';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:share/share.dart';

class ShopFlowerDetailsPage extends StatefulWidget {
  static var routeName = "/ShopFlowerDetailsPage";

  ShopProductModel food;

  FoodPresenter presenter;

  int foodId;

  ShopModel restaurant;

  ShopFlowerDetailsPage({Key key, this.food, this.foodId, this.presenter})
      : super(key: key) {
    this.restaurant = food?.restaurant_entity;
  }

  @override
  _ShopFlowerDetailsPageState createState() => _ShopFlowerDetailsPageState();
}

class _ShopFlowerDetailsPageState extends State<ShopFlowerDetailsPage>
    implements FoodView {
//  SliverAppBar flexibleSpaceWidget;
  ScrollController _scrollController;

  int _carousselPageIndex = 0;

  static List<String> popupMenus = ["Share"];

  int quantity = 1;

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  int MAX_FOOD_COUNT = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    popupMenus = ["${AppLocalizations.of(context).translate('share')}"];
    if (widget.food != null) {
      expandedHeight = 2 * MediaQuery.of(context).size.width / 3 + 20;
      images = widget.food?.food_details_pictures;
      if (images == null) {
        images = [widget.food.pic];
      }
    }
  }

  double expandedHeight;
  var images;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();

    if (widget.food == null) {
      // there must be a food id.
      widget.presenter.foodView = this;
      widget.presenter.fetchFoodById(widget.foodId);
    }
  }

  _carousselPageChanged(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int args = ModalRoute.of(context).settings.arguments;
    if (args != null && args != 0) widget.foodId = args;
    if (widget.food == null) {
      // there must be a food id.
      widget.presenter.fetchFoodById(widget.foodId);
    }

    /* use silver-app-bar first */
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
        actions: <Widget>[
      PopupMenuButton<String>(
      onSelected: menuChoiceAction,
        itemBuilder: (BuildContext context) {
          return popupMenus.map((String menuName) {
            return PopupMenuItem<String>(
                value: menuName, child: Text(menuName));
          }).toList();
        },
      )
      ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('product_details')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
            color: Colors.white,
            child: isLoading
                ? Center(child: MyLoadingProgressWidget())
                : (hasNetworkError
                    ? _buildNetworkErrorPage()
                    : hasSystemError
                        ? _buildSysErrorPage()
                        : _buildRestaurantFoodPage())),
      ),
    );
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchFoodById(widget.foodId);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchFoodById(widget.foodId);
        });
  }

  _buildRestaurantFoodPage() {
    if (widget.food == null) return _buildSysErrorPage();
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                height: 9 * MediaQuery.of(context).size.width / 16,
                width: MediaQuery.of(context).size.width,
                color: Colors.redAccent,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: images?.length != null && images.length > 1
                        ? true
                        : false,
                    reverse: images?.length != null && images.length > 1
                        ? true
                        : false,
                    enableInfiniteScroll:
                        images?.length != null && images.length > 1
                            ? true
                            : false,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 300),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    height: expandedHeight,
                    onPageChanged: _carousselPageChanged,
                  ),
                  items: images?.map<Widget>((pictureLink) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            height: 9 * MediaQuery.of(context).size.width / 16,
                            width: MediaQuery.of(context).size.width,
                            child: CachedNetworkImage(
                                imageUrl: Utils.inflateLink(pictureLink),
                                fit: BoxFit.cover));
                      },
                    );
                  })?.toList(),
                ),
              ),
              SingleChildScrollView(
                  child: Column(children: <Widget>[
                SizedBox(
                  height: 9 * MediaQuery.of(context).size.width / 16,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                    /*  borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))*/),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0, top: 10, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[]..addAll(List<Widget>.generate(
                                    images?.length == null ? 0 : images?.length,
                                    (int index) {
                              return Container(
                                  margin: EdgeInsets.only(right: 2.5, top: 2.5),
                                  height: 9,
                                  width: _carousselPageIndex == index ? 18 : 9,
                                  decoration: new BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: (index == _carousselPageIndex ||
                                              index == images.length)
                                          ? KColors.primaryColor
                                          : KColors.primaryColor
                                              .withAlpha(50)));
                            })
                                /* add a list of rounded views */
                                ),
                        ),
                      ),
                      Container(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 10,),
                            Row(crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text("${widget.food?.name?.toUpperCase()}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 15,fontWeight: FontWeight.w600,
                                          color: Colors.grey)),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 20,),
                                      widget.food.promotion == 0
                                          ? Text("${widget.food?.price}",
                                              style: TextStyle(
                                                  color: KColors.primaryColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold))
                                          : Text("${widget.food?.price}",
                                              style: TextStyle(
                                                  color: KColors.new_black,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                      widget.food.promotion != 0
                                          ? Row(children: <Widget>[
                                              SizedBox(width: 5),
                                              Text(
                                                  "${widget.food?.promotion_price}",
                                                  style: TextStyle(
                                                      color:
                                                          KColors.primaryYellowColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                          : Container(),
                                      SizedBox(width: 5),
                                      Text(
                                          "${AppLocalizations.of(context).translate('currency')}",
                                          style: TextStyle(
                                              color:  widget.food.promotion == 0 ? KColors.primaryColor : KColors.primaryYellowColor,
                                              fontSize: 12))
                                    ]),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(children: [
                              Text(
                                  "${AppLocalizations.of(context).translate('product_description_section_title')}",
                                  style: TextStyle(color: KColors.new_black,  fontSize: 14, fontWeight: FontWeight.w600))
                            ]),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text("${widget.food?.description?.trim()}",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                            SizedBox(height: 20)
                          ])),
                    ],
                  ),
                ),
              ])),
              /* bottom bar for quantity and others */
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                              Container(
                                child: IconButton(
                                    icon: Icon(Icons.remove,
                                        size: 15, color: KColors.primaryColor),
                                    onPressed: () => _decreaseQuantity()),
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KColors.primaryColor.withAlpha(50)),
                              ),
                              SizedBox(width: 15),
                              Text("${quantity}",
                                  style: TextStyle(
                                      color: KColors.new_black, fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Container(
                                child: IconButton(
                                    icon: Icon(Icons.add,
                                        size: 15, color: KColors.primaryColor),
                                    onPressed: () => _increaseQuantity()),
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: KColors.primaryColor.withAlpha(50)),
                              ),
                            ])),
                        SizedBox(height: 10),
                        Text(
                            "${_getTotalPrice()}${AppLocalizations.of(context).translate('currency')}",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 15),
                        Container(margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: ElevatedButton(
                              onPressed: () {
                                _continuePurchase();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      "${AppLocalizations.of(context).translate('buy')}"
                                          ?.toUpperCase(),
                                      style: TextStyle(
                                          color: KColors.white, fontSize: 15)),
                                ],
                              )),
                        )
                      ]),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _decreaseQuantity() {
    if (quantity > 1)
      setState(() {
        quantity--;
      });
    else
      /* toast that we can't go less*/
      xrint("");
  }

  _increaseQuantity() {
    if (quantity < MAX_FOOD_COUNT)
      setState(() {
        quantity++;
      });
    else
      /* toast that we can't go much */
      xrint("");
  }

  void menuChoiceAction(String value) {
    /* share a link */
    Share.share(
        '${AppLocalizations.of(context).translate('share_food_1')}${ServerConfig.SERVER_ADDRESS_SECURE}/food/${widget.food?.id} ${AppLocalizations.of(context).translate('share_food_2')}',
        subject: '');
  }

  void _continuePurchase() {
    Map<ShopProductModel, int> adds_on_selected = HashMap();
    Map<ShopProductModel, int> food_selected = HashMap();
    int totalPrice = 0;

    /* init */
    food_selected.putIfAbsent(widget.food, () => quantity);
    totalPrice = int.parse(widget.food.promotion == 0 /* no promotion */
            ? widget.food.price
            : widget.food.promotion_price) *
        quantity;

    /* data */
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderConfirmationPage2(restaurant: widget.restaurant, presenter: OrderConfirmationPresenter(),foods: food_selected, addons: adds_on_selected),
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
//                      border: new Border.all(color: Colors.white, width: 2),
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

  @override
  void inflateFood(ShopProductModel food) {
    showLoading(false);
    this.widget.food = food;
    // expandedHeight = 9 * MediaQuery.of(context).size.width / 16 + 20;

    setState(() {
      images = widget.food?.food_details_pictures;
    });
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasNetworkError = true;
    });
  }

  @override
  void showLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
      if (isLoading == true) {
        this.hasNetworkError = false;
        this.hasSystemError = false;
      }
    });
  }

  @override
  void systemError() {
    showLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasSystemError = true;
    });
  }

  _getTotalPrice() {
    return Utils.inflatePrice(
        "${int.parse(widget.food.promotion == 0 /* no promotion */
            ? widget.food.price : widget.food.promotion_price) * quantity}");
  }
}
