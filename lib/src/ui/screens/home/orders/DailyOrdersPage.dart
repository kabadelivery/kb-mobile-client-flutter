import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyNewOrderWidget.dart';
import 'package:KABA/src/ui/screens/home/orders/LastOrdersPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/UserTokenModel.dart';
import 'package:KABA/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../xrint.dart';

class DailyOrdersPage extends StatefulWidget {
  CustomerModel customer;
  DailyOrderPresenter presenter;

  List<CommandModel> orders;

  DailyOrdersPage({Key key, this.presenter}) : super(key: key);

  @override
  _DailyOrdersPageState createState() => _DailyOrdersPageState();
}

class _DailyOrdersPageState extends State<DailyOrdersPage>
    implements DailyOrderView {
  // String last_update_timeout = "";

  int MAX_MINUTES_FOR_AUTO_RELOAD = 5;
  bool is_out_of_app_order = false;
  @override
  void initState() {
    widget.presenter.dailyOrderView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.loadDailyOrders(customer);
    });
    super.initState();
    Future.delayed(Duration.zero, () async {
      // last_update_timeout = getTimeOutLastTime();
    });
  }

  @override
  void dispose() {
    mainTimer.cancel();
    super.dispose();
  }

  bool isLoading = true;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
         centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('orders')}"),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),

        body: Column(
          children: [
            //choose type
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: 40,

                width: MediaQuery.of(context).size.width*.95,
                decoration: BoxDecoration(
                    color: Color(0x6EC5C5C5),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(is_out_of_app_order==true){
                          widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: false);
                        }
                        setState(() {
                          is_out_of_app_order=false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        height: 40,
                        width: (MediaQuery.of(context).size.width*.95)/2,
                        decoration: BoxDecoration(
                            color: is_out_of_app_order==true?
                            Colors.transparent:
                            KColors.primaryColor,
                            borderRadius: BorderRadius.only(
                                topLeft:Radius.circular(10),
                                bottomLeft:Radius.circular(10)
                            )
                        ),
                        child: Text(
                            "${AppLocalizations.of(context).translate('normal_orders')}",
                            style: TextStyle(
                                fontSize: 15,
                                color:is_out_of_app_order==false? Colors.white :KColors.new_black)),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        if(is_out_of_app_order==false){
                          widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: true);
                        }
                        setState(() {
                          is_out_of_app_order=true;
                        });
                      },
                      child:  AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        height: 40,
                        width: (MediaQuery.of(context).size.width*.95)/2,
                        decoration: BoxDecoration(
                            color: is_out_of_app_order==true?
                            KColors.primaryColor:
                            Colors.transparent,
                            borderRadius: BorderRadius.only(
                                topRight:Radius.circular(10),
                                bottomRight:Radius.circular(10)
                            )
                        ),
                        child:  Text(
                            "${AppLocalizations.of(context).translate('out_of_app_orders')}",
                            style: TextStyle(
                                fontSize: 15,
                                color:is_out_of_app_order==true? Colors.white :Colors.grey)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: Container(
                height: MediaQuery.of(context).size.height*.77,
                  child: isLoading
                      ? Center(child: MyLoadingProgressWidget())
                      : (hasNetworkError
                          ? _buildNetworkErrorPage()
                          : hasSystemError
                              ? _buildSysErrorPage()
                              : _buildOrderList())),
            ),
          ],
        ));
  }

  _buildOrderList() {
    if (widget?.orders != null && widget?.orders?.length > 0)
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),

            //build out of app
            //build normalOrder List
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              InkWell(
                onTap: () {
                  if(is_out_of_app_order==true)
                    widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: true);
                  else
                      widget.presenter.loadDailyOrders(widget.customer);
                },
                child: Container(
                  // width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KColors.primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.refresh,
                          color: KColors.primaryColor, size: 20),
                      SizedBox(width: 5),
                      // count down here
                      Text(
                          Utils.capitalize(
                              "${AppLocalizations.of(context).translate('refresh')}"),
                          style: TextStyle(
                              color: KColors.primaryColor,
                              fontWeight: FontWeight.normal,
                              fontSize: 13))
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
            ]),
            SizedBox(height: 15),
          ]
            ..add(widget?.orders?.length > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Text(
                              "${AppLocalizations.of(context).translate('today')}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3)),
                    ],
                  )
                : Container())
            ..addAll(List<Widget>.generate(widget?.orders?.length, (int index) {
              return MyNewOrderWidget(command: widget?.orders[index]);
            }))
            ..add(GestureDetector(
              onTap: () => _jumpToPage(context, LastOrdersPage()),
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rotate_left, color: KColors.mBlue),
                        SizedBox(width: 5),
                        Text(
                            "${AppLocalizations.of(context).translate('see_order_history')}",
                            style:
                                TextStyle(color: KColors.mBlue, fontSize: 13))
                      ],
                    ),
                  )),
            )),
        ),
      );
    else
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(icon: Icon(Icons.bookmark_border, color: Colors.grey)),
          SizedBox(height: 5),
          Center(
              child: Text(
                  "${AppLocalizations.of(context).translate('no_order_today')}",
                  style: TextStyle(color: Colors.grey, fontSize: 14))),
        ],
      ));
  }

  @override
  void inflateOrder(List<CommandModel> commands) {
    setState(() {
      widget.orders = commands;
      // keep now timestamp as last time update happened
      _setLastTimeDailyOrderToNow();
    });
    // start timer to decrement this value
    restartTimer();
  }

  @override
  void networkError() {
    setState(() {
      hasNetworkError = true;
    });
  }

  @override
  void systemError() {
    setState(() {
      hasSystemError = true;
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

  _buildSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('system_error')}",
        onClickAction: () {
          widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: is_out_of_app_order);
        });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context).translate('network_error')}",
        onClickAction: () {
          widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: is_out_of_app_order);
        });
  }

  Future<int> _setLastTimeDailyOrderToNow() async {
    StateContainer.of(context).last_time_get_daily_order =
        DateTime.now().millisecondsSinceEpoch;
  }

  getTimeOutLastTime() {
    if (StateContainer.of(context).last_time_get_daily_order == 0) {
      return "";
    } else {
      // time different since last time update
      int diff = (DateTime.now().millisecondsSinceEpoch -
              StateContainer.of(context).last_time_get_daily_order) ~/
          1000;
      // convert different in minute seconds
      int min = diff ~/ 60;
      int sec = diff % 60;
      return "${min < 10 ? "0" : ""}${min}:${sec < 10 ? "0" : ""}${sec}";
    }
  }

  Timer mainTimer;

  void restartTimer() {
    if (mainTimer != null) mainTimer.cancel();

    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      xrint("dailyorder this page is --> " +
          ModalRoute.of(context).settings.name);
      xrint("dailyorder is_current is --> ${ModalRoute.of(context).isCurrent}");

      if (!("/HomePage".compareTo(ModalRoute.of(context).settings.name) == 0 &&
          ModalRoute.of(context).isCurrent)) {
        // check if time is ok
        xrint("dailyorder NO exec timer ");
        return;
      }
      xrint("dailyorder exec timer ");
      // setState(() {
      //   last_update_timeout = getTimeOutLastTime();
      // });

      int POTENTIAL_EXECUTION_TIME = 3;
      int diff = (DateTime.now().millisecondsSinceEpoch -
              StateContainer.of(context).last_time_get_daily_order) ~/
          1000;
      // convert different in minute seconds
      int min = (diff + POTENTIAL_EXECUTION_TIME) ~/ 60;

      if (min >= MAX_MINUTES_FOR_AUTO_RELOAD)
        widget.presenter.loadDailyOrders(widget.customer,is_out_of_app_order: is_out_of_app_order);
    });
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
