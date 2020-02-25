import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/contracts/transaction_contract.dart';
import 'package:kaba_flutter/src/models/CustomerModel.dart';
import 'package:kaba_flutter/src/models/TransactionModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';


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
  String balance;

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
//widget.presenter.fetchTransaction(widget.);
  }

  bool hasSystemError = false;
  bool isLoading = false;
  bool isBalanceLoading = false;
  bool hasNetworkError = false;



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: KColors.primaryColor),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.white,
          title: Text("MY TRANSACTIONS", style:TextStyle(color:KColors.primaryColor, fontSize: 16)),
//          actions: isBalanceLoading ? SizedBox(height: 20, width: 20,child: CircularProgressIndicator()) : <Widget>[Text(balance, style: TextStyle(fontWeight: FontWeight.bold,color: KColors.primaryYellowColor))]
          actions: <Widget>[

            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: isBalanceLoading ? SizedBox(height: 20, width: 20,child: CircularProgressIndicator()) : GestureDetector(
                    onTap: () {},
                    child: Center(child: Text("${balance == null ? "--" : balance} XOF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: KColors.primaryColor)))
                )
            ),
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
              Text("Sorry, you have made no transaction yet !", style: TextStyle(color: Colors.grey)),
            ],
          ));

    return  ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withAlpha(50),
        ),
        itemCount: data?.length,
        itemBuilder: (BuildContext context, int index) {

//          print("timestamp is ${data[index].created_at}");
//          print("eq date is ${Utils.readTimestamp(data[index]?.created_at)}\n\n");
//          return Container();

          return Column(
            children: <Widget>[
              ListTile(
                leading: data[index].type == -1 ? Icon(Icons.trending_down, color: Colors.red,) : (data[index].type == 1 ? Icon(Icons.trending_up, color: Colors.green,) : Icon(Icons.trending_flat, color: Colors.blue,)),
                title: Row(
                  children: <Widget>[
                    Expanded(child: Text("${data[index].details}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                ),
                subtitle: Text("${data[index].details}", style: TextStyle(fontSize: 12)),
                trailing: Text(data[index].value, style: TextStyle(color: data[index].type == -1 ? Colors.red : Colors.green,fontWeight: FontWeight.bold, fontSize: 18)),
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
    return ErrorPage(message: "System error.",onClickAction: (){ widget.presenter.fetchTransaction(widget.customer); });
  }

  _buildNetworkErrorPage() {
    return ErrorPage(message: "Network error.",onClickAction: (){ widget.presenter.fetchTransaction(widget.customer); });
  }

  @override
  void balanceSystemError() {

    balance = "---";
    showBalanceLoading(false);
  }

  @override
  void showBalance(String balance) {

    print("balance ${balance}");
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

}
