import 'package:flutter/material.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/customwidgets/RestaurantListWidget.dart';


class RestaurantListPage extends StatefulWidget {
  RestaurantListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          /* list des restaurants */
          child: Column(
            children: <Widget>[
              /* image */
              /* text */
              SizedBox(height:40)
            ]
              ..addAll(
                  List<Widget>.generate(12, (int index) {
                    return RestaurantListWidget();
                  })
              ),
          ),
        ));
  }
}
