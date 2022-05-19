import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/MoneyTransactionModel.dart';
import 'package:KABA/src/models/PointObjModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyNormalLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../StateContainer.dart';


class TransactionHistoryPage extends StatefulWidget {

  static var routeName = "/TransactionHistoryPage";

  TransactionPresenter presenter;

  CustomerModel customer;

  TransactionHistoryPage({Key key, this.title, this.presenter}) : super(key: key);

  final String title;

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();

}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> with TransactionView, SingleTickerProviderStateMixin {

  List<MoneyTransactionModel> moneyData;
  PointObjModel pointData = null;


  String balance, kaba_points;

  TabController _tabController;

  var TABS_LENGTH = 2;

  String currentMonth ="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.presenter.transactionView = this;
    _tabController = TabController(vsync: this, length: TABS_LENGTH);
    /*  _tabController.addListener(() {
      _handleTabSelection();
    });*/

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;

      // fetch transaction as the first page
      widget.presenter.fetchMoneyTransaction(customer);
      // only fetch point when we press on the other button
      widget.presenter.checkBalance(customer);
    });
    _tabController.addListener(_handleTabSelection);

  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
        /* we know that we have to init / load data from specific page */
          break;
        case 1:
          if (pointData == null) {
            widget.presenter.fetchPointTransaction(widget.customer);
          }
          /* we know that we have to init / load data from specific page */
          break;
      }
    }
  }

  bool isMoneyLoading = true;
  bool isMoneyBalanceLoading = false;
  bool hasMoneySystemError = false;
  bool hasMoneyNetworkError = false;

  bool isPointTopLoading = false;
  bool isPointPageLoading = true; // to make sure when the tab is switched, the page is loading already
  bool hasPointSystemError = false;
  bool hasPointNetworkError = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (currentMonth == "") {
      try {
        xrint("current month ${DateTime.now().month}");
        xrint("mois_${DateTime.now().month}");

        currentMonth = "${AppLocalizations.of(context)?.translate("mois_${DateTime.now().month}")}";
      } catch(_) {
        xrint(_.toString());
        currentMonth = "This month";
      }
    }

    return
      DefaultTabController(
          length: TABS_LENGTH,
          child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: KColors.primaryColor,
                  tabs: [
                    Tab(child : Center(child:
                    Row(mainAxisSize: MainAxisSize.min,children:
                    [
                      Text("${AppLocalizations.of(context)?.translate('balance')}", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold)),
                      SizedBox(width:5),
                      Icon( Icons.attach_money, color: Colors.black),
                      SizedBox(width:5),
                      isMoneyBalanceLoading || isMoneyLoading ? MyNormalLoadingProgressWidget(isMini:true) : Container()
                    ]))),

                    Tab(
                        child: Center(child:
                        Row(mainAxisSize: MainAxisSize.min,children:
                        [
                          Text("${AppLocalizations.of(context)?.translate('points')}", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold)),
                          SizedBox(width:5),
                          Icon( Icons.control_point, color: Colors.black),
                          SizedBox(width:5),
                          isPointTopLoading ? MyNormalLoadingProgressWidget(isMini:true) : Container()
                        ])))
                  ],
                ),
                brightness: Brightness.light,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                backgroundColor: Colors.white,
                title: Text("${AppLocalizations.of(context)?.translate('my_balance')}", style:TextStyle(color:KColors.primaryColor, fontSize: 16)),
                actions: <Widget>[
                ],
              ),
              body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    Container(
                        child: isMoneyBalanceLoading || isMoneyLoading ? Center(child:MyLoadingProgressWidget()) : (hasMoneyNetworkError ? _buildMoneyNetworkErrorPage() : hasMoneySystemError ? _buildMoneySysErrorPage():
                        _buildMoneyTransactionHistoryList())
                    ),
                    Container(
                        child: isPointPageLoading ?
                        Center(child:MyLoadingProgressWidget())
                            : (
                            hasPointNetworkError ? _buildPointNetworkErrorPage() :
                            (hasPointNetworkError ? _buildPointSysErrorPage():
                            _buildPointTransactionHistoryList()))
                    ),
                  ]
              )
          ));
  }



  @override
  void inflatePointModelObj(PointObjModel pointModel) {

    showPointloading(false);

    setState(() {
      this.pointData = pointModel;
    });
  }


  @override
  void networkPointError({int delay = 0}) {
    // showPointloading(false);
    /* show a page of network error. */
    Future.delayed(Duration(seconds: delay), (){
      setState(() {
        this.isPointPageLoading = false;
        this.isPointTopLoading = false;
        this.hasPointNetworkError = true;
      });
    });
  }

  @override
  void showPointloading(bool isLoading) {
    setState(() {
      this.isPointPageLoading = isLoading;
      this.isPointTopLoading = isLoading;
      if (isLoading == true) {
        this.hasPointNetworkError = false;
        this.hasPointSystemError = false;
      }
    });
  }

  @override
  void systemPointError() {
    showPointloading(false);
    /* show a page of network error. */
    setState(() {
      this.hasPointSystemError = true;
    });
  }


  @override
  void inflateMoneyTransaction(List<MoneyTransactionModel> transactions) {

    showMoneyLoading(false);

    setState(() {
      this.moneyData = transactions.reversed.toList();
    });
  }

  @override
  void networkMoneyError() {
    showMoneyLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasMoneyNetworkError = true;
    });
  }

  @override
  void showMoneyLoading(bool isLoading) {
    setState(() {
      this.isMoneyLoading = isLoading;
      if (isLoading == true) {
        this.hasMoneyNetworkError = false;
        this.hasMoneySystemError = false;
      }
    });
  }

  @override
  void systemMoneyError() {
    showMoneyLoading(false);
    /* show a page of network error. */
    setState(() {
      this.hasMoneySystemError = true;
    });
  }


  _buildPointTransactionHistoryList() {
    if (pointData == null/* || pointData?.last_ten_transactions?.length == 0*/)
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.monetization_on, color: Colors.grey)),
              SizedBox(height: 5),
              Text("${AppLocalizations.of(context)?.translate('sorry_empty_transactions')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ));

    // send a first card_view that shows the solde, then below we add the transactions stuffs
    return  ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withAlpha(50),
        ),
        itemCount: pointData?.last_ten_transactions?.length == 0 ? 1 : pointData?.last_ten_transactions?.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              index == 0 ? Center(
                child: Card(margin: EdgeInsets.only(top:10, bottom: 10, left:15,right:15),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top:15,left:10, right:10, bottom: 10),
                        width: MediaQuery.of(context).size.width*0.9,
                        child: Column(
                          children: [
                            SizedBox(height:5),
                            Center(child:Text(pointData?.is_eligible ? "${AppLocalizations.of(context)?.translate('kaba_point_description')}".replaceAll("XXX_XXX", "${pointData?.monthly_limit_amount}") :
                            "${AppLocalizations.of(context)?.translate("use_of_kaba_points_not_eligible")}", textAlign: TextAlign.center, style: TextStyle( color: Colors.grey, fontSize: 11))),
                            SizedBox(height:5),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Text("${AppLocalizations.of(context)?.translate('kaba_points')}", style: TextStyle(fontSize: 24)),
                                    ]),
                                    SizedBox(height:5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Text("${AppLocalizations.of(context)?.translate('month_used_kaba_points')}".replaceAll("XXX_XXX",
                                          currentMonth), style: TextStyle(fontSize: 18, color: KColors.primaryColor)),

                                    ]),
                                    SizedBox(height:5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Text("${AppLocalizations.of(context)?.translate('month_remain_kaba_points')}".replaceAll("XXX_XXX",
                                          currentMonth), style: TextStyle(fontSize: 18, color: CommandStateColor.delivered)),
                                    ])
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Row(
                                        children: [
                                          Text("${pointData?.balance == null ? "---" : pointData?.balance}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                                        ],
                                      ),
                                    ]),
                                    SizedBox(height:5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Row(
                                        children: [
                                          Text("${pointData?.amount_already_used == null ? "---" : pointData?.amount_already_used}", style: TextStyle(fontSize: 18, color: KColors.primaryColor)),
                                        ],
                                      ),
                                    ]),
                                    SizedBox(height:5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      Row(
                                        children: [
                                          Text("${pointData?.balance == null || pointData?.amount_already_used == null ? "---" : _getRemainingPointToUse(pointData)}", style: TextStyle(fontSize: 18, color: CommandStateColor.delivered)),
                                        ],
                                      ),
                                    ])
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(height: 20),
                      pointData?.is_eligible ? Container() : RawMaterialButton(onPressed: () => mToast("${AppLocalizations.of(context)?.translate('kaba_point_description')}".replaceAll("XXX_XXX", "${pointData?.monthly_limit_amount}")),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey),
                                SizedBox(width: 5),
                                Text("${AppLocalizations.of(context)?.translate('your_points')}", style: TextStyle( color: Colors.grey)),
                              ])),
                      false ? RawMaterialButton(onPressed: () => mToast("${AppLocalizations.of(context)?.translate('non_eligible_reason')}"),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey),
                              SizedBox(width: 5),
                              Text("${AppLocalizations.of(context)?.translate('non_eligible')}", style: TextStyle( color: Colors.grey)),
                            ]),
                      ) : Container(),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ) : Container(),

              pointData?.last_ten_transactions?.length > 0 ?
              Column(
                children: [
                  ListTile(
                    leading: pointData?.last_ten_transactions[index]?.type == "D" ? Icon(Icons.trending_down, color: Colors.red,) : (pointData?.last_ten_transactions[index].type == "C" ? Icon(Icons.trending_up, color: Colors.green,) : Icon(Icons.trending_flat, color: Colors.blue)),
                    title: Row(
                      children: <Widget>[
                        Expanded(child: Text("${pointData?.last_ten_transactions[index]?.type == "D" ? "${AppLocalizations.of(context)?.translate('debit_points_kaba')}" : "${AppLocalizations.of(context)?.translate('credit_points_kaba')}"}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      ],
                    ),
                    // subtitle: Text("${pointData[index].details}", style: TextStyle(fontSize: 12)),
                    trailing: Text("${(pointData?.last_ten_transactions[index]?.type == "D" ? "-" : "+")} ${pointData?.last_ten_transactions[index]?.amount}", style: TextStyle(color: pointData?.last_ten_transactions[index]?.type == "D" ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                    /*Row(
                        children: <Widget>[
                          Text(data[index].value, style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(width: 5), Icon(data[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                        ],
                      ),*/
                  ),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment:MainAxisAlignment.end, children: <Widget>[
                Text("${pointData?.last_ten_transactions[index]?.created_at}", style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),SizedBox(width: 10)
                // SizedBox(width: 5), Icon(pointData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
              ]),
            ],
          ) : Container(),


            ],
          );
        });
  }

  _buildMoneyTransactionHistoryList() {
    if (moneyData == null || moneyData?.length == 0)
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.monetization_on, color: Colors.grey)),
              SizedBox(height: 5),
              Text("${AppLocalizations.of(context)?.translate('sorry_empty_transactions')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ));

    // send a first card_view that shows the solde, then below we add the transactions stuffs
    return  ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withAlpha(50),
        ),
        itemCount: moneyData?.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              index == 0 ? Center(
                child: Card(margin: EdgeInsets.only(top:15, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.only(top:30, bottom:30, left:10, right:10),
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          Text("${AppLocalizations.of(context)?.translate('balance')}", style: TextStyle(fontSize: 24)),
                          Row(
                            children: [
                              Text("${balance == null ? (StateContainer.of(context).balance == null || StateContainer.of(context).balance == 0 ? "--" : StateContainer.of(context).balance) : balance}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                              Text("  ${AppLocalizations.of(context)?.translate('currency')}", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 14))
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ) : Container(),
              InkWell(
                onTap: () {
                  _onMoneyTransactionTap(moneyData[index]);
                },
                child: ListTile(
                  leading: moneyData[index].type == -1 ? Icon(Icons.trending_down, color: Colors.red,) : (moneyData[index].type == 1 ? Icon(Icons.trending_up, color: Colors.green,) : Icon(Icons.trending_flat, color: Colors.blue,)),
                  title: Row(
                    children: <Widget>[
                      Expanded(child: Text("${moneyData[index].details}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                  subtitle: Text("${moneyData[index].details}", style: TextStyle(fontSize: 12)),
                  trailing: Text("${(moneyData[index].type == -1 ? "-" : "+")} ${moneyData[index].value}", style: TextStyle(color: moneyData[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                  /*Row(
                      children: <Widget>[
                        Text(moneyData[index].value, style: TextStyle(color: moneyData[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(width: 5), Icon(moneyData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                      ],
                    ),*/
                ),
              ),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment:MainAxisAlignment.end, children: <Widget>[
                Text(Utils.readTimestamp(moneyData[index]?.created_at), style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                SizedBox(width: 5), Icon(moneyData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
              ]),
            ],
          );
        });
  }

  _buildMoneySysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)?.translate('system_error')}",onClickAction: (){ widget.presenter.fetchMoneyTransaction(widget.customer);    widget.presenter.checkBalance(widget.customer); });
  }

  _buildMoneyNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)?.translate('network_error')}",onClickAction: (){ widget.presenter.fetchMoneyTransaction(widget.customer);     widget.presenter.checkBalance(widget.customer); });
  }

  _buildPointSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)?.translate('system_error')}",onClickAction: (){ widget.presenter.fetchPointTransaction(widget.customer); });
  }

  _buildPointNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context)?.translate('network_error')}",onClickAction: (){ widget.presenter.fetchPointTransaction(widget.customer); });
  }

  @override
  void balanceSystemError() {

    balance = "---";
    showBalanceLoading(false);
  }

  @override
  void showBalance(String balance) {

    xrint("balance ${balance}");
    StateContainer.of(context).updateBalance(balance: int.parse(balance));
    showBalanceLoading(false);
    setState(() {
      this.balance = balance;
    });
  }

  @override
  void showBalanceLoading(bool isLoading) {
    setState(() {
      isMoneyBalanceLoading = isLoading;
    });
  }

  void mToast(String message) {
    mDialog(message);
  }

  void mDialog(String message) {

    _showDialog(
      icon: Icon(Icons.info_outline, color: Colors.red),
      message: "${message}",
      isYesOrNo: false,
    );
  }

  void _showDialog(
      {String svgIcons, Icon icon, var message, bool okBackToHome = false, bool isYesOrNo = false, Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: icon == null ? SvgPicture.asset(
                        svgIcons,
                      ) : icon),
                  SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 13))
                ]
            ),
            actions:
            isYesOrNo ? <Widget>[
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: Colors.grey, width: 1))),
                child: new Text("${AppLocalizations.of(context).translate('refuse')}", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                style: ButtonStyle(side: MaterialStateProperty.all(BorderSide(color: KColors.primaryColor, width: 1))),
                child: new Text(
                    "${AppLocalizations.of(context).translate('accept')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                  actionIfYes();
                },
              ),
            ] : <Widget>[
              OutlinedButton(
                child: new Text(
                    "${AppLocalizations.of(context).translate('ok')}", style: TextStyle(color: KColors.primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
        );
      },
    );
  }

  void _jumpToPage(BuildContext context, page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void _onMoneyTransactionTap(MoneyTransactionModel moneyData) {
    if (moneyData?.command_id != null && moneyData?.command_id > 1) {
      // jump to order details page
      _jumpToPage(context, OrderDetailsPage(
          orderId: moneyData?.command_id, presenter: OrderDetailsPresenter()));
    }
  }

  _getRemainingPointToUse(PointObjModel pointData) {

    try {
      int diff = pointData?.monthly_limit_amount - pointData?.amount_already_used;
      if (diff >= pointData?.balance) {
        return balance;
      } else {
        return diff;
      }
    } catch(_){
      xrint(_.toString());
      return "---";
    }
  }


/* @override
  void updateKabaPoints(String kabaPoints) {
    setState(() {
      StateContainer.of(context).updateKabaPoints(kabaPoints: kabaPoints);
    });
  }*/

}
