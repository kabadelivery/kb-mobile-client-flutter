import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MyHomePage extends StatefulWidget {

 static var routeName = "/MyHomePage";
 
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            children: <Widget>[
            /* image */
              /* text */
            ]
        ),
      ),
    );
  }
}
