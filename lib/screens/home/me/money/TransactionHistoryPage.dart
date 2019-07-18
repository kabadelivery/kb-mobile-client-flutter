import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';


class TransactionHistoryPage extends StatefulWidget {

  static var routeName = "/TransactionHistoryPage";

  TransactionHistoryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("TRANSACTIONS HISTORY", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.withAlpha(50),
          ),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Icon(Icons.trending_down, color: Colors.red),
              title: Text("Recharge T-money", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("25-01-1992", style: TextStyle(fontSize: 12)),
              trailing: Text("-1.500F", style: TextStyle(color: Colors.red, fontSize: 14)),
            );
          }),
    );
  }
}
