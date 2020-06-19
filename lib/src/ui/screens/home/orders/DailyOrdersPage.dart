import 'package:KABA/src/contracts/daily_order_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
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


class DailyOrdersPage extends StatefulWidget {

  CustomerModel customer;
  DailyOrderPresenter presenter;

  List<CommandModel> orders;

  DailyOrdersPage({Key key, this.presenter}) : super(key: key);

  @override
  _DailyOrdersPageState createState() => _DailyOrdersPageState();
}

class _DailyOrdersPageState extends State<DailyOrdersPage> implements DailyOrderView {

  @override
  void initState() {
    widget.presenter.dailyOrderView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.loadDailyOrders(customer);
    });
    super.initState();
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
              child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
              _buildOrderList())
          ),
        ));
  }

  _buildOrderList() {

    if (widget?.orders != null && widget?.orders?.length > 0)
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[
              InkWell(onTap: ()=> widget.presenter.loadDailyOrders(widget.customer),
                child: Container(
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding: EdgeInsets.only(right:10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.refresh, color: Colors.white,size: 20)),
                      Text("${AppLocalizations.of(context).translate('refresh')}".toUpperCase(), style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 14))
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
              Text("${AppLocalizations.of(context).translate('no_order_today')}", style: TextStyle(color: Colors.grey)),
            ],
          ));
  }

  @override
  void inflateOrder(List<CommandModel> commands) {
    setState(() {
      widget.orders = commands;
    });
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
}
