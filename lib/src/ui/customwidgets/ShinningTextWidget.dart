import 'package:flutter/material.dart';
import 'dart:async';

/*
_shiningText({ textColorsMap : const [Colors.white, Colors.red], List<Color> bgColorsMap = const [Colors.red, KColors.new_black12], text="PROMO"}) {

  const timeout = const Duration(seconds: 3);

  return
    Container(
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(6)), color: bgColorsMap[i]),
        child:Text(
            text,
            style: TextStyle(color: textColorsMap[i], fontSize: 10)
        ));
}
startTimeout([int milliseconds]) {
  var duration = milliseconds == null ? timeout : ms * milliseconds;
  return new Timer(duration, handleTimeout);
}
void handleTimeout() {  // callback function

}*/

import 'package:flutter/cupertino.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';

class ShinningTextWidget extends StatefulWidget {

  String text;
  int timeOut;

  var backgroundColor;
  var textColor;

  ShinningTextWidget({this.text, this.textColor = Colors.white, this.backgroundColor = KColors.primaryColor, this.timeOut=1000});

  @override
  _ShinningTextWidgetState createState() {
    return _ShinningTextWidgetState();
  }

}

class _ShinningTextWidgetState extends State<ShinningTextWidget> {

  int step = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    startTimeout(widget.timeOut);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      (
          AnimatedContainer(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: widget.backgroundColor),
              child:Text(
                  widget.text,
                  style: TextStyle(color: widget.textColor, fontSize: 10)
              ), duration: Duration(milliseconds: (widget.timeOut/3).round())));
  }

//  final List<Color> textColorsMap = const [Colors.white, KColors.primaryColor];
//  final List<Color> bgColorsMap = const [KColors.primaryColor, KColors.new_black12];

  startTimeout([int milliseconds]) {
    return new Timer(Duration(milliseconds: milliseconds), handleTimeout);
  }

  void handleTimeout() {
    setState(() {
      step = (step == 0 ? 1 : 0);
    });
    startTimeout(widget.timeOut);
  }
}