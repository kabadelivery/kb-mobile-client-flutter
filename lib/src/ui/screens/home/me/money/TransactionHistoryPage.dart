import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/MoneyTransactionModel.dart';
import 'package:KABA/src/models/PointObjModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyNormalLoadingProgressWidget.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderDetailsPage.dart';
import 'package:KABA/src/ui/screens/home/orders/OrderNewDetailsPage.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class TransactionHistoryPage extends StatefulWidget {
  static var routeName = "/TransactionHistoryPage";

  TransactionPresenter presenter;

  CustomerModel customer;

  var selectedPosition = 1;

  TransactionHistoryPage({Key key, this.title, this.presenter})
      : super(key: key);

  final String title;

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with TransactionView, SingleTickerProviderStateMixin {
  List<MoneyTransactionModel> moneyData;
  PointObjModel pointData = null;

  String balance, kaba_points;

  TabController _tabController;

  var TABS_LENGTH = 2;

  String currentMonth = "";

  Color filter_unactive_button_color = Color(0xFFF7F7F7),
      filter_active_button_color = KColors.primaryColor,
      filter_unactive_text_color = KColors.new_black,
      filter_active_text_color = Colors.white;

  var _searchChoices = null;

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
  bool isPointPageLoading =
      true; // to make sure when the tab is switched, the page is loading already
  bool hasPointSystemError = false;
  bool hasPointNetworkError = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchChoices == null) {
      _searchChoices = [
        "${AppLocalizations.of(context)?.translate("balance")}",
        "${AppLocalizations.of(context)?.translate("points")}"
      ];
    }

    if (currentMonth == "") {
      try {
        xrint("current month ${DateTime.now().month}");
        xrint("mois_${DateTime.now().month}");

        currentMonth =
            "${AppLocalizations.of(context)?.translate("mois_${DateTime.now().month}")}";
      } catch (_) {
        xrint(_.toString());
        currentMonth = "This month";
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context)?.translate('my_balance')}"),
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: filter_unactive_button_color,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(5.0)),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () => _onSwitch(1),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(Utils.capitalize(
                                                  // "${AppLocalizations.of(context).translate('search_restaurant')}"),
                                                  _searchChoices[0]),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: widget
                                                              .selectedPosition ==
                                                          1
                                                      ? this
                                                          .filter_active_text_color
                                                      : this
                                                          .filter_unactive_text_color)),
                                        ),
                                        decoration: BoxDecoration(
                                            color: widget.selectedPosition == 1
                                                ? this
                                                    .filter_active_button_color
                                                : this
                                                    .filter_unactive_button_color,
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    5.0)))),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () => _onSwitch(2),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(
                                              Utils.capitalize(
                                                  _searchChoices[1]),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: widget
                                                              .selectedPosition ==
                                                          1
                                                      ? this
                                                          .filter_unactive_text_color
                                                      : this
                                                          .filter_active_text_color)),
                                        ),
                                        decoration: BoxDecoration(
                                            color: widget.selectedPosition == 1
                                                ? this
                                                    .filter_unactive_button_color
                                                : this
                                                    .filter_active_button_color,
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    5.0)))),
                              ),
                            ]),
                        duration: Duration(milliseconds: 3000),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              widget.selectedPosition == 1
                  ? Container(
                      child: isMoneyBalanceLoading || isMoneyLoading
                          ? Center(child: MyLoadingProgressWidget())
                          : (hasMoneyNetworkError
                              ? _buildMoneyNetworkErrorPage()
                              : hasMoneySystemError
                                  ? _buildMoneySysErrorPage()
                                  : _buildMoneyTransactionHistoryList()))
                  : Container(),
              widget.selectedPosition == 2
                  ? Container(
                      child: isPointPageLoading
                          ? Center(child: MyLoadingProgressWidget())
                          : (hasPointNetworkError
                              ? _buildPointNetworkErrorPage()
                              : (hasPointNetworkError
                                  ? _buildPointSysErrorPage()
                                  : _buildPointTransactionHistoryList())))
                  : Container(),
            ],
          ),
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
    Future.delayed(Duration(seconds: delay), () {
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
    if (pointData == null ||
        !pointData
            ?.is_eligible /* || pointData?.last_ten_transactions?.length == 0*/)
      return Column(
        children: [
          SizedBox(height: 15),
          Center(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
                pointData?.is_eligible
                    ? "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                        .replaceAll(
                            "XXX_XXX", "${pointData?.monthly_limit_amount}")
                    : "${AppLocalizations.of(context)?.translate("use_of_kaba_points_not_eligible")}",
                textAlign: TextAlign.center,
                style: TextStyle(color: KColors.new_black, fontSize: 11)),
          )),
          SizedBox(height: 20),
          Opacity(opacity: 0.7,
            child: Center(
              child: Container(
                color: KColors.new_gray,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 20, left: 10, right: 10, bottom: 15),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('kaba_points')}\n",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ]),
                                    SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                  "${pointData?.balance == null ? "---" : pointData?.balance}",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('month_remain_kaba_points')}"
                                                  .replaceAll(
                                                      "XXX_XXX", currentMonth),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ]),
                                    SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                  "${pointData?.balance == null || pointData?.amount_already_used == null ? "---" : _getRemainingPointToUse(pointData)}",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: CommandStateColor
                                                          .delivered)),
                                            ],
                                          ),
                                        ])
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('month_used_kaba_points')}"
                                                  .replaceAll(
                                                      "XXX_XXX", currentMonth),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ]),
                                    SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                  "${pointData?.amount_already_used == null ? "---" : pointData?.amount_already_used}",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color:
                                                          KColors.primaryColor)),
                                            ],
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 20),
                    pointData?.is_eligible
                        ? Container()
                        : RawMaterialButton(
                            onPressed: () => mToast(
                                "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                                    .replaceAll("XXX_XXX",
                                        "${pointData?.monthly_limit_amount}")),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                      "${AppLocalizations.of(context)?.translate('your_points')}",
                                      style: TextStyle(color: Colors.grey)),
                                ])),
                    false
                        ? RawMaterialButton(
                            onPressed: () => mToast(
                                "${AppLocalizations.of(context)?.translate('non_eligible_reason')}"),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                      "${AppLocalizations.of(context)?.translate('non_eligible')}",
                                      style: TextStyle(color: Colors.grey)),
                                ]),
                          )
                        : Container(),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.discount, color:  KColors.primaryColor),
                  SizedBox(height: 5),
                  Text(
                      "${AppLocalizations.of(context)?.translate('non_eligible_reason')}".replaceAll("XXX", pointData?.eligible_order_count?.toString()).replaceAll("YYY", pointData?.monthly_limit_amount?.toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KColors.primaryColor)),
                ],
              ))
        ],
      );

    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
            children: <Widget>[]..addAll(List.generate(
                  pointData?.last_ten_transactions?.length, (index) {
                return Column(
                  children: <Widget>[
                    index == 0 ? SizedBox(height: 15) : Container(),
                    index == 0
                        ? Center(
                            child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                                pointData?.is_eligible
                                    ? "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                                        .replaceAll("XXX_XXX",
                                            "${pointData?.monthly_limit_amount}")
                                    : "${AppLocalizations.of(context)?.translate("use_of_kaba_points_not_eligible")}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ))
                        : Container(),
                    index == 0 ? SizedBox(height: 20) : Container(),
                    index == 0
                        ? Center(
                            child: Container(
                              color: KColors.new_gray,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 10,
                                        right: 10,
                                        bottom: 15),
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            "${AppLocalizations.of(context)?.translate('kaba_points')}\n",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey)),
                                                      ]),
                                                  SizedBox(height: 5),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                "${pointData?.balance == null ? "---" : pointData?.balance}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black)),
                                                          ],
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Text(
                                                            "${AppLocalizations.of(context)?.translate('month_remain_kaba_points')}"
                                                                .replaceAll(
                                                                    "XXX_XXX",
                                                                    currentMonth),
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey)),
                                                      ]),
                                                  SizedBox(height: 5),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                "${pointData?.balance == null || pointData?.amount_already_used == null ? "---" : _getRemainingPointToUse(pointData)}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: CommandStateColor
                                                                        .delivered)),
                                                          ],
                                                        ),
                                                      ])
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                            "${AppLocalizations.of(context)?.translate('month_used_kaba_points')}"
                                                                .replaceAll(
                                                                    "XXX_XXX",
                                                                    currentMonth),
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey)),
                                                      ]),
                                                  SizedBox(height: 5),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                "${pointData?.amount_already_used == null ? "---" : pointData?.amount_already_used}",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: KColors
                                                                        .primaryColor)),
                                                          ],
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: 20),
                                  pointData?.is_eligible
                                      ? Container()
                                      : RawMaterialButton(
                                          onPressed: () => mToast(
                                              "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                                                  .replaceAll("XXX_XXX",
                                                      "${pointData?.monthly_limit_amount}")),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.grey),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${AppLocalizations.of(context)?.translate('your_points')}",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ])),
                                  false
                                      ? RawMaterialButton(
                                          onPressed: () => mToast(
                                              "${AppLocalizations.of(context)?.translate('non_eligible_reason')}"),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.grey),
                                                SizedBox(width: 5),
                                                Text(
                                                    "${AppLocalizations.of(context)?.translate('non_eligible')}",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ]),
                                        )
                                      : Container(),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    index == 0 ? SizedBox(height: 15) : Container(),
                    pointData?.last_ten_transactions?.length > 0
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: KColors.new_gray,
                              border: Border(
                                bottom: BorderSide(
                                    width: index ==
                                            pointData?.last_ten_transactions
                                                    ?.length -
                                                1
                                        ? 0
                                        : 0.8,
                                    color: Colors.grey.withAlpha(35)),
                              ),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: pointData
                                              ?.last_ten_transactions[index]
                                              ?.type ==
                                          "D"
                                      ? Icon(
                                          Icons.trending_down,
                                          color: Colors.red,
                                        )
                                      : (pointData?.last_ten_transactions[index]
                                                  .type ==
                                              "C"
                                          ? Icon(
                                              Icons.trending_up,
                                              color: Colors.green,
                                            )
                                          : Icon(Icons.trending_flat,
                                              color: Colors.blue)),
                                  title: Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                              "${pointData?.last_ten_transactions[index]?.type == "D" ? "${AppLocalizations.of(context)?.translate('debit_points_kaba')}" : "${AppLocalizations.of(context)?.translate('credit_points_kaba')}"}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16))),
                                    ],
                                  ),
                                  // subtitle: Text("${pointData[index].details}", style: TextStyle(fontSize: 12)),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: (pointData
                                                        ?.last_ten_transactions[
                                                            index]
                                                        ?.type !=
                                                    "D"
                                                ? CommandStateColor.delivered
                                                : KColors.primaryColor)
                                            .withAlpha(30)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 5),
                                        Icon(
                                            pointData
                                                        ?.last_ten_transactions[
                                                            index]
                                                        ?.type !=
                                                    "D"
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 12,
                                            color: pointData
                                                        ?.last_ten_transactions[
                                                            index]
                                                        ?.type !=
                                                    "D"
                                                ? CommandStateColor.delivered
                                                : KColors.primaryColor),
                                        SizedBox(width: 5),
                                        Text(
                                            "${pointData?.last_ten_transactions[index]?.amount}",
                                            style: TextStyle(
                                                color: pointData
                                                            ?.last_ten_transactions[
                                                                index]
                                                            ?.type !=
                                                        "D"
                                                    ? CommandStateColor
                                                        .delivered
                                                    : KColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        SizedBox(width: 5),
                                        Text(
                                            "${AppLocalizations.of(context)?.translate('currency')}",
                                            style: TextStyle(
                                                color: pointData
                                                            ?.last_ten_transactions[
                                                                index]
                                                            ?.type !=
                                                        "D"
                                                    ? CommandStateColor
                                                        .delivered
                                                    : KColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                  ),
                                  /*Row(
                          children: <Widget>[
                            Text(data[index].value, style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(width: 5), Icon(data[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                          ],
                      ),*/
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                          "${pointData?.last_ten_transactions[index]?.created_at}",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          )),
                                      SizedBox(width: 10)
                                      // SizedBox(width: 5), Icon(pointData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                                    ]),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                );
              }).toList())));

    // send a first card_view that shows the solde, then below we add the transactions stuffs
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(
              color: Colors.grey.withAlpha(50),
            ),
        itemCount: pointData?.last_ten_transactions?.length == 0
            ? 1
            : pointData?.last_ten_transactions?.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              index == 0
                  ? Center(
                      child: Card(
                        margin: EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  top: 15, left: 10, right: 10, bottom: 10),
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Center(
                                      child: Text(
                                          pointData?.is_eligible
                                              ? "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                                                  .replaceAll("XXX_XXX",
                                                      "${pointData?.monthly_limit_amount}")
                                              : "${AppLocalizations.of(context)?.translate("use_of_kaba_points_not_eligible")}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11))),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                    "${AppLocalizations.of(context)?.translate('kaba_points')}",
                                                    style: TextStyle(
                                                        fontSize: 24)),
                                              ]),
                                          SizedBox(height: 5),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                    "${AppLocalizations.of(context)?.translate('month_used_kaba_points')}"
                                                        .replaceAll("XXX_XXX",
                                                            currentMonth),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: KColors
                                                            .primaryColor)),
                                              ]),
                                          SizedBox(height: 5),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                    "${AppLocalizations.of(context)?.translate('month_remain_kaba_points')}"
                                                        .replaceAll("XXX_XXX",
                                                            currentMonth),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: CommandStateColor
                                                            .delivered)),
                                              ])
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${pointData?.balance == null ? "---" : pointData?.balance}",
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            color: KColors
                                                                .primaryColor)),
                                                  ],
                                                ),
                                              ]),
                                          SizedBox(height: 5),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${pointData?.amount_already_used == null ? "---" : pointData?.amount_already_used}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: KColors
                                                                .primaryColor)),
                                                  ],
                                                ),
                                              ]),
                                          SizedBox(height: 5),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${pointData?.balance == null || pointData?.amount_already_used == null ? "---" : _getRemainingPointToUse(pointData)}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                CommandStateColor
                                                                    .delivered)),
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
                            pointData?.is_eligible
                                ? Container()
                                : RawMaterialButton(
                                    onPressed: () => mToast(
                                        "${AppLocalizations.of(context)?.translate('kaba_point_description')}"
                                            .replaceAll("XXX_XXX",
                                                "${pointData?.monthly_limit_amount}")),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.grey),
                                          SizedBox(width: 5),
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('your_points')}",
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ])),
                            false
                                ? RawMaterialButton(
                                    onPressed: () => mToast(
                                        "${AppLocalizations.of(context)?.translate('non_eligible_reason')}"),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.grey),
                                          SizedBox(width: 5),
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('non_eligible')}",
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ]),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              pointData?.last_ten_transactions?.length > 0
                  ? Column(
                      children: [
                        ListTile(
                          leading: pointData
                                      ?.last_ten_transactions[index]?.type ==
                                  "D"
                              ? Icon(
                                  Icons.trending_down,
                                  color: Colors.red,
                                )
                              : (pointData?.last_ten_transactions[index].type ==
                                      "C"
                                  ? Icon(
                                      Icons.trending_up,
                                      color: Colors.green,
                                    )
                                  : Icon(Icons.trending_flat,
                                      color: Colors.blue)),
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                      "${pointData?.last_ten_transactions[index]?.type == "D" ? "${AppLocalizations.of(context)?.translate('debit_points_kaba')}" : "${AppLocalizations.of(context)?.translate('credit_points_kaba')}"}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                            ],
                          ),
                          // subtitle: Text("${pointData[index].details}", style: TextStyle(fontSize: 12)),
                          trailing: Text(
                              "${(pointData?.last_ten_transactions[index]?.type == "D" ? "-" : "+")} ${pointData?.last_ten_transactions[index]?.amount}",
                              style: TextStyle(
                                  color: pointData?.last_ten_transactions[index]
                                              ?.type ==
                                          "D"
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          /*Row(
                        children: <Widget>[
                          Text(data[index].value, style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(width: 5), Icon(data[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                        ],
                      ),*/
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                  "${pointData?.last_ten_transactions[index]?.created_at}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic)),
                              SizedBox(width: 10)
                              // SizedBox(width: 5), Icon(pointData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                            ]),
                      ],
                    )
                  : Container(),
            ],
          );
        });
  }

  _buildMoneyTransactionHistoryList() {
    if (moneyData == null || moneyData?.length == 0)
      return Column(
        children: [
          Center(
            child: Container(
              color: KColors.new_gray,
              margin: EdgeInsets.only(top: 15, bottom: 10),
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            "${AppLocalizations.of(context)?.translate('available_balance')}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                                "${balance == null ? (StateContainer.of(context).balance == null || StateContainer.of(context).balance == 0 ? "--" : StateContainer.of(context).balance) : balance}",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: KColors.new_black)),
                            SizedBox(width: 5),
                            Text(
                                "  ${AppLocalizations.of(context)?.translate('currency')}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: KColors.primaryYellowColor,
                                    fontSize: 14))
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          ),
          Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.monetization_on, color: Colors.grey),
              SizedBox(height: 5),
              Text(
                  "${AppLocalizations.of(context)?.translate('sorry_empty_transactions')}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ],
          )),
        ],
      );

    return Container(
        child: Column(
            children: <Widget>[]
              ..addAll(List.generate(moneyData?.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: <Widget>[
                      index == 0
                          ? Center(
                              child: Container(
                                color: KColors.new_gray,
                                margin: EdgeInsets.only(top: 15, bottom: 10),
                                padding: EdgeInsets.only(
                                    top: 15, bottom: 15, left: 20, right: 20),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context)?.translate('available_balance')}",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                  "${balance == null ? (StateContainer.of(context).balance == null || StateContainer.of(context).balance == 0 ? "--" : StateContainer.of(context).balance) : balance}",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          KColors.new_black)),
                                              SizedBox(width: 5),
                                              Text(
                                                  "  ${AppLocalizations.of(context)?.translate('currency')}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: KColors
                                                          .primaryYellowColor,
                                                      fontSize: 14))
                                            ],
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      index == 0
                          ? Container(
                              height: 20,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white)
                          : Container(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            color: KColors.new_gray,
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                _onMoneyTransactionTap(moneyData[index]);
                              },
                              child: ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                            "${moneyData[index].details}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: KColors.new_black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14))),
                                  ],
                                ),
                                subtitle: Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text("${moneyData[index].details}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: (moneyData[index].type != -1
                                              ? CommandStateColor.delivered
                                              : KColors.primaryColor)
                                          .withAlpha(30)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      /*   moneyData[index].payAtDelivery == true
                                          ? Container(width: 0, height: 0,) : Icon(
                                              Icons.monetization_on,
                                              color: moneyData[index].type != -1
                                                  ? CommandStateColor.delivered
                                                  : KColors.primaryColor,
                                              size: 15,
                                            )
                                      ,*/
                                      Icon(
                                          moneyData[index].type != -1
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 12,
                                          color: moneyData[index].type != -1
                                              ? CommandStateColor.delivered
                                              : KColors.primaryColor),
                                      SizedBox(width: 5),
                                      Text("${moneyData[index].value}",
                                          style: TextStyle(
                                              color: moneyData[index].type != -1
                                                  ? CommandStateColor.delivered
                                                  : KColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      SizedBox(width: 5),
                                      Text(
                                          "${AppLocalizations.of(context)?.translate('currency_short')}",
                                          style: TextStyle(
                                              color: moneyData[index].type != -1
                                                  ? CommandStateColor.delivered
                                                  : KColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                                /*Row(
                              children: <Widget>[
                                Text(moneyData[index].value, style: TextStyle(color: moneyData[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                                SizedBox(width: 5), Icon(moneyData[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                              ],
                            ),*/
                              ),
                            ),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                      Utils.readTimestamp(context,
                                          moneyData[index]?.created_at),
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  SizedBox(width: 20)
                                ]),
                          ],
                        ),
                      ),
                      index == moneyData?.length - 1
                          ? Container(
                              height: 90,
                              child: Center(
                                child: Text(
                                  '${AppLocalizations.of(context).translate("only_3_months_transaction_history")}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
              }).toList())));
  }

  _buildMoneySysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)?.translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchMoneyTransaction(widget.customer);
          widget.presenter.checkBalance(widget.customer);
        });
  }

  _buildMoneyNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)?.translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchMoneyTransaction(widget.customer);
          widget.presenter.checkBalance(widget.customer);
        });
  }

  _buildPointSysErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)?.translate('system_error')}",
        onClickAction: () {
          widget.presenter.fetchPointTransaction(widget.customer);
        });
  }

  _buildPointNetworkErrorPage() {
    return ErrorPage(
        message: "${AppLocalizations.of(context)?.translate('network_error')}",
        onClickAction: () {
          widget.presenter.fetchPointTransaction(widget.customer);
        });
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
      {String svgIcons,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(
                  height: 80,
                  width: 80,
                  child: icon == null
                      ? SvgPicture.asset(
                          svgIcons,
                        )
                      : icon),
              SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: KColors.new_black, fontSize: 13))
            ]),
            actions: isYesOrNo
                ? <Widget>[
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.grey, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('refuse')}",
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(BorderSide(
                              color: KColors.primaryColor, width: 1))),
                      child: new Text(
                          "${AppLocalizations.of(context).translate('accept')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes();
                      },
                    ),
                  ]
                : <Widget>[
                    OutlinedButton(
                      child: new Text(
                          "${AppLocalizations.of(context).translate('ok')}",
                          style: TextStyle(color: KColors.primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
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
      _jumpToPage(
          context,
          OrderNewDetailsPage(
              orderId: moneyData?.command_id,
              presenter: OrderDetailsPresenter()));
    }
  }

  _getRemainingPointToUse(PointObjModel pointData) {
    try {
      int diff =
          pointData?.monthly_limit_amount - pointData?.amount_already_used;
      if (diff >= pointData?.balance) {
        return pointData?.balance;
      } else {
        return diff;
      }
    } catch (_) {
      xrint(_.toString());
      return "---";
    }
  }

  _onSwitch(int i) {
    setState(() {
      widget.selectedPosition = i;
      if (widget.selectedPosition == 2) {
        if (pointData == null)
          widget.presenter.fetchPointTransaction(widget.customer);
      }
    });
  }

/* @override
  void updateKabaPoints(String kabaPoints) {
    setState(() {
      StateContainer.of(context).updateKabaPoints(kabaPoints: kabaPoints);
    });
  }*/

}
