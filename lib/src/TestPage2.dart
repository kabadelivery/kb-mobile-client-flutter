

import 'dart:math';

import 'package:KABA/src/ui/customwidgets/MyVoucherMiniWidget.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  @override
  _Test2PageState createState() => _Test2PageState();
}

class _Test2PageState extends State<TestPage2> {

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SingleChildScrollView(
        child: Column(children: <Widget>[]
          ..addAll(List.generate(10, (index) => MyVoucherMiniWidget()).toList())
        ),
      ),
    );
  }


}


