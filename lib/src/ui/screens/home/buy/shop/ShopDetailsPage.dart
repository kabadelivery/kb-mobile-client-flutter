import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/contracts/login_contract.dart';
import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/contracts/restaurant_review_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/CommentModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantCommentWidget.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantNewCommentWidget.dart';
import 'package:KABA/src/ui/screens/auth/login/LoginPage.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/ui/screens/restaurant/ReviewRestaurantPage.dart';
import 'package:KABA/src/utils/_static_data/ImageAssets.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShopDetailsPage extends StatefulWidget {

  static var routeName = "/ShopDetailsPage";

  ShopModel restaurant;

  CustomerModel customer;

  RestaurantDetailsPresenter presenter;

  int restaurantId;

  List<CommentModel> commentList;

  String shipping_price;

  String distance;

  ShopDetailsPage({this.restaurant, this.restaurantId, this.presenter, this.distance, this.shipping_price}) {
//    restaurantId = restaurant.id;
    if (restaurant != null && restaurant?.id != null) {
      this.restaurantId = restaurant?.id;
    }
  }

  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage>
    implements RestaurantDetailsView {
  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  bool commentIsLoading = false;
  bool commentHasNetworkError = false;
  bool commentHasSystemError = false;
  bool isUpdatingRestaurantOpenType = false;

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
        // we can accept to load the restaurant here if needed
        widget.presenter.checkCanComment(customer, widget?.restaurant);
        widget.presenter.fetchCommentList(
            widget?.customer, ShopModel(id: widget?.restaurantId));
        // fetch if the restaurant is open
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int args = ModalRoute.of(context).settings.arguments;
    if (args != null && args != 0) widget.restaurantId = args;
    if (widget.restaurant == null || widget.restaurant?.name == null) {
      showLoading(true);
      // there must be a food id.
      if (widget.customer != null) {
        widget.restaurant = ShopModel(id: widget.restaurantId);
        widget.presenter
            .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
      } else {
        showLoading(true);
        CustomerUtils.getCustomer().then((customer) {
          widget.customer = customer;
          widget.restaurant = ShopModel(id: widget.restaurantId);
          widget.presenter
              .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
        });
      }
    }

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
          actions: [Container(width: 40)],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('shop_details')}"),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
              child: isLoading
                  ? Center(child: MyLoadingProgressWidget())
                  : (hasNetworkError
                      ? _buildNetworkErrorPage()
                      : hasSystemError
                          ? _buildSysErrorPage()
                          : _buildPageNew())),
        ));
  }

  _buildPageNew() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                height: 9 * MediaQuery.of(context).size.width / 16,
                width: MediaQuery.of(context).size.width,
                color: Colors.redAccent,
                child: Container(
                    height: 9 * MediaQuery.of(context).size.width / 16,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                        imageUrl:
                            Utils.inflateLink(widget.restaurant?.theme_pic),
                        fit: BoxFit.cover)),
              ),
              SingleChildScrollView(
                  child: Column(children: <Widget>[
                SizedBox(
                  height: 9 * MediaQuery.of(context).size.width / 16 - 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, top: 10, bottom: 5),
                          child: Column(
                            children: [
                              Row(children: [
                                Expanded(
                                    flex: 8,
                                    child: Text(
                                        "${widget?.restaurant?.name}"
                                            ?.toUpperCase(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 15))),
                                Expanded(flex: 2, child: Container()),
                                isUpdatingRestaurantOpenType
                                    ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator())
                                    : _getRestaurantStateTag(widget.restaurant)
                              ]),
                              SizedBox(
                                height: 5,
                              ),
                              Row(children: [
                                Icon(
                                  Icons.location_on,
                                  color: KColors.mBlue,
                                  size: 15,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Text("${widget?.restaurant?.address}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                )
                              ]),
                              SizedBox(height: 10),
                              widget?.distance == null ?    Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: KColors.new_gray),
                                    child: Row(
                                      children: [
                                        Icon(FontAwesomeIcons.locationArrow,
                                            color: KColors.mGreen, size: 10),
                                        SizedBox(width: 10),
                                        Text(
                                            "--- ${AppLocalizations.of(context).translate('km')}",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: KColors.new_gray),
                                    child: Row(
                                      children: [
                                        Icon(Icons.directions_bike_outlined,
                                            color: KColors.primaryColor,
                                            size: 10),
                                        SizedBox(width: 10),
                                        Text(
                                            "--- ${AppLocalizations.of(context).translate('currency')}",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  )
                                ],
                              ) : Container(),
                              SizedBox(height: 10),
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: KColors.new_gray),
                              SizedBox(height: 15),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${AppLocalizations.of(context).translate('note_reviews')}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          /* stars */
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                    children:
                                                        List<Widget>.generate(
                                                            widget.restaurant
                                                                .stars
                                                                .toInt(),
                                                            (int index) {
                                                  return Icon(
                                                    FontAwesomeIcons.solidStar,
                                                    color: KColors
                                                        .primaryYellowColor,
                                                    size: 20,
                                                  );
                                                })),
                                                SizedBox(height: 5),
                                                RichText(
                                                    text: TextSpan(
                                                        text:
                                                            " ${widget.restaurant.votes} ",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: KColors
                                                                .primaryColor),
                                                        children: [
                                                      TextSpan(
                                                          text:
                                                              "${AppLocalizations.of(context).translate('votes')}",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey))
                                                    ])),
                                              ]),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                  "${widget.restaurant.stars.toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                            ),
                                          ),
                                          _canComment == 1
                                              ? InkWell(
                                            onTap: () => _starPressed(3),
                                                  child: Container(
                                                    child: Text(
                                                        "${AppLocalizations.of(context).translate('review_us')}",
                                                        style: TextStyle(
                                                            color: KColors
                                                                .primaryColor,
                                                            fontSize: 12)),
                                                    decoration: BoxDecoration(
                                                        color: KColors
                                                            .primaryColor
                                                            .withAlpha(30),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 20),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),

                                      // personnal

                                      commentIsLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : (commentHasSystemError
                                              ? _buildCommentNetworkErrorPage()
                                              : commentHasNetworkError
                                                  ? _buildCommentSysErrorPage()
                                                  : Column(children: <Widget>[
                                                      isLoading
                                                          ? Container()
                                                          : _buildNewCommentList()
                                                    ])
                                          // personnal end
                                          )
                                    ]),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ])),
            ],
          ),
        ),
      ],
    );
  }

  _buildPage() {
    /* use silver-app-bar first */
    double expandedHeight = 9 * MediaQuery.of(context).size.width / 16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          title: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(7)),
                color: KColors.primaryColor.withAlpha(100)),
            padding: EdgeInsets.all(5),
            child: Text("${widget?.restaurant?.name}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
          ),
          background: Container(
            child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: Utils.inflateLink(widget?.restaurant?.theme_pic)),
          )),
    );
    return DefaultTabController(
        length: 1,
        child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                flexibleSpaceWidget,
              ];
            },
            body: /* Container(
                    child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
                    _buildPage())
                ),*/
                SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 15),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        "${AppLocalizations.of(context).translate('opening_time')}",
                                        style: TextStyle(
                                            color: Colors.black.withAlpha(150),
                                            fontSize: 16)),
                                    isUpdatingRestaurantOpenType
                                        ? Container()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                                Icon(Icons.access_time),
                                                Text(
                                                    "${widget?.restaurant?.working_hour}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                              ])
                                  ],
                                ),
                                SizedBox(height: 5),
                                isUpdatingRestaurantOpenType
                                    ? SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator())
                                    : _getRestaurantStateTag(widget.restaurant),
                              ],
                            ),
                          ),
//                        SizedBox(height: 10),
                          SizedBox(height: 20),
                          /* rounded image - */
                          InkWell(
                            onTap: () =>
                                _seeProfilePicture(widget?.restaurant?.pic),
                            child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                    border: new Border.all(
                                        color: KColors.primaryYellowColor,
                                        width: 2),
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            Utils.inflateLink(
                                                widget?.restaurant?.pic))))),
                          ),
                          SizedBox(height: 20),
                          /* see the menu entry */
                          Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            color: Colors.white,
                            child: InkWell(
                                onTap: () {
                                  _jumpToRestaurantMenu(
                                      context, widget?.restaurant);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          SizedBox(width: 15),
                                          Icon(Icons.menu,
                                              color: KColors.primaryColor),
                                          SizedBox(width: 15),
                                          Text(
                                              "${AppLocalizations.of(context).translate('see_menu')}"
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: KColors.primaryColor))
                                        ]),
                                        Icon(Icons.chevron_right,
                                            color: KColors.primaryColor),
                                      ]),
                                )),
                          ),
                          SizedBox(height: 20),
                          Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  /* description of restaurant */
                                  Text(
                                    "${widget?.restaurant?.description}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Row(children: <Widget>[
                                      Icon(Icons.location_on,
                                          color: Colors.blue),
                                      Flexible(
                                          child: Text(
                                              "${widget?.restaurant?.address}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16))),
                                    ]),
                                  ),

                                  /* note this application part - */

                                  SizedBox(height: 20),
                                  Container(
                                      height: 1,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.grey.withAlpha(100)),
                                  SizedBox(height: 20),
                                  StateContainer.of(context).loggingState == 1
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                "${AppLocalizations.of(context).translate('note_reviews')}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ],
                                        )
                                      : Container(),
                                  /* 4.0 - stars */
                                  SizedBox(height: 20),
                                  commentIsLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : (commentHasSystemError
                                          ? _buildCommentNetworkErrorPage()
                                          : commentHasNetworkError
                                              ? _buildCommentSysErrorPage()
                                              : Column(children: <Widget>[
                                                  _canComment == 1
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 20),
                                                          child: Text(
                                                              "${AppLocalizations.of(context).translate('review_us')}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: KStyles
                                                                  .hintTextStyle_gray))
                                                      : Container(),
                                                  SizedBox(height: 10),
                                                  _canComment == 1
                                                      ? Container(
                                                          // add a button to review the restaurant.
                                                          child: Center(
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                IconButton(
                                                                    icon: Icon(
                                                                        _latentRate >=
                                                                                1
                                                                            ? Icons
                                                                                .star
                                                                            : Icons
                                                                                .star_border,
                                                                        color: KColors
                                                                            .primaryYellowColor,
                                                                        size:
                                                                            50),
                                                                    onPressed: () =>
                                                                        _starPressed(
                                                                            1)),
                                                                IconButton(
                                                                    icon: Icon(
                                                                        _latentRate >=
                                                                                2
                                                                            ? Icons
                                                                                .star
                                                                            : Icons
                                                                                .star_border,
                                                                        color: KColors
                                                                            .primaryYellowColor,
                                                                        size:
                                                                            50),
                                                                    onPressed: () =>
                                                                        _starPressed(
                                                                            2)),
                                                                IconButton(
                                                                    icon: Icon(
                                                                        _latentRate >=
                                                                                3
                                                                            ? Icons
                                                                                .star
                                                                            : Icons
                                                                                .star_border,
                                                                        color: KColors
                                                                            .primaryYellowColor,
                                                                        size:
                                                                            50),
                                                                    onPressed: () =>
                                                                        _starPressed(
                                                                            3)),
                                                                IconButton(
                                                                    icon: Icon(
                                                                        _latentRate >=
                                                                                4
                                                                            ? Icons
                                                                                .star
                                                                            : Icons
                                                                                .star_border,
                                                                        color: KColors
                                                                            .primaryYellowColor,
                                                                        size:
                                                                            50),
                                                                    onPressed: () =>
                                                                        _starPressed(
                                                                            4)),
                                                                IconButton(
                                                                    icon: Icon(
                                                                        _latentRate >=
                                                                                5
                                                                            ? Icons
                                                                                .star
                                                                            : Icons
                                                                                .star_border,
                                                                        color: KColors
                                                                            .primaryYellowColor,
                                                                        size:
                                                                            50),
                                                                    onPressed: () =>
                                                                        _starPressed(
                                                                            5)),
                                                              ]),
                                                        ))
                                                      : SizedBox(height: 20),
                                                  isLoading
                                                      ? Container()
                                                      : _buildCommentList(),
                                                ])),
                                  SizedBox(height: 20),
                                ],
                              )),
                        ]..add(Container(
                            margin: EdgeInsets.only(top: 30, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                                Icon(Icons.te, size: 20, color: KColors.primaryColor),
                                Text(
                                  "${AppLocalizations.of(context).translate('powered_by_kaba_tech')}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              ],
                            ),
                          ))))));
  }

  void _jumpToRestaurantMenu(BuildContext context, ShopModel restaurantModel) {
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantMenuPage(restaurant: restaurantModel, presenter: MenuPresenter()),
      ),
    );*/

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                restaurant: restaurantModel, presenter: MenuPresenter()),
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

  _buildNewCommentsList(List<CommentModel> comments) {
    if (comments != null) {
      List<Widget> list = List<Widget>.generate(comments?.length, (int index) {
        if (!comments[index].hidden)
          return RestaurantNewCommentWidget(comment: comments[index]);
        return Container();
      }).toList()?.reversed.toList();

      if (list != null) {
        return list;
      } else {
        return <Widget>[Container()];
      }
    } else
      return <Widget>[Container()];
  }

  _buildCommentsList(List<CommentModel> comments) {
    if (comments != null) {
      var list = List<Widget>.generate(comments?.length, (int index) {
        if (!comments[index].hidden)
          return RestaurantCommentWidget(comment: comments[index]);
        return Container();
      })?.reversed;

      if (list != null) {
        return list;
      }
    } else
      return <Widget>[Container()];
  }

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter
              .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter
              .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
        });
  }

  _buildCommentSysErrorPage() {
    if (StateContainer.of(context).loggingState == 0) return Container();
    return ErrorPage(
        error_text_font_size: 12,
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter
              .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
        });
  }

  _buildCommentNetworkErrorPage() {
    if (StateContainer.of(context).loggingState == 0) return Container();
    return ErrorPage(
        error_text_font_size: 12,
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter
              .fetchRestaurantDetailsById(widget.customer, widget.restaurantId);
        });
  }

  @override
  void inflateRestaurantDetails(ShopModel restaurant) {
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
  void inflateComments(
      List<CommentModel> comments, String stars, String votes) {
    setState(() {
      if (widget?.restaurant != null) {
        widget.restaurant.stars = double.parse(stars);
        widget.restaurant.votes = int.parse(votes);
      }
      widget.commentList = comments;
    });
    if (widget.commentList?.length > 0) {
      // scroll to bottom
      /*   Timer(Duration(milliseconds: 800), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent*2);
      });*/
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

  _buildNewCommentList() {
    if (widget.commentList == null) return Container();
    return Column(
      children: _buildNewCommentsList(widget.commentList),
    );
  }

  _buildCommentList() {
    if (widget.commentList == null) return Container();
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        Text(
            "- ${widget.restaurant?.name} ${AppLocalizations.of(context).translate('review')} -",
            textAlign: TextAlign.center,
            style: KStyles.hintTextStyle_gray),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("${widget.restaurant.stars.toStringAsFixed(1)}",
                style: TextStyle(fontSize: 100, color: KColors.primaryColor)),
            /* stars */
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                      children: List<Widget>.generate(
                          widget.restaurant.stars.toInt(), (int index) {
                    return Icon(FontAwesomeIcons.solidStar,
                        color: KColors.primaryYellowColor);
                  })),
                  Text(
                      "${widget.restaurant.votes} ${AppLocalizations.of(context).translate('votes')}",
                      style: TextStyle(color: Colors.grey))
                ])
          ],
        ),
        /* the list of comments */
      ]..addAll(_buildCommentsList(widget.commentList)),
    );
  }

  _getRestaurantStateTag(ShopModel shopModel) {
    String tagText = "-- --";
    Color tagTextColor = Colors.white;

    switch (shopModel?.open_type) {
      case 0: // closed
        tagText = "${AppLocalizations.of(context).translate('t_closed')}";
        tagTextColor = KColors.mBlue;
        break;
      case 1: // open
        tagText = "${AppLocalizations.of(context).translate('t_opened')}";
        tagTextColor = CommandStateColor.delivered;
        break;
      case 2: // paused
        tagText = "${AppLocalizations.of(context).translate('t_paused')}";
        tagTextColor = KColors.mBlue;
        break;
      case 3: // blocked
        tagText = "${AppLocalizations.of(context).translate('t_unavailable')}";
        tagTextColor = KColors.mBlue;
        break;
    }

    return shopModel.coming_soon == 0
        ? Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: tagTextColor),
            child: Text(Utils.capitalize("${tagText}"),
                style: TextStyle(color:  Colors.white, fontSize: 12)))
        : Container();
  }

  _reviewRestaurant() async {
    Map results = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRestaurantPage(
            restaurant: widget?.restaurant,
            rate: _latentRate,
            presenter: RestaurantReviewPresenter()),
      ),
    );
    if (results != null && results.containsKey('ok')) {
      bool feedBackOk = results['ok'];
      if (feedBackOk) {
        setState(() {
          _canComment = 0;
        });
        if (widget?.restaurant?.id != null)
          widget.restaurantId = widget?.restaurant?.id;
        widget.presenter.fetchCommentList(
            widget.customer, ShopModel(id: widget?.restaurantId));
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
      this.commentIsLoading = isLoading;
    });
  }

  _starPressed(int rate) {
    if (StateContainer.of(context).loggingState == 0) {
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
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                new AssetImage(ImageAssets.login_description),
                          ))),
                  SizedBox(height: 10),
                  Text(
                      "${AppLocalizations.of(context).translate("please_login_before_going_forward_description_comment")}",
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
      setState(() {
        _latentRate = rate;
      });
      // after two seconds, i jump to the review activity.
      Future.delayed(Duration(seconds: 1), () {
        _reviewRestaurant();
      });
    }
  }

  
  
  _seeProfilePicture(String imageLink) {
    List<AdModel> slider = [AdModel(pic: "${imageLink}")];

    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AdsPreviewPage(
            data: slider, position: 0, presenter: AdsViewerPresenter()),
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
