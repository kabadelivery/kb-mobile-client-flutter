import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_review_contract.dart';
import 'package:KABA/src/locale/locale.dart';
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantCommentWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/HomePage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/ReviewRestaurantPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class RestaurantDetailsPage extends StatefulWidget {

  static var routeName = "/RestaurantDetailsPage";

  RestaurantModel restaurant;


  CustomerModel customer;

  RestaurantDetailsPresenter presenter;

  int restaurantId;

  List<CommentModel> commentList;

  RestaurantDetailsPage({this.restaurant, this.presenter}) {
    restaurantId = restaurant.id;
  }

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> implements RestaurantDetailsView {

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  bool commentIsLoading = false;
  bool commentHasNetworkError = false;
  bool commentHasSystemError = false;
  bool isUpdatingRestaurantOpenType = false;
  bool _canCommentLoading = false;

  int _canComment = 0;
  int _latentRate = 1;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // check restaurant id and work with it.
    widget.presenter.restaurantDetailsView = this;

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      if (widget.restaurant != null) {
        // fetch comments
        widget.presenter.checkCanComment(customer, widget?.restaurant);
        widget.presenter.fetchCommentList(widget.customer, RestaurantModel(id:widget?.restaurantId));
        // fetch if the restaurant is open
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    final int args = ModalRoute.of(context).settings.arguments;
    if (args != null && args != 0)
      widget.restaurantId = args;
    if (widget.restaurant == null){
      showLoading(true);
      // there must be a food id.
      if (widget.customer != null) {
        widget.restaurant = RestaurantModel(id: widget.restaurantId);
        widget.presenter.fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
      }
      else {
        showLoading(true);
        Future.delayed(Duration(seconds: 1)).then((onValue) {
          widget.restaurant = RestaurantModel(id: widget.restaurantId);
          widget.presenter.fetchRestaurantDetailsById(
              widget.customer, widget.restaurantId);
        });
      }
    }

    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
              child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildPage())
          ),
        ));
  }


  _buildPage () {
    /* use silver-app-bar first */
    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          title: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color:KColors.primaryColor.withAlpha(100)),
            padding: EdgeInsets.all(5),
            child: Text(
                "${widget?.restaurant?.name}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
          ),
          background: Container(
            child: CachedNetworkImage(fit:BoxFit.cover,imageUrl: Utils.inflateLink(widget?.restaurant?.theme_pic)),
          )),
    );
    return DefaultTabController(
        length: 1,
        child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                flexibleSpaceWidget,
              ];
            },
            body:/* Container(
                    child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
                    _buildPage())
                ),*/
            SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(color:Colors.white, padding: EdgeInsets.only(left: 10, right:10, top: 15, bottom: 15),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Opening Time", style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 16)),
                                isUpdatingRestaurantOpenType ? Container() :
                                Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                  Icon(Icons.access_time),
                                  Text(widget?.restaurant?.working_hour, style: TextStyle(color: Colors.black, fontSize: 16)),
                                ])
                              ],
                            ),
                            SizedBox(height: 5),
                            isUpdatingRestaurantOpenType ? SizedBox(width: 40, height: 40,child: CircularProgressIndicator()) : _getRestaurantStateTag(widget.restaurant),
                          ],
                        ),
                      ),
//                        SizedBox(height: 10),
                      SizedBox(height:20),
                      /* rounded image - */
                      Container(
                          height:90, width: 90,
                          decoration: BoxDecoration(
                              border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(Utils.inflateLink(widget?.restaurant?.pic))
                              )
                          )
                      ),
                      SizedBox(height:20),
                      /* see the menu entry */
                      Container(padding: EdgeInsets.only(top: 10,bottom: 10), color: Colors.white,
                        child: InkWell( onTap: (){_jumpToRestaurantMenu(context, widget?.restaurant);},
                            child: Container(padding: EdgeInsets.only(top:5,bottom: 5),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Row(children: <Widget>[SizedBox(width: 15), Icon(Icons.menu, color: KColors.primaryColor), SizedBox(width: 15), Text("See the Menu", style: TextStyle(color:KColors.primaryColor))]),
                                Icon(Icons.chevron_right, color: KColors.primaryColor),
                              ]),
                            )
                        ),
                      ),
                      SizedBox(height:20),
                      Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(10),
                          child:Column(
                            children: <Widget>[
                              /* description of restaurant */
                              Text(widget?.restaurant?.description,
                                style: TextStyle(color: Colors.black, fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Container(
                                child: Row(children: <Widget>[
                                  Icon(Icons.location_on, color: Colors.blue),
                                  Flexible (child: Text(widget?.restaurant?.address, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontSize: 16))),
                                ]),
                              ),

                              /* note this application part - */

                              SizedBox(height: 20),
                              Container(height: 1, width: MediaQuery.of(context).size.width, color: Colors.grey.withAlpha(100)),
                              SizedBox(height: 20),
                              Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("Notes and Reviews", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              _canComment == 1 ? Container(
                                // add a button to review the restaurant.
                                  child:Center(
                                    child:   Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                      IconButton(icon: Icon(_latentRate >= 1 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(1)),
                                      IconButton(icon: Icon(_latentRate >= 2 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(2)),
                                      IconButton(icon: Icon(_latentRate >= 3 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(3)),
                                      IconButton(icon: Icon(_latentRate >= 4 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(4)),
                                      IconButton(icon: Icon(_latentRate >= 5 ? Icons.star : Icons.star_border, color: Colors.yellow, size: 50),onPressed: () => _starPressed(5)),
                                    ]),
                                  )
                              ) : SizedBox(height:20),
                              /* 4.0 - stars */
                              isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
                              _buildCommentList()) ,
                              SizedBox(height:20),
                            ],
                          )
                      ),
                    ]
                      ..add(
                          Container(
                            margin: EdgeInsets.only(top: 15, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.star, size: 20, color: Colors.grey),
                                Text("Powered by >> Kaba Technlogies")
                              ],
                            ),
                          )
                      )
                ))
        ));
  }

  void _jumpToRestaurantMenu (BuildContext context, RestaurantModel restaurantModel) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel, presenter: MenuPresenter()),
      ),
    );
  }

  _buildCommentsList(List<CommentModel> comments) {

    var list = List<Widget>.generate(comments.length, (int index) {
      if (!comments[index].hidden)
        return RestaurantCommentWidget(comment: comments[index]);
      return Container();
    })?.reversed;

    if (list!= null && list != Container()) {
      return list;
    }
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchRestaurantDetailsById(widget.customer, widget.restaurantId); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchRestaurantDetailsById(widget.customer, widget.restaurantId); });
  }

  @override
  void inflateRestaurantDetails(RestaurantModel restaurant) {
    showLoading(false);
    setState(() {
      widget.restaurant = restaurant;
    });
    widget.presenter.fetchCommentList(widget.customer, widget?.restaurant);
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

  @override
  void commentNetworkError() {
    showCommentLoading(false);
    /* show a page of network error. */
    setState(() {
      this.commentHasNetworkError = true;
    });
  }

  @override
  void commentSystemErrorComment() {
    showCommentLoading(false);
    /* show a page of network error. */
    setState(() {
      this.commentHasSystemError = true;
    });
  }

  @override
  void inflateComments(List<CommentModel> comments, String stars, String votes) {
    setState(() {
      if (widget?.restaurant != null) {
        widget.restaurant.stars = double.parse(stars);
        widget.restaurant.votes = int.parse(votes);
      }
      widget.commentList = comments;
    });
    if (widget.commentList?.length > 0) {
      // scroll to bottom
      Timer(Duration(milliseconds: 500), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent*2);
      });
    }
  }

  @override
  void showCommentLoading(bool isLoading) {
    setState(() {
      this.commentIsLoading = isLoading;
      if (isLoading == true) {
        this.commentHasNetworkError = false;
        this.commentHasSystemError = false;
      }
    });
  }

  _buildCommentList() {
    if (widget.commentList == null)
      return Container();
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("${widget.restaurant.stars.toStringAsFixed(1)}", style: TextStyle(fontSize: 100, color: KColors.primaryColor)),
            /* stars */
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(children:  List<Widget>.generate(widget.restaurant.stars.toInt(), (int index) {
                    return Icon(Icons.star, color: KColors.primaryYellowColor);
                  })
                  ),
                  Text("${widget.restaurant.votes} Votes", style: TextStyle(color:Colors.grey))
                ])
          ],
        ),
        /* the list of comments */
      ]..addAll(
          _buildCommentsList(widget.commentList)
      ),
    );
  }

  _getRestaurantStateTag(RestaurantModel restaurantModel) {

    String tagText = "-- --";
    Color tagTextColor = Colors.white;
    Color tagColor = KColors.primaryColor;

    switch(restaurantModel.open_type){
      case 0: // closed
        tagText = "Closed => Preorder";
        break;
      case 1: // open
        tagText = "Opened";
        tagColor = KColors.mGreen;
        break;
      case 2: // paused
        tagText = "Breaktime => Preorder";
        tagColor = KColors.mBlue;
        break;
      case 3: // blocked
        tagText = "Preorder only";
        tagColor = KColors.primaryColor;
        break;
    }

    return   restaurantModel.coming_soon == 0 ? Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
            color: tagColor),
        child:Text(
            tagText,
            style: TextStyle(color: tagTextColor, fontSize: 12)
        )) : Container();
  }

  _reviewRestaurant () async {
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRestaurantPage(restaurant: widget?.restaurant, rate: _latentRate, presenter: RestaurantReviewPresenter()),
      ),
    );
    if (results != null && results.containsKey('ok')) {
      bool feedBackOk = results['ok'];
      if (feedBackOk) {
        setState(() {
          _canComment = 0;
        });
        widget.presenter.fetchCommentList(widget.customer, RestaurantModel(id:widget?.restaurantId));
      }
    }
  }

  @override
  void canComment(int canComment) {
    setState(() {
      this._canComment = canComment;
    });
  }

  @override
  void showCanCommentLoading(bool isLoading) {
    setState(() {
      this._canCommentLoading = isLoading;
    });
  }

  _starPressed(int rate) {
    setState(() {
      _latentRate = rate;
    });
    // after two seconds, i jump to the review activity.
    Future.delayed(Duration(seconds: 1), () {
      _reviewRestaurant();
    });
  }

}
