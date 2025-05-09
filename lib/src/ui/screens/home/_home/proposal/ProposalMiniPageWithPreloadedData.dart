import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantMenuPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ProposalMiniWithPreloadedDataPage extends StatefulWidget {
  static var routeName = "/ProposalMiniWithPreloadedDataPage";

  List<ShopProductModel> data = [];

  ProposalMiniWithPreloadedDataPage({Key key, this.data}) : super(key: key);

  @override
  _ProposalMiniWithPreloadedDataPageState createState() =>
      _ProposalMiniWithPreloadedDataPageState();
}

class _ProposalMiniWithPreloadedDataPageState
    extends State<ProposalMiniWithPreloadedDataPage> {
  int _carousselPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: _buildProposalList());
  }

  _buildProposalList() {
    return Column(
      children: [
        Container(
            child: CarouselSlider(
                options: CarouselOptions(
                    height: 115.0,
                    autoPlayAnimationDuration: Duration(seconds: 2),
                    viewportFraction: 1,
                    enableInfiniteScroll: widget?.data?.length != null &&
                        widget?.data?.length > 1,
                    onPageChanged: _carousselPageChanged,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 5)),
                items: widget?.data?.length == null
                    ? []
                    : widget.data.map((position) {
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
                children: <Widget>[]..addAll(List<Widget>.generate(
                      widget?.data?.length == null ? 0 : widget.data.length,
                      (int index) {
                    return Container(
                        margin: EdgeInsets.only(right: 2.5, top: 2.5),
                        height: 7,
                        width: index == _carousselPageIndex ||
                                index == widget.data.length
                            ? 12
                            : 7,
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: new Border.all(color: KColors.primaryColor),
                            color: (index == _carousselPageIndex ||
                                    index == widget.data.length)
                                ? KColors.primaryColor
                                : Colors.transparent));
                  })),
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
                                  image: CachedNetworkImageProvider(
                                      Utils.inflateLink(product?.pic)))),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
