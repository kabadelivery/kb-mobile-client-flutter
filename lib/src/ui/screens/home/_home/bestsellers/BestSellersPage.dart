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


class BestSellersPage extends StatefulWidget {

  static var routeName = "/BestSellersPage";

  BestSellerPresenter presenter;

  BestSellersPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _BestSellersPageState createState() => _BestSellersPageState();
}

class _BestSellersPageState extends State<BestSellersPage> implements BestSellerView {


  /* week days names */

  List<BestSellerModel> data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.bestSellerView = this;
    widget.presenter.fetchBestSeller();
  }

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("${AppLocalizations.of(context).translate('best_seller')}", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
          child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
          _buildBSellerList())
      ),
    );
  }

  @override
  void inflateBestSeller(List<BestSellerModel> bSellers) {

    showLoading(false);
    setState(() {
      this.data = bSellers;
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
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.fetchBestSeller(); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){ widget.presenter.fetchBestSeller(); });
  }

  _buildBSellerList() {
    if (data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }
    return Container(
        margin: EdgeInsets.only(bottom:10, right:10, left:10),
        child: ListView.builder(itemCount: data?.length,
            itemBuilder: (BuildContext context, int position) {
              return _buildBestSellerListItem(position, data[position]);
            }));
  }

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  _jumpToFoodDetails(ShopProductModel food) {
    Navigator.of(context).push(
        PageRouteBuilder (pageBuilder: (context, animation, secondaryAnimation)=>
            RestaurantMenuPage (presenter: MenuPresenter(), menuId: int.parse(food.menu_id), highlightedFoodId: food?.id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin:begin, end:end);
              var curvedAnimation = CurvedAnimation(parent:animation, curve:curve);
              return SlideTransition(position: tween.animate(curvedAnimation), child: child);
            }
        ));
  }

  _buildBestSellerListItem(int position, BestSellerModel data) {

    //history is yesterday, y-1, y-2
    var dayz = [
      "${AppLocalizations.of(context).translate('monday_short')}",
      "${AppLocalizations.of(context).translate('tuesday_short')}",
      "${AppLocalizations.of(context).translate('wednesday_short')}",
      "${AppLocalizations.of(context).translate('thursday_short')}",
      "${AppLocalizations.of(context).translate('friday_short')}",
      "${AppLocalizations.of(context).translate('saturday_short')}",
      "${AppLocalizations.of(context).translate('sunday_short')}",
    ];

    DateTime date = new DateTime.now();
    int day_of_week = date?.weekday;

//    String daY = dayz[day_of_week-1];
//    String today = dayz[day_of_week-1 < 0 ? 0:(day_of_week-1)];
//    String day_m_1 = dayz[day_of_week-2 < 0 ? 0:(day_of_week-2)];
//    String day_m_2 = dayz[day_of_week-3 < 0 ? 0:(day_of_week-3)];

    return Card(child: InkWell(
        onTap: ()=>_jumpToFoodDetails(data?.food_entity),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Row(children: <Widget>[
            // ranking id
            Container(
                padding: EdgeInsets.all(5),
                child: Text("${position + 1}.", style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 28))),
            Row(children: <Widget>[
              Container(
                height: 40, width: 40,
                decoration: BoxDecoration(
                    border: new Border.all(
                        color: KColors
                            .primaryYellowColor,
                        width: 2),
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            Utils.inflateLink(data?.food_entity?.pic))
                    )
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // restaurant name
                    Row(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text("${data?.food_entity?.restaurant_entity?.name}"
                                .toUpperCase(),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18,
                                    color: KColors.primaryColor,
                                    fontWeight: FontWeight
                                        .bold))),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 10),
                        child: Column(children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text("${data?.food_entity?.name?.length > 20 ? data?.food_entity?.name?.substring(0,20): data?.food_entity?.name}${data?.food_entity?.name?.length > 20 ? "...":""}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight
                                            .bold)),
                              ),
                            ],
                          ),
                        ])),
                    Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center,
                        children: <Widget>[
                          data?.food_entity?.promotion == 0 ?
                          Text("${data?.food_entity?.price}",
                              style: TextStyle(
                                  color: KColors
                                      .primaryYellowColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight
                                      .bold)) : Text(
                              "${data?.food_entity?.price}",
                              style: TextStyle(
                                  color: Colors.black,
                                  decoration:  TextDecoration.lineThrough,
                                  fontSize: 30,
                                  fontWeight: FontWeight
                                      .bold)),

                          data?.food_entity?.promotion != 0 ? Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text("${data?.food_entity?.promotion_price}",
                                    style: TextStyle(
                                        color: KColors
                                            .primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight
                                            .bold)),
                              ]) : Container(),

                          SizedBox(width: 10),
                          Text("${AppLocalizations.of(context).translate('currency')}",
                              style: TextStyle(
                                  color: KColors
                                      .primaryYellowColor,
                                  fontSize: 12))
                        ]),
                    SizedBox(height: 10),

                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly,
                        children: <Widget>[]
                          ..addAll(
                              List<Widget>.generate(
                                  3, (int index) {
                                return Column(
                                    children: <Widget>[
                                      Text("${dayz[((day_of_week-1 -3 +index) < 0 ? (day_of_week-1 -3 +index + 7) : (day_of_week-1 -3 +index))%7]}",
                                          style: TextStyle(
                                              color: Colors
                                                  .black
                                                  .withAlpha(
                                                  150))),
                                      data?.history[index] ==
                                          -1 ? IconButton(
                                          iconSize: 40,
                                          icon: Icon(
                                              Icons
                                                  .trending_down,
                                              color: Colors
                                                  .red),
                                          onPressed: null) :
                                      data?.history[index] == 0
                                          ? IconButton(
                                          iconSize: 40,
                                          icon: Icon(
                                              Icons
                                                  .trending_flat,
                                              color: Colors
                                                  .blue),
                                          onPressed: null)
                                          :
                                      data?.history[index] == 1
                                          ? IconButton(
                                          iconSize: 40,
                                          icon: Icon(
                                              Icons.trending_up,
                                              color: CommandStateColor
                                                  .delivered),
                                          onPressed: null)
                                          : Container()
                                    ]);
                              })
                          )),
                  ])
            ])
          ]),
        )));
  }

}
