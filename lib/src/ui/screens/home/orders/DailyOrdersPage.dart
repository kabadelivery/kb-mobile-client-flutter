import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/blocs/RestaurantBloc.dart';
import 'package:kaba_flutter/src/blocs/UserDataBloc.dart';
import 'package:kaba_flutter/src/models/CommandModel.dart';
import 'package:kaba_flutter/src/models/UserTokenModel.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/ui/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantListWidget.dart';


class DailyOrdersPage extends StatefulWidget {
  DailyOrdersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DailyOrdersPageState createState() => _DailyOrdersPageState();
}

class _DailyOrdersPageState extends State<DailyOrdersPage> {


  @override
  void initState() {
    // TODO: implement initState
    userDataBloc.fetchDailyOrders(UserTokenModel.fake());
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
                return ErrorPage(onClickAction: (){userDataBloc.fetchDailyOrders(UserTokenModel.fake());});
              }
              return Center(child: CircularProgressIndicator());
            }));
    /*  */
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

/*@override
Widget build(BuildContext context) {
  return Scaffold(
      body: SingleChildScrollView(
        *//* list des restaurants *//*
        child: Column(
          children: <Widget>[
            *//* image *//*
            *//* text *//*
            SizedBox(height:40)
          ]
            ..addAll(
                List<Widget>.generate(3, (int index) {
                  return MyOrderWidget();
                })
            ),
        ),
      ));
}
}*/

