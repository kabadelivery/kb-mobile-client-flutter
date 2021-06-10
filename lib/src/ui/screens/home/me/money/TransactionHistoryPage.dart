import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/TransactionModel.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';

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

class _TransactionHistoryPageState extends State<TransactionHistoryPage> implements TransactionView {

  List<TransactionModel> data;
  String balance, kaba_points;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.presenter.transactionView = this;
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      widget.presenter.fetchTransaction(customer);
      widget.presenter.checkBalance(customer);
    });
  }

  bool hasSystemError = false;
  bool isLoading = true;
  bool isBalanceLoading = false;
  bool hasNetworkError = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.white,
          title: Text("${AppLocalizations.of(context).translate('my_balance')}", style:TextStyle(color:KColors.primaryColor, fontSize: 16)),
          actions: <Widget>[
          ],
        ),
        body: Container(
            child: isLoading ? Center(child:CircularProgressIndicator()) : (hasNetworkError ? _buildNetworkErrorPage() : hasSystemError ? _buildSysErrorPage():
            _buildTransactionHistoryList())
        )
    );
  }


  @override
  void inflateTransaction(List<TransactionModel> transactions) {

    showLoading(false);

    setState(() {
      this.data = transactions.reversed.toList();
    });
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

  _buildTransactionHistoryList() {
    if (data == null || data?.length == 0)
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.monetization_on, color: Colors.grey)),
              SizedBox(height: 5),
              Text("${AppLocalizations.of(context).translate('sorry_empty_transactions')}", style: TextStyle(color: Colors.grey)),
            ],
          ));

    // send a first card_view that shows the solde, then below we add the transactions stuffs


    return  ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withAlpha(50),
        ),
        itemCount: data?.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[

             index == 0 ? Center(
                child: Card(margin: EdgeInsets.only(top:15, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.only(top:30, bottom:30, left:10, right:10),
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Text("${AppLocalizations.of(context).translate('balance')}", style: TextStyle(fontSize: 30)),
                      Row(
                        children: [
                          Text("${balance == null ? (StateContainer.of(context).balance == null || StateContainer.of(context).balance == 0 ? "--" : StateContainer.of(context).balance) : balance}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                        Text("  ${AppLocalizations.of(context).translate('currency')}", style: TextStyle(color: KColors.primaryYellowColor, fontSize: 14))
                        ],
                      ),
                    ]),
                  ),
                ),
              ) : Container(),

              index == 0 ? Center(
                child: Card(margin: EdgeInsets.only(top:10, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.only(top:30, bottom:30, left:10, right:10),
                    width: MediaQuery.of(context).size.width*0.9,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Text("${AppLocalizations.of(context).translate('kaba_points')}", style: TextStyle(fontSize: 24)),
                      Row(
                        children: [
                          Text("${kaba_points == null ? (StateContainer.of(context).kabaPoints == null || StateContainer.of(context).kabaPoints == null ? "--" : StateContainer.of(context).kabaPoints) : kaba_points}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                        ],
                      ),
                    ]),
                  ),
                ),
              ) : Container(),

              ListTile(
                leading: data[index].type == -1 ? Icon(Icons.trending_down, color: Colors.red,) : (data[index].type == 1 ? Icon(Icons.trending_up, color: Colors.green,) : Icon(Icons.trending_flat, color: Colors.blue,)),
                title: Row(
                  children: <Widget>[
                    Expanded(child: Text("${data[index].details}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                ),
                subtitle: Text("${data[index].details}", style: TextStyle(fontSize: 12)),
                trailing: Text("${(data[index].type == -1 ? "-" : "+")} ${data[index].value}", style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                /*Row(
                    children: <Widget>[
                      Text(data[index].value, style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(width: 5), Icon(data[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
                    ],
                  ),*/
              ),
              Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment:MainAxisAlignment.end, children: <Widget>[
                Text(Utils.readTimestamp(data[index]?.created_at), style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                SizedBox(width: 5), Icon(data[index].payAtDelivery == true ? Icons.money_off : Icons.attach_money, color: Colors.grey),SizedBox(width: 10)
              ]),
            ],
          );
        });
  }

  _buildSysErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){ widget.presenter.fetchTransaction(widget.customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){ widget.presenter.fetchTransaction(widget.customer); });
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
      isBalanceLoading = isLoading;
    });
  }

  @override
  void updateKabaPoints(String kabaPoints) {
    setState(() {
      StateContainer.of(context).updateKabaPoints(kabaPoints: kabaPoints);
    });
  }

}
