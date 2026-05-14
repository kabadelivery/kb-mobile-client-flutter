import 'dart:collection';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/food_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/order_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/modals/Modal_2_connect.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderConfirmationPage2.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../utils/functions/popups.dart';
import '../../../../../customwidgets/notation.dart';
import '../../../../newAuth/loginpage.dart';

class ShopFlowerDetailsPage extends StatefulWidget {
  static var routeName = "/ShopFlowerDetailsPage";

  ShopProductModel? food;

  FoodPresenter? presenter;

  int? foodId;

  ShopModel? restaurant;

  ShopFlowerDetailsPage({Key? key, this.food, this.foodId, this.presenter})
      : super(key: key) {
    this.restaurant = food?.restaurant_entity;
  }

  @override
  _ShopFlowerDetailsPageState createState() => _ShopFlowerDetailsPageState();
}

class _ShopFlowerDetailsPageState extends State<ShopFlowerDetailsPage>
    implements FoodView {
//  SliverAppBar flexibleSpaceWidget;
  ScrollController? _scrollController;

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
    popupMenus = ["${AppLocalizations.of(context)!.translate('share')}"];
    if (widget.food != null) {
      expandedHeight = 2 * MediaQuery.of(context).size.width / 3 + 20;
      images = widget.food?.food_details_pictures;
      if (images == null) {
        images = [widget.food!.pic!];
      }
    }
  }

  double? expandedHeight;
  var images;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();

    if (widget.food == null) {
      // there must be a food id.
      widget.presenter!.foodView = this;
      widget.presenter!.fetchFoodById(widget.foodId!);
    }
  }

  _carousselPageChanged(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int args = ModalRoute.of(context)!.settings.arguments == null
        ? 0
        : ModalRoute.of(context)!.settings.arguments as int;
    if (args != null && args != 0) widget.foodId = args;
    if (widget.food == null) {
      // there must be a food id.
      widget.presenter!.fetchFoodById(widget.foodId!);
    }

    /* use silver-app-bar first */
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        backgroundColor: KColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25),bottomRight: Radius.circular(25))
        ),
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
                    "${AppLocalizations.of(context)!.translate('product_details')}"),
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
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          widget.presenter!.fetchFoodById(widget.foodId!);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          widget.presenter!.fetchFoodById(widget.foodId!);
        });
  }

  _buildRestaurantFoodPage() {
    if (widget.food == null) return _buildSysErrorPage();
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 9 * MediaQuery.of(context).size.width / 16,
                  width: MediaQuery.of(context).size.width,
                  decoration:BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(25)
                  ),
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
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              height: 9 * MediaQuery.of(context).size.width / 16,
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl: Utils.inflateLink(pictureLink),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    })?.toList(),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 9 * MediaQuery.of(context).size.width / 15,
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// INDICATORS
                          if ((images?.length ?? 0) > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  images?.length ?? 0,
                                      (index) {
                                    final bool isActive =
                                        _carousselPageIndex == index;

                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      height: 8,
                                      width: isActive ? 22 : 8,

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: isActive
                                            ? KColors.primaryColor
                                            : KColors.primaryColor.withOpacity(.2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          /// TITLE + PRICE
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// LEFT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      Utils.capitalize(
                                        widget.food?.name ?? "",
                                      ),

                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: KColors.new_black,
                                        height: 1.2,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    if (widget.food?.promotion != 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE5EA),
                                          borderRadius: BorderRadius.circular(999),
                                        ),

                                        child: Text(
                                          "PROMO",

                                          style: TextStyle(
                                            color: KColors.primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// RIGHT PRICE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [

                                  if (widget.food!.promotion != 0)
                                    Text(
                                      "${widget.food?.price} ${AppLocalizations.of(context)!.translate('currency')}",

                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AutoSizeText(
                                        "${widget.food!.promotion != 0 ? widget.food?.promotion_price : widget.food?.price}",

                                        maxLines: 1,
                                        minFontSize: 16,

                                        style: TextStyle(
                                          color: widget.food!.promotion == 0
                                              ? KColors.primaryColor
                                              : KColors.primaryYellowColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),

                                      const SizedBox(width: 4),

                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('currency'),

                                          style: TextStyle(
                                            color: widget.food!.promotion == 0
                                                ? KColors.primaryColor
                                                : KColors.primaryYellowColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          /// DESCRIPTION TITLE
                          Text(
                            AppLocalizations.of(context)!
                                .translate('product_description_section_title'),

                            style: TextStyle(
                              color: KColors.new_black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// DESCRIPTION
                          Text(
                            "${widget.food?.description?.trim()}",

                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /* bottom bar for quantity and others */
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.primaryColor.withOpacity(.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                _qtyButton(
                                  icon: Icons.remove,
                                  onTap: _decreaseQuantity,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  child: Text(
                                    "$quantity",
                                    style: TextStyle(
                                      color: KColors.new_black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),

                                _qtyButton(
                                  icon: Icons.add,
                                  onTap: _increaseQuantity,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.translate('total'),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${_getTotalPrice()} ${AppLocalizations.of(context)!.translate('currency')}",
                                style: TextStyle(
                                  color: KColors.primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => PreparationPopup(
                                preparationTime:
                                widget.food!.restaurant_entity!.cooking_time ?? 35,
                              ),
                            ).then((value) {
                              if (value != null) {
                                if (value['success']) {
                                  _continuePurchase();
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('buy')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        '${AppLocalizations.of(context)!.translate('share_food_1')}${ServerConfig.SERVER_ADDRESS_SECURE}/food/${widget.food?.id} ${AppLocalizations.of(context)!.translate('share_food_2')}',
        subject: '');
  }

  void _continuePurchase() {
    Map<ShopProductModel, int> adds_on_selected = HashMap();
    Map<ShopProductModel, int> food_selected = HashMap();
    int totalPrice = 0;

    /* init */
    food_selected.putIfAbsent(widget.food!, () => quantity);
    totalPrice = int.parse(widget.food!.promotion! == 0 /* no promotion */
            ? widget.food!.price.toString()
            : widget.food!.promotion_price.toString()) *
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
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône carrée avec gradient
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KColors.primaryColor,
                          KColors.primaryColor.withOpacity(.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Connexion requise",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    AppLocalizations.of(context)!.translate(
                        "please_login_before_going_forward_description_place_order"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton principal "Se connecter"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD13457),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(Icons.person, color: Colors.white),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.translate('login'),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>LoginPageV2()
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bouton secondaire "Pas maintenant"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.translate('not_now'),
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );


    } else {
      Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OrderConfirmationPage2(
                  restaurant: widget.restaurant!,
                  presenter:
                      OrderConfirmationPresenter(OrderConfirmationView()),
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
        "${int.parse(widget.food!.promotion == 0
            ? widget.food!.price.toString() :
        widget.food!.promotion_price.toString()) * quantity}"
    );


  }
  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: KColors.primaryColor,
        ),
      ),
    );
  }
}
