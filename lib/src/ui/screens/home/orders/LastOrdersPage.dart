import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';


  class LastOrdersPage extends StatefulWidget {

  LastOrdersPage({Key key}) : super(key: key);

  @override
  _LastOrdersPageState createState() => _LastOrdersPageState();
}

class _LastOrdersPageState extends State<LastOrdersPage> {

  @override
  void initState() {
    // TODO: implement initState
    CustomerUtils.getCustomer().then((customer) {
      userDataBloc.fetchLastOrders(customer);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
          backgroundColor: Colors.white,
          title: Text("LAST ODERS", style:TextStyle(color:KColors.primaryColor)),
        ),
        backgroundColor: Colors.white,
        body:  StreamBuilder(
            stream: userDataBloc.mLastOrders,
            builder: (context, AsyncSnapshot<List<CommandModel>> snapshot) {
              if (snapshot.hasData) {
                userDataBloc.dispose();
                return _buildOrderList(snapshot.data);
              } else if (snapshot.hasError) {
                return ErrorPage(onClickAction: (){
                  CustomerUtils.getCustomer().then((customer) {
                    userDataBloc.fetchLastOrders(customer);
                  });
                });
              }
              return Center(child: CircularProgressIndicator());
            }));
    /* instead of streams, wanna use mvp */
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
