import 'package:flutter/material.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/customwidgets/MyOrderWidget.dart';
import 'package:kaba_flutter/utils/customwidgets/RestaurantListWidget.dart';


class DailyOrdersPage extends StatefulWidget {
  DailyOrdersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DailyOrdersPageState createState() => _DailyOrdersPageState();
}

class _DailyOrdersPageState extends State<DailyOrdersPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          /* list des restaurants */
          child: Column(
            children: <Widget>[
              /* image */
              /* text */
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
}

