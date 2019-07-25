import 'package:flutter/material.dart';
import 'dart:async';

/*
_shiningText({ textColorsMap : const [Colors.white, Colors.red], List<Color> bgColorsMap = const [Colors.red, Colors.black12], text="PROMO"}) {

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
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';

class ShinningTextWidget extends StatefulWidget {

  String text;
  int timeOut;

  ShinningTextWidget({this.text, this.timeOut=1000});

  @override
  _ShinningTextWidgetState createState() {
    // TODO: implement createState
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
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: bgColorsMap[step]),
              child:Text(
                  widget.text,
                  style: TextStyle(color: textColorsMap[step], fontSize: 10)
              ), duration: Duration(milliseconds: (widget.timeOut/3).round())));
  }

  final List<Color> textColorsMap = const [Colors.white, KColors.primaryColor];
  final List<Color> bgColorsMap = const [KColors.primaryColor, Colors.black12];

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