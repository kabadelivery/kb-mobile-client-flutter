import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';


class DailyOrdersPage extends StatefulWidget {

  DailyOrdersPage({Key key}) : super(key: key);

  @override
  _DailyOrdersPageState createState() => _DailyOrdersPageState();
}

class _DailyOrdersPageState extends State<DailyOrdersPage> {


  @override
  void initState() {
    // TODO: implement initState
    CustomerUtils.getCustomer().then((customer) {
      userDataBloc.fetchDailyOrders(customer);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body:  StreamBuilder(
            stream: userDataBloc.mDailyOrders,
            builder: (context, AsyncSnapshot<List<CommandModel>> snapshot) {
              if (snapshot.hasData) {
                return _buildOrderList(snapshot.data);
              } else if (snapshot.hasError) {
                return ErrorPage(onClickAction: (){
                  CustomerUtils.getCustomer().then((customer) {
                    userDataBloc.fetchDailyOrders(customer);
                  });
                });
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  _buildOrderList(List<CommandModel> data) {
    if (data != null && data.length > 0)
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 40)
          ]
            ..addAll(
                List<Widget>.generate(data.length, (int index) {
                  return MyOrderWidget(command: data[index]);
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
              Text("You have made no order yet today!", style: TextStyle(color: Colors.grey)),
            ],
          ));
  }
}
