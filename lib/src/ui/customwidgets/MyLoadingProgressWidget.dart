import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

class MyLoadingProgressWidget extends StatefulWidget {


  var color;

  MyLoadingProgressWidget({this.color = KColors.primaryColor});

  @override
  _MyLoadingProgressWidgetState createState() {
    return _MyLoadingProgressWidgetState();
  }

}

class _MyLoadingProgressWidgetState extends State<MyLoadingProgressWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AwesomeLoader(
      loaderType: AwesomeLoader.AwesomeLoader3,
      color: widget.color,
    );
  }


}