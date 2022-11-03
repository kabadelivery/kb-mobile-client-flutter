import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/models/BestSellerModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ProposalMiniPage extends StatefulWidget {
  static var routeName = "/ProposalMiniPage";

  ProposalPresenter presenter;

  List<ShopProductModel> data;

  CustomerModel customer;

  ProposalMiniPage({Key key, this.title, this.presenter, this.customer})
      : super(key: key);

  final String title;

  @override
  _ProposalMiniPageState createState() => _ProposalMiniPageState();
}

class _ProposalMiniPageState extends State<ProposalMiniPage>
    implements ProposalView {
  int _carousselPageIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.presenter.proposalView = this;
  }

  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;
  bool isDataInflated = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      widget.presenter.fetchProposal(widget.customer);
    } else {
      if (!isDataInflated) {
        inflateProposal(widget.data);
        isDataInflated = true;
      }
    }
    return Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: SizedBox(
                    height: 25, width: 25, child: CircularProgressIndicator()))
            : (hasNetworkError
                ? _buildNetworkErrorPage()
                : hasSystemError
                    ? _buildSysErrorPage()
                    : _buildProposalList()));
  }

  @override
  void inflateProposal(List<ShopProductModel> proposals) {
    showLoading(false);
    setState(() {
      widget.data = proposals;
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
        message: "",
        // "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchProposal(widget?.customer);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "",
        //"""${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchProposal(widget?.customer);
        });
  }

  _buildProposalList() {
    if (widget.data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }
    /*   return Container(
        margin: EdgeInsets.only(bottom: 10, right: 10, left: 10),
        child: ListView.builder(
            addAutomaticKeepAlives: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.data?.length,
            itemBuilder: (BuildContext context, int position) {
              return _buildProposalListItem(position, widget.data[position]);
            }));*/
    return Column(
      children: [
        Container(
            child: CarouselSlider(
                options: CarouselOptions(height: 115.0, autoPlayAnimationDuration: Duration(seconds: 2), viewportFraction: 1, enableInfiniteScroll: true, onPageChanged: _carousselPageChanged, autoPlay: true, autoPlayInterval: Duration(seconds: 5)),
                items: widget.data.map((position) {
                  return Builder(
                    builder: (BuildContext context) {
                      return _buildProposalListItem(position);
                    },
                  );
                }).toList())),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: <Widget>[]..addAll(
                    List<Widget>.generate(widget.data.length,
                            (int index) {
                          return Container(
                              margin: EdgeInsets.only(
                                  right: 2.5, top: 2.5),
                              height: 7,
                              width: index == _carousselPageIndex ||
                                  index == widget.data.length
                                  ? 12
                                  : 7,
                              decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(5)),
                                  border: new Border.all(
                                      color: KColors.primaryColor),
                                  color: (index ==
                                      _carousselPageIndex ||
                                      index == widget.data.length)
                                      ? KColors.primaryColor
                                      : Colors.transparent));
                        })
                  /* add a list of rounded views */
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _carousselPageChanged(int index, CarouselPageChangedReason changeReason) {
    setState(() {
      _carousselPageIndex = index;
    });
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

  _buildProposalListItem(ShopProductModel product) {
    return GestureDetector(
        child: InkWell(
            onTap: () => _jumpToFoodDetails(product),
            child: Container(
                width: MediaQuery.of(context).size.width - 30,
                height: 115,
                margin: EdgeInsets.only(bottom: 15, left: 10, right: 10),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                            color: KColors.new_gray),
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
                                  Text(
                                      "${Utils.capitalize(product?.name?.trim())}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: KColors.new_black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(height: 5),
                                  Text(
                                      "${Utils.capitalize(Utils.replaceNewLineBy(product?.description?.trim(), " / "))}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // added
                                    Row(children: <Widget>[
                                      Text("${product?.price}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              decoration: product.promotion != 0
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: KColors.primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 3),
                                      (product.promotion != 0
                                          ? Text("${product?.promotion_price}",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: KColors.primaryColor,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.normal))
                                          : Container()),
                                      SizedBox(width: 2),
                                      Text(
                                          "${AppLocalizations.of(context).translate('currency')}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: KColors.primaryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ]),
                                    GestureDetector(
                                      onTap: () {
                                        _jumpToFoodDetails(product);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: KColors.primaryColor
                                                .withAlpha(30),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            right: 8,
                                            left: 8),
                                        child: Row(children: <Widget>[
                                          Text(
                                              "${AppLocalizations.of(context).translate("buy")}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: KColors.primaryColor)),
                                          SizedBox(width: 5),
                                          Icon(Icons.add_shopping_cart,
                                              color: KColors.primaryColor,
                                              size: 12),
                                        ]),
                                      ),
                                    ),
                                  ])
                            ]),
                      )),
                      Container(
                        color: KColors.new_gray,
                        child: Container(
                          height: 115,
                          width: 115,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: OptimizedCacheImageProvider(
                                      Utils.inflateLink(product?.pic)))),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
