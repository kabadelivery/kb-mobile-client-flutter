import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

class MyNormalLoadingProgressWidget extends StatefulWidget {


  var color;

  bool isMini;

  MyNormalLoadingProgressWidget({this.color = KColors.primaryColor, this.isMini = false});

  @override
  _MyNormalLoadingProgressWidgetState createState() {
    return _MyNormalLoadingProgressWidgetState();
  }

}

class _MyNormalLoadingProgressWidgetState extends State<MyNormalLoadingProgressWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(widget.color)), height: widget.isMini ? 15 : 15, width: widget.isMini ? 15 : 15);
  }


}