

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/feeds_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/FeedModel.dart';
import 'package:kaba_flutter/src/models/NotificationFDestination.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class FeedsPage extends StatefulWidget {

  static var routeName = "/FeedsPage";

  FeedPresenter presenter;

  FeedsPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> implements FeedView {

  /* week days names */
  List<FeedModel> data;
  CustomerModel customer;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.feedView = this;
    /* customer */
    CustomerUtils.getCustomer().then((customer) {
      this.customer = customer;
      widget.presenter.fetchFeed(customer);
    });
  }

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("FEEDS", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
          child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
          _buildFeedsList())
      ),
    );
  }

  @override
  void inflateFeed(List<FeedModel> feeds) {

    showLoading(false);
    setState(() {
      this.data = feeds;
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
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchFeed(customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchFeed(customer); });
  }

  _buildFeedsList() {
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
                    onTap: ()=>_jumpToAdd(data[position].destination),
                    child: Container(padding: EdgeInsets.all(5),
                      child: Column(children: <Widget>[
                        Row(children: <Widget>[Expanded(child: Text("${data[position]?.title?.toUpperCase()}", style: TextStyle(color: KColors.primaryColor, fontSize: 18, fontWeight: FontWeight.normal),))]),
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Expanded(child: Text("${data[position].content}", style: TextStyle(color: Colors.black))),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[Text("${data[position].created_at}", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),)])
                      ]),
                    ),
                  )
              );
            }));
  }

  _jumpToAdd(NotificationFDestination destination) {

    switch (destination.type) {
      case NotificationFDestination.FOOD_DETAILS:

        break;
      case NotificationFDestination.RESTAURANT_MENU:

        break;
      case NotificationFDestination.RESTAURANT_PAGE:

        break;
      case NotificationFDestination.MONEY_MOVMENT:
        break;
      case NotificationFDestination.ARTICLE_DETAILS:

        break;
      default:

        break;
    }
  }

/* _jumpToFoodDetails(RestaurantFoodModel food_entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food_entity),
      ),
    );
  }*/

}