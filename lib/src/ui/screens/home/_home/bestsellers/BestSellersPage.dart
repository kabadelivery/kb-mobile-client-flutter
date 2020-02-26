import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/bestseller_contract.dart';
import 'package:kaba_flutter/src/models/BestSellerModel.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


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
  List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];


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
        backgroundColor: Colors.white,
        title: Text("BEST SELLERS", style:TextStyle(color:KColors.primaryColor)),
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
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchBestSeller(); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchBestSeller(); });
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
              return Card(
                  child: InkWell(
                    onTap: ()=>_jumpToFoodDetails(data[position].food_entity),
                    child: Container(
//                      color: Colors.yellow,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(5),
                              child: Text("${position + 1}.", style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 28))),
                          Container(
//                            color: Colors.green,
                            child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
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
                                                  Utils.inflateLink(
                                                      data[position]
                                                          .food_entity
                                                          .restaurant_entity
                                                          .pic))
                                          )
                                      )
                                  ),
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(data[position].food_entity
                                                .restaurant_entity.name
                                                .toUpperCase(),
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 18,
                                                    color: KColors.primaryColor,
                                                    fontWeight: FontWeight
                                                        .bold))),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Column(children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(data[position].food_entity
                                                          .name,
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
                                                Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .center,
                                                    children: <Widget>[

                                                      data[position].food_entity
                                                          .promotion == 0 ?
                                                      Text("${data[position]
                                                          .food_entity?.price}",
                                                          style: TextStyle(
                                                              color: KColors
                                                                  .primaryYellowColor,
                                                              fontSize: 30,
                                                              fontWeight: FontWeight
                                                                  .bold)) : Text(
                                                          "${data[position]
                                                              .food_entity
                                                              ?.price}",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 30,
                                                              fontWeight: FontWeight
                                                                  .bold)),

                                                      data[position].food_entity
                                                          .promotion != 0 ? Row(
                                                          children: <Widget>[
                                                            SizedBox(width: 10),
                                                            Text("${data[position]
                                                                .food_entity
                                                                ?.promotion_price}",
                                                                style: TextStyle(
                                                                    color: KColors
                                                                        .primaryColor,
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight
                                                                        .bold)),
                                                          ]) : Container(),

                                                      SizedBox(width: 10),
                                                      Text("FCFA",
                                                          style: TextStyle(
                                                              color: KColors
                                                                  .primaryYellowColor,
                                                              fontSize: 12))
                                                    ]),
                                              ])),
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
                                                        Text("Ven",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black
                                                                    .withAlpha(
                                                                    150))),
                                                        data[position]
                                                            .history[index] ==
                                                            -1 ? IconButton(
                                                            iconSize: 40,
                                                            icon: Icon(
                                                                Icons
                                                                    .trending_down,
                                                                color: Colors
                                                                    .red),
                                                            onPressed: null) :
                                                        data[position]
                                                            .history[index] == 0
                                                            ? IconButton(
                                                            iconSize: 40,
                                                            icon: Icon(
                                                                Icons
                                                                    .trending_flat,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed: null)
                                                            :
                                                        data[position]
                                                            .history[index] == 1
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
                                            ),
                                        )
                                      ]),
                                ]),
                          )
                        ],
                      ),
                    ),
                  )
              );
            }));
  }

  _jumpToFoodDetails(RestaurantFoodModel food_entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food_entity),
      ),
    );
  }

}
