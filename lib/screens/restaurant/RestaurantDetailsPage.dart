import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/locale/locale.dart';
import 'package:kaba_flutter/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/screens/home/HomePage.dart';
import 'package:kaba_flutter/screens/restaurant/RestaurantMenuPage.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/Vectors.dart';

class RestaurantDetailsPage extends StatefulWidget {

  static var routeName = "/RestaurantDetailsPage";

  RestaurantDetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {


  ScrollController _scrollController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
  }


  @override
  Widget build(BuildContext context) {
    /* use silver-app-bar first */
    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          centerTitle: true,
          title: Text("Vadout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              )),
          background: Container(
            child: CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://imgix.bustle.com/uploads/image/2018/5/9/fa2d3d8d-9b6c-4df4-af95-f4fa760e3c5c-2t4a9501.JPG?w=970&h=546&fit=crop&crop=faces&auto=format&q=70"),
            // put an image
          )),
    );

    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: new DefaultTabController(
            length: 1,
            child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  flexibleSpaceWidget,
                ];
              },
              body:  SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height:20),
                        /* rounded image - */
                        Container(
                          height:90, width: 90,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider("https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png")
                                )
                            )
                        ),
                        SizedBox(height:20),
                        /* see the menu entry */
                        InkWell(
                          splashColor: Colors.red,
                          child:Container(padding: EdgeInsets.only(top:5,bottom: 5),
                              child:ListTile(
                                  title: Text("See the Menu", style: TextStyle(color:KColors.primaryColor)),
                                  leading: IconButton(icon: Icon(Icons.menu, color: KColors.primaryColor), onPressed: null),
                                  trailing: IconButton(icon: Icon(Icons.chevron_right, color: KColors.primaryColor), onPressed: null),
                                  onTap: (){_jumpToRestaurantMenuPage();}), color: Colors.white),
                        ),
                        SizedBox(height:20),
                        Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child:Column(
                              children: <Widget>[
                                /* description of restaurant */
                                Text("Bar à Yaourt et Dèguè. Du Dèguè comme vous n'en avez jamais dégusté. Régalez vos papilles avec Vadout.",
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Opening Time", style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 16)),
                                    Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                                      IconButton(icon:Icon(Icons.access_time), onPressed: () {},),
                                      Text("13:30-21:00", style: TextStyle(color: Colors.black, fontSize: 16)),
                                    ])
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(mainAxisAlignment: MainAxisAlignment.start,children: <Widget>[
                                  IconButton(icon:Icon(Icons.location_on, color: Colors.blue), onPressed: () {},),
                                  Text("Voie expresse Limousine Agoè", style: TextStyle(color: Colors.black, fontSize: 16)),
                                ]),
                                SizedBox(height: 10),
                                Text("Notes and Reviews", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                                /* 4.0 - stars */
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("4.0", style: TextStyle(fontSize: 100, color: KColors.primaryColor)),
                                    /* stars */
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(children: <Widget>[]
                                            ..addAll(
                                                List<Widget>.generate(5, (int index) {
                                                  return Icon(Icons.star, color: KColors.primaryYellowColor);
                                                })
                                            )
                                          ),
                                          Text("5 Votes", style: TextStyle(color:Colors.grey))
                                        ])
                                  ],
                                ),
                                /* list of commands */
                              ],
                            )
                        ),
                        /* get list */
                        Column(
                          children: <Widget>[],
                        )
                      ]
                        ..addAll(
                            List<Widget>.generate(3, (int index) {
                              return Container(
                                  padding: EdgeInsets.only(top:10, bottom:10),
                                  color: Colors.white,
                                  child:ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider("https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png")
                                          )
                                      ),
                                      height:40, width: 40,
                                    ),
                                    title: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text("Antoine", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Row(children: <Widget>[]
                                            ..addAll(
                                                List<Widget>.generate(5, (int index) {
                                                  return Icon(Icons.star, color: KColors.primaryYellowColor, size: 16);
                                                })
                                            )),
                                          Text("I like you yoghurt in a way you can never imagine. Pleasekeep on doing it this nicely!", textAlign: TextAlign.left, style: TextStyle(color:Colors.black.withAlpha(150), fontSize: 16))
                                        ]
                                    ),
                                  ));
                            }).toList()
                        )
                        ..add(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(iconSize: 20,onPressed: (){}, icon: Icon(Icons.star, size: 20, color: Colors.grey)),
                                Text("Powered by >> Kaba Technlogies")
                              ],
                            )
                        )
                  )),
            )));
  }

  void _jumpToRestaurantMenuPage() {
    Navigator.pushNamed(context, RestaurantMenuPage.routeName);
  }
}
