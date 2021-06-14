import 'package:KABA/src/blocs/UserDataBloc.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CommandModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:KABA/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:flutter/material.dart';


class LastOrdersPage extends StatefulWidget {
  CustomerModel customer;


  LastOrdersPage({Key key}) : super(key: key);

  @override
  _LastOrdersPageState createState() => _LastOrdersPageState();
}

class _LastOrdersPageState extends State<LastOrdersPage> {

  @override
  void initState() {
    // TODO: implement initState
    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      userDataBloc.fetchLastOrders(widget.customer);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
          backgroundColor: Colors.white,
          title: Text("${AppLocalizations.of(context).translate('last_orders')}", style:TextStyle(color:KColors.primaryColor)),
        ),
        backgroundColor: Colors.white,
        body:  StreamBuilder(
            stream: userDataBloc.mLastOrders,
            builder: (context, AsyncSnapshot<List<CommandModel>> snapshot) {
              if (snapshot.hasData) {
                return _buildOrderList(snapshot.data);
              } else if (snapshot.hasError) {
                if (snapshot.connectionState == ConnectionState.none)
                  return ErrorPage(message: "${AppLocalizations.of(context).translate('network_error')}",onClickAction: (){
                    userDataBloc.fetchLastOrders(widget.customer);
                  });
                else
                  return ErrorPage(message: "${AppLocalizations.of(context).translate('system_error')}",onClickAction: (){
                    userDataBloc.fetchLastOrders(widget.customer);
                  });
              }
              return Center(child: MyLoadingProgressWidget());
            }));
  }

  _buildOrderList(List<CommandModel> data) {
    if (data != null && data.length > 0)
      return ListView(
        children: <Widget>[
          SizedBox(height: 10)
        ]
          ..addAll(
              List<Widget>.generate(data.length, (int index) {
                return MyOrderWidget(command: data[index]);
              })
          ),
      );
    else
      return Center(
          child:Column(mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(icon: Icon(Icons.bookmark_border, color: Colors.grey)),
              SizedBox(height: 5),
              Text("${AppLocalizations.of(context).translate('no_past_order')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ));
  }
}
