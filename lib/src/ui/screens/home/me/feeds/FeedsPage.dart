import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/buy/shop/ShopDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/money/TransactionHistoryPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/xrint.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/feeds_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/FeedModel.dart';
import 'package:KABA/src/models/NotificationFDestination.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class FeedsPage extends StatefulWidget {
  static var routeName = "/FeedsPage";

  FeedPresenter? presenter;

  List<FeedModel>? data;

  FeedsPage({Key? key, this.title, this.presenter}) : super(key: key);

  final String? title;

  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> implements FeedView {
  /* week days names */
  CustomerModel? customer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter!.feedView = this;
    /* customer */
    CustomerUtils.getCustomer().then((customer) {
      this.customer = customer;
      widget.presenter!.fetchFeed(customer!);
    });
  }

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context)!.translate('feeds')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20,),
              onPressed: () {
                Navigator.pop(context);
              }),

      ),
      body: Container(
          child: isLoading
              ? Center(child: MyLoadingProgressWidget())
              : (hasNetworkError
                  ? _buildNetworkErrorPage()
                  : hasSystemError
                      ? _buildSysErrorPage()
                      : _buildFeedsList())),
    );
  }

  @override
  void inflateFeed(List<FeedModel> feeds) {
    showLoading(false);
    setState(() {
      widget.data = feeds;
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

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          widget.presenter!.fetchFeed(customer!);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          widget.presenter!.fetchFeed(customer!);
        });
  }

  _buildFeedsList() {
    if (widget.data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }
    return Container(
        margin: EdgeInsets.only(bottom: 10, right: 10, left: 10, top: 10),
        child: ListView.builder(
            itemCount: widget.data?.length,
            itemBuilder: (BuildContext context, int position) {
              return InkWell(
                onTap: () => _jumpToAdd(widget.data![position].destination!),
                child: Container(decoration: BoxDecoration(color: KColors.new_gray, borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      child: Text(
                   Utils.capitalize( "${widget.data![position]?.title}"),
                    style: TextStyle(
                        color: KColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ))
                ]),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(Utils.capitalize("${widget.data![position].content}"),
                            style: TextStyle(color: Colors.grey,fontSize: 12))),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "${widget.data![position].created_at}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey),
                      )
                    ])
              ]),
                ),
              );
            }));
  }

  _jumpToAdd(NotificationFDestination notificationFDestination) {
    xrint(notificationFDestination.toString());

    switch (notificationFDestination.type) {
      /* go to the activity we are supposed to go to with only the id */
      case NotificationFDestination.FOOD_DETAILS:
        _jumpToFoodDetailsWithId(notificationFDestination.product_id!);
        break;
      case NotificationFDestination.COMMAND_PAGE:
      case NotificationFDestination.COMMAND_DETAILS:
      case NotificationFDestination.COMMAND_PREPARING:
      case NotificationFDestination.COMMAND_SHIPPING:
      case NotificationFDestination.COMMAND_END_SHIPPING:
      case NotificationFDestination.COMMAND_CANCELLED:
      case NotificationFDestination.COMMAND_REJECTED:
        _jumpToCommandDetails(notificationFDestination.product_id!);
        break;
      case NotificationFDestination.MONEY_MOVMENT:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.SPONSORSHIP_TRANSACTION_ACTION:
        _jumpToTransactionHistory();
        break;
      case NotificationFDestination.ARTICLE_DETAILS:
//        _jumpToArticleInterface(notificationFDestination.product_id);
        break;
      case NotificationFDestination.RESTAURANT_PAGE:
        _jumpToRestaurantDetailsPage(notificationFDestination.product_id!);
        break;
      case NotificationFDestination.RESTAURANT_MENU:
        _jumpToRestaurantMenuPage(notificationFDestination.product_id!);
        break;
      case NotificationFDestination.MESSAGE_SERVICE_CLIENT:
        _jumpToServiceClient();
        break;
    }
  }

  _jumpToCommandDetails(int orderId) {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: orderId, presenter: OrderDetailsPresenter(OrderDetailsView())),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderNewDetailsPage(
                orderId: orderId, presenter: OrderDetailsPresenter(OrderDetailsView())),
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

  void _jumpToTransactionHistory() {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TransactionHistoryPage(presenter: TransactionPresenter(TransactionView())),
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

  void _jumpToArticleInterface(int product_id) {
//    navigatorKey.currentState.pushNamed(WebViewPage.routeName, arguments: product_id);
  }

  void _jumpToRestaurantDetailsPage(int product_id) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopDetailsPage(
                restaurantId: product_id,
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

  void _jumpToRestaurantMenuPage(int product_id) {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(menuId: product_id, presenter: MenuPresenter(MenuView())),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(menuId: product_id, presenter: MenuPresenter(MenuView())),
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

  void _jumpToFoodDetailsWithId(int food_id) {
    /*  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(foodId: food_id, highlightedFoodId: food_id, presenter: MenuPresenter(MenuView())),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                foodId: food_id,
                highlightedFoodId: food_id,
                presenter: MenuPresenter(MenuView())),
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

  void _jumpToServiceClient() {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerCareChatPage(presenter: CustomerCareChatPresenter(CustomerCareChatView())),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CustomerCareChatPage(presenter: CustomerCareChatPresenter(CustomerCareChatView())),
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

/* _jumpToFoodDetails(ShopProductModel food_entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food_entity),
      ),
    );
  }*/

}
