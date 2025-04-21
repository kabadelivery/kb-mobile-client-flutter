
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    // return AwesomeLoader(
    //   loaderType: AwesomeLoader.AwesomeLoader3,
    //   color: widget.color,
    // );
    return SizedBox(
      width: 50,
      height: 50,
      child: LoadingAnimationWidget.threeRotatingDots(
        color: KColors.primaryYellowColor,
        // rightDotColor: const Color(0xFFEA3799),
        size: 60,
      ),
      // LoadingAnimationWidget.twistingDots(
      //   leftDotColor: const Color(0xFF1A1A3F),
      //   rightDotColor: const Color(0xFFEA3799),
      //   size: 60,
      // ),
    );
  }
}
