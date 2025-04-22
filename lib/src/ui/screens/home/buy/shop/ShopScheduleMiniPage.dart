import 'package:KABA/src/contracts/menu_contract.dart';
import 'package:KABA/src/contracts/shop_schedule_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/ShopScheduleModel.dart';
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

class ShopScheduleMiniPage extends StatefulWidget {
  static var routeName = "/ShopScheduleMiniPage";

  ShopSchedulePresenter? presenter;

  List<ShopScheduleModel>? data;

  int? restaurant_id;

  ShopScheduleMiniPage({Key? key, this.restaurant_id, this.presenter})
      : super(key: key);

  @override
  _ShopScheduleMiniPageState createState() => _ShopScheduleMiniPageState();
}

class _ShopScheduleMiniPageState extends State<ShopScheduleMiniPage>
    implements ShopScheduleView {
  @override
  void initState() {
    super.initState();
    widget.presenter!.shopScheduleView = this;
  }

  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;
  bool isDataInflated = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      widget.presenter!.fetchShopSchedule(widget.restaurant_id!);
    } else {
      if (!isDataInflated) {
        inflateShopSchedule(widget.data!);
        isDataInflated = true;
      }
    }
    return Container(
        child: isLoading
            ? Center(
                child: SizedBox(
                    height: 25, width: 25, child: CircularProgressIndicator()))
            : (hasNetworkError
                ? _buildNetworkErrorPage()
                : hasSystemError
                    ? _buildSysErrorPage()
                    : _buildShopSchedule()));
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
        message: "${AppLocalizations.of(context)!.translate('system_error')}",
        onClickAction: () {
          widget.presenter!.fetchShopSchedule(widget.restaurant_id!);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)!.translate('network_error')}",
        onClickAction: () {
          widget.presenter!.fetchShopSchedule(widget.restaurant_id!);
        });
  }

  _buildShopSchedule() {
    if (widget.data == null) {
      /* just show empty page. */
      return _buildSysErrorPage();
    }

    int dday = DateTime.now().weekday;

    // return Center(
    //   child: Container(
    //       child: RichText(
    //           text: TextSpan(
    //               text: "",
    //               children: []
    //                 ..addAll(List.generate(widget.data?.length, (index) {
    //                  ShopScheduleModel model = widget.data[index];
    //                  return TextSpan(text:"${_dayFromModel(model)}  ${model.start} - ${model.end}\n".toUpperCase(),
    //                      style: TextStyle(color: dday == model.day ? KColors.primaryColor : Colors.grey,
    //                          fontSize: 12, fontWeight: FontWeight.bold));
    //                 }))))),
    // );
    return Column(
        children: []..addAll(List.generate(widget.data!.length!, (index) {
            ShopScheduleModel model = widget.data![index];
            return Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                        width: 30,
                        child: Text("${_dayFromModel(model)}".toUpperCase(),
                            style: TextStyle(
                                color: dday == model.day
                                    ? KColors.primaryColor
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 10),
                    Container(
                        child: Text(
                            model.open == 1
                                ? "${model.start} - ${model.end}"
                                : "${AppLocalizations.of(context)!.translate('restaurant_closed')}",
                            style: TextStyle(
                                color: dday == model.day
                                    ? KColors.primaryColor
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)))
                  ],
                ));
          })));
  }

  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  _jumpToFoodDetails(ShopProductModel food) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RestaurantMenuPage(
                presenter: MenuPresenter(MenuView()),
                menuId: int.parse(food.menu_id!),
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

  @override
  void inflateShopSchedule(List<ShopScheduleModel> shopSchedule) {
    showLoading(false);
    setState(() {
      widget.data = shopSchedule;
    });
  }

  _dayFromModel(ShopScheduleModel model) {
    String day = "unknown";

    switch (model.day) {
      case 1:
        day = "monday_short";
        break;
      case 2:
        day = "tuesday_short";
        break;
      case 3:
        day = "wednesday_short";
        break;
      case 4:
        day = "thursday_short";
        break;
      case 5:
        day = "friday_short";
        break;
      case 6:
        day = "saturday_short";
        break;
      case 7:
        day = "sunday_short";
    }

    return AppLocalizations.of(context)!.translate(day);
  }
}
