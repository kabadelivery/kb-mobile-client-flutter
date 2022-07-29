import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class BestSellersMiniPage extends StatefulWidget {
  static var routeName = "/BestSellersMiniPage";

  BestSellerPresenter presenter;

  List<BestSellerModel> data;

  BestSellersMiniPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _BestSellersMiniPageState createState() => _BestSellersMiniPageState();
}

class _BestSellersMiniPageState extends State<BestSellersMiniPage>
    implements BestSellerView {


  @override
  void initState() {
    super.initState();
    widget.presenter.bestSellerView = this;
  }

  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;
  bool isDataInflated = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      widget.presenter.fetchBestSeller();
    } else {
      if (!isDataInflated) {
        inflateBestSeller(widget.data);
        isDataInflated = true;
      }
    }
    return Container(
        color: Colors.white,
        child: isLoading
            ? Center(child: SizedBox(height: 25, width: 25,child: CircularProgressIndicator()))
            : (hasNetworkError
                ? _buildNetworkErrorPage()
                : hasSystemError
                    ? _buildSysErrorPage()
                    : _buildBSellerList()));
  }

  @override
  void inflateBestSeller(List<BestSellerModel> bSellers) {
    showLoading(false);
    setState(() {
      widget.data = bSellers;
    });
  }

  @override
  void networkError() {
    showLoading(false);
    /* show a page of network error. */
    if (widget?.data == null)
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
    if (widget?.data == null)
    setState(() {
      this.hasSystemError = true;
    });
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchBestSeller();
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchBestSeller();
        });
  }

  _buildBSellerList() {
    if (widget.data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }
    return Container(
        margin: EdgeInsets.only(bottom: 10, right: 10, left: 10),
        child: ListView.builder(reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.data?.length,
            itemBuilder: (BuildContext context, int position) {
              return _buildBestSellerListItem(position, widget.data[position]);
            }));
  }

  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  _jumpToFoodDetails(ShopProductModel food) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                presenter: MenuPresenter(),
                menuId: int.parse(food.menu_id),
                highlightedFoodId: food?.id),
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

  _buildBestSellerListItem(int position, BestSellerModel data) {
    return GestureDetector(
        child: InkWell(
            onTap: () => _jumpToFoodDetails(data?.food_entity),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 100,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                  color: KColors.new_gray,
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.all(10),
              child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                // ranking id
                Container(
                  height: 82,
                  width: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      border: new Border.all(
                          color: KColors.primaryYellowColor.withOpacity(0.7),
                          width: 3),
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              Utils.inflateLink(data?.food_entity?.pic)))),
                ),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  "${data?.food_entity?.name}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ],
                                        ),
                                      ])),
                              Container( padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                              ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      data?.food_entity?.promotion == 0
                                          ? Text("${data?.food_entity?.price}",
                                              style: TextStyle(
                                                color: KColors.primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                              ))
                                          : Text("${data?.food_entity?.price}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  decoration:
                                                      TextDecoration.lineThrough,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                      data?.food_entity?.promotion != 0
                                          ? Row(children: <Widget>[
                                              SizedBox(width: 10),
                                              Text(
                                                  "${data?.food_entity?.promotion_price}",
                                                  style: TextStyle(
                                                      color: KColors.primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                          : Container(),
                                      SizedBox(width: 5),
                                      Text(
                                          "${AppLocalizations.of(context).translate('currency')}",
                                          style: TextStyle(
                                              color: KColors.primaryYellowColor,
                                              fontSize: 12))
                                    ]),
                              ),
                            ]),
                        // restaurant name
                        Container(
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                      Utils.capitalize(
                                              "${data?.food_entity?.restaurant_entity?.name}")
                                          .toUpperCase(),
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: KColors.primaryColor,
                                          fontWeight: FontWeight.normal))),
                            ],
                          ),
                        ),
                      ]),
                )
              ]),
            )));
  }
}
