import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
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

class _DailyOrdersPageState extends State<DailyOrdersPage> implements DailyOrderView {

  String last_update_timeout = "";

  @override
  void initState() {
    widget.presenter.dailyOrderView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.loadDailyOrders(customer);
    });
    super.initState();
    Future.delayed(Duration.zero,() async {
      last_update_timeout = getTimeOutLastTime();
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
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child:  Container(
              child: isLoading ? Center(child:MyLoadingProgressWidget()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildOrderList())
          ),
        ));
  }

  _buildOrderList() {

    if (widget?.orders != null && widget?.orders?.length > 0)
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
              InkWell(onTap: ()=> widget.presenter.loadDailyOrders(widget.customer),
                child: Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KColors.primaryColorSemiTransparentADDTOBASKETBUTTON,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: EdgeInsets.only(right:10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                       Icon(Icons.refresh, color: KColors.primaryColor,size: 25),
                      SizedBox(width:5),
                      // count down here
                      Text("${last_update_timeout}".toUpperCase(), style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12))
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
            ]),
            SizedBox(height: 15),
          ]
            ..addAll(
                List<Widget>.generate(widget?.orders?.length, (int index) {
                  return MyOrderWidget(command: widget?.orders[index]);
                })
            ),
        ),
      );
    else
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.bookmark_border, color: Colors.grey)),
              SizedBox(height: 5),
              Center(child: Text("${AppLocalizations.of(context).translate('no_order_today')}", style: TextStyle(color: Colors.grey))),
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
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.loadDailyOrders(widget.customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){ widget.presenter.loadDailyOrders(widget.customer); });
  }



  Future<int> _setLastTimeDailyOrderToNow() async {
    StateContainer.of(context).last_time_get_daily_order = DateTime.now().millisecondsSinceEpoch;
  }

  getTimeOutLastTime() {
    if (StateContainer.of(context).last_time_get_daily_order == 0){
      return "";
    } else {
      // time different since last time update
      int diff = (DateTime.now().millisecondsSinceEpoch - StateContainer.of(context).last_time_get_daily_order)~/1000;
      // convert different in minute seconds
      int min = diff~/60;
      int sec = diff%60;
      return "${min < 10 ? "0": ""}${min}:${sec < 10 ? "0": ""}${sec}";
    }
  }

  Timer mainTimer;

  void restartTimer() {
    if (mainTimer != null)
      mainTimer.cancel();
    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        last_update_timeout = getTimeOutLastTime();
      });
    });
  }



}
