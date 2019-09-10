import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class OrderDetailsPage extends StatefulWidget {

  static var routeName = "/OrderDetailsPage";

  OrderDetailsPage ({Key key, this.orderId}) : super(key: key);

  final int orderId;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState(orderId);
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  int orderId;

  _OrderDetailsPageState(this.orderId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userDataBloc.fetchOrderDetails(UserTokenModel.fake(), 3825 /*orderId*/);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: KColors.primaryColor,
            title: Text("Command Details",
                style: TextStyle(fontSize: 20, color: Colors.white))),
        body: StreamBuilder<Object>(
            stream: userDataBloc.mDailyOrders,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _inflateDetails(snapshot.data);
              } else if (snapshot.hasError) {
                return ErrorPage(onClickAction: () {
                  userDataBloc.fetchOrderDetails(UserTokenModel.fake(), orderId);
                });
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Widget _inflateDetails(CommandModel data) {

    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
            Container(width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top:15, bottom:15, right:10, left:10),
                color: Colors.green,child: Text(_orderTopLabel(data), style: TextStyle(fontSize: 18, color: Colors.white))),
            /* Progress line */
            Container(height:200),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(10),
                child: RichText(
                  text: new TextSpan(
                    text: 'Latest Update: ',
                    style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: " ${_orderLastUpdate(data)}", style: TextStyle(fontSize: 24, color: KColors.primaryColor)),
                    ],
                  ),
                ),
              ),
            ),
            /* your contact */
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                Flexible (child: Text("Your contact", style: TextStyle(color: Colors.black, fontSize: 16))),
                Flexible (child: Text("${data?.shipping_address?.phone_number}", style: TextStyle(color: Colors.black, fontSize: 14))),
              ]),
            ),
            SizedBox(height: 10),
            /* command key */
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
                Flexible (child: Text("Command key", style: TextStyle(color: Colors.black, fontSize: 16))),
                Flexible (child: Text("${data?.passphrase}", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
              ]),
            ),
            SizedBox(height: 10),
            /* not so far from */
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.yellow,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Not so far from", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                      SizedBox(height: 10),
                      Text("${data?.shipping_address?.near}", style: TextStyle(color: Colors.black, fontSize: 14)),
                    ]),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.yellow,
                padding: EdgeInsets.only(top:20, bottom:20, right:10, left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Description", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.black, fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${data?.shipping_address?.description}", style: TextStyle(color: Colors.black, fontSize: 14)),
                    ]),
              ),
            ),
            SizedBox(height: 10),
            /* food list
                  Card(child: ListView.builder(
                      itemCount: litems.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Text(litems[index]);
                      }
                  )) */
          ]
      ),
    );
  }

  String _orderTopLabel(CommandModel data) {
    return "COMMAND XXXXXXXX";
  }

  _orderLastUpdate(CommandModel data) {
    return "XX-XX-XXXX";
  }

}
