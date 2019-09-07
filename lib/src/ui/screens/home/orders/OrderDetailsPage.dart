import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class OrderDetailsPage extends StatefulWidget {

 static var routeName = "/OrderDetailsPage";
 
  OrderDetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar (
        backgroundColor: KColors.primaryColor,
        title: Text("Command Details", style:TextStyle(fontSize:20, color:Colors.white))),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Container(width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top:15, bottom:15, right:10, left:10),
                  color: Colors.green,child: Text("COMMAND DELIVEVRED SUCCESSFULLY", style: TextStyle(fontSize: 18, color: Colors.white))),

              /*  */
            ]
        ),
      ),
    );
  }
}
