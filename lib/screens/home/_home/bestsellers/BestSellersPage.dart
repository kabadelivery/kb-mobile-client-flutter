import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/Vectors.dart';


class BestSellersPage extends StatefulWidget {

  static var routeName = "/BestSellersPage";

  BestSellersPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BestSellersPageState createState() => _BestSellersPageState();
}

class _BestSellersPageState extends State<BestSellersPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("BEST SELLERS", style:TextStyle(color:KColors.primaryColor)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: KColors.primaryColor), onPressed: (){Navigator.pop(context);}),
      ),
      body: Container(
          child: ListView.builder(itemCount:10,itemBuilder: (BuildContext context, int position){
            return Card (
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                      child: Text("${position+1}.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28))),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Container(padding: EdgeInsets.only(bottom: 10),
                            child: Text("WINGS N SHAKE BAGUIDA", style: TextStyle(fontSize: 18, color: KColors.primaryColor, fontWeight: FontWeight.bold))),
                        Row(children: <Widget>[
                          Container(
                            height:60, width: 60,
                            child:CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png"),
                          ),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Column(children: <Widget>[
                                Text("AYIMOLOU BASIQUE 3", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                Text("1.500 FCFA", style: TextStyle(fontSize: 20,color: KColors.primaryYellowColor)),
                              ]))
                        ]),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[]
                              ..addAll(
                                  List<Widget>.generate(3, (int index) {
                                    return Column(children: <Widget>[
                                      Text("Ven", style: TextStyle(color: Colors.black.withAlpha(150))),
                                      IconButton(iconSize: 40,icon: Icon(Icons.trending_down,color: Colors.red), onPressed: null,)
                                    ]);
                                  })
                              )
                        )
                      ]),
                    ],
                  ),
                ));
          })
      ),
    );
  }
}
