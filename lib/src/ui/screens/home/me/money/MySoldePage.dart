import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';


class MySoldePage extends StatefulWidget {

  static var routeName = "/MySoldePage";

  MySoldePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySoldePageState createState() => _MySoldePageState();
}

class _MySoldePageState extends State<MySoldePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("SOLDE", style:TextStyle(color:KColors.primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: <Widget>[
              SizedBox(height: 180, child:
              Card(color: KColors.primaryColor,
                  child: Container(margin: EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: KColors.primaryYellowColor, width: 3)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
                        Text("Solde", style: TextStyle(color: Colors.white, fontSize: 16)),
                        Text("XOF 0", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      ])))),
              SizedBox(height: 60),
              /* leave some space, then have the topup option and credit kaba option */
              Container(color:Colors.white, padding: EdgeInsets.only(left: 15, right: 5, top:5, bottom:5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Recharger", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                      IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: () {})],
                  )),
              SizedBox(height: 1),
              Container(color:Colors.white, padding: EdgeInsets.only(left: 15, right: 5, top:5, bottom:5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Points KABA", style: TextStyle(color: KColors.primaryColor, fontSize: 16)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text("1500pts", style: TextStyle(color: Colors.black, fontSize: 14)),
                            SizedBox(width: 5),
                            IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: () {})
                          ])
                    ],
                  )),
            ]
        ),
      ),
    );
  }
}
