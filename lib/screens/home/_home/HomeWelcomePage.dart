import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaba_flutter/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/utils/_static_data/my_flutter_app_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/_data/model/_RestaurantModel.dart';
import 'package:kaba_flutter/utils/customwidgets/GroupAdsWidget.dart';
import 'package:kaba_flutter/utils/customwidgets/ShinningTextWidget.dart';

class HomeWelcomePage extends StatefulWidget {
  HomeWelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeWelcomePageState createState() => _HomeWelcomePageState();
}

class _HomeWelcomePageState extends State<HomeWelcomePage> {

  static final List<String> popupMenus = ["Settings"];

  List<String> mImages = [
    "http://app1.kaba-delivery.com/slider/Fditr1kfuV2nVmf.jpg",
  "http://app1.kaba-delivery.com/slider/slider_1061552403092.jpg",
  "http://app1.kaba-delivery.com/slider/Lk8nmkLoqzgvEIR.jpg",
  "http://app1.kaba-delivery.com/slider/slpUfVfXivO4uZd.jpg",
  ];

  int _carousselPageIndex = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child:TextField(decoration:
            InputDecoration.collapsed(hintText: "Play basketball with us today, ar yo ok with that", hintStyle: TextStyle(color:Colors.white.withAlpha(200))), enabled: false,),
            color: Colors.transparent,
          ),
          leading: IconButton(icon: SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                VectorsData.kaba_icon_svg,
                color: Colors.white,
              )), onPressed: (){_jumpToScanPage();}),
          backgroundColor: KColors.primaryColor,
          actions: <Widget>[
            IconButton(tooltip: "Scanner", icon: Icon(Icons.center_focus_strong), onPressed: (){_jumpToScanPage();}),
//            IconButton(icon: Icon(Icons.search, color: Colors.white), tooltip: "Search", onPressed: () {}),
            PopupMenuButton<String>(
              onSelected: menuChoiceAction,
              itemBuilder: (BuildContext context) {
                return popupMenus.map((String menuName){
                  return PopupMenuItem<String>(value: menuName, child: Text(menuName));
                }).toList();
              },
            )
          ],
        ),
        body:  RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    /*top slide*/
                    Stack(
                      children: <Widget>[
                        ClipPath(
                            clipper: KabaRoundTopClipper(),
                            child:CarouselSlider(
                              onPageChanged: _carousselPageChanged,
                              viewportFraction: 1.0,
                              autoPlay: true,
                              reverse: true,
                              enableInfiniteScroll: true,
                              autoPlayInterval: Duration(seconds: 5),
                              autoPlayAnimationDuration: Duration(milliseconds: 300),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              height: 9*MediaQuery.of(context).size.width/16,
                              items: [1,2,3,4,5].map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        height: 9*MediaQuery.of(context).size.width/16,
                                        width: 9*MediaQuery.of(context).size.width,
                                        child:CachedNetworkImage(
                                            imageUrl: mImages[i%mImages.length],
                                            fit: BoxFit.cover
                                        )
                                    );
                                  },
                                );
                              }).toList(),
                            )),
                        Positioned(
                            bottom: 10,
                            right:0,
                            child:Row(
                              children: <Widget>[]
                                ..addAll(
                                    List<Widget>.generate(mImages.length, (int index) {
                                      return Container(
                                          margin: EdgeInsets.only(right:2.5, top: 2.5),
                                          height: 10,width:10,
                                          decoration: new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                              border: new Border.all(color: Colors.white),
                                              color: (index==_carousselPageIndex || index==mImages.length)?Colors.white:Colors.transparent
                                          ));
                                    })
                                  /* add a list of rounded views */
                                ),
                            )),
                      ],
                    ),
                    /* top restaurants */
                    SizedBox(child:
                    Table(
                      children: <TableRow>[]
                        ..addAll(
                            List<TableRow>.generate(1, (int row_index) {
                              return TableRow(
                                  children:<TableCell>[]
                                    ..addAll(
                                        List<TableCell>.generate (3, (int cell_index) {
                                          return
                                            TableCell(child:_mainRestaurantWidget());
                                        })
                                    ));
                            })
                          /* add a list of rounded views */
                        ),
                    )),
                    /* all the restaurants button*/
                    SizedBox(height: 10),
                    Container(
                        padding: EdgeInsets.only(top:20, bottom:20),
                        color: Colors.grey.shade300,
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            InkWell(onTap: (){},
                                child:Container(
                                    decoration: BoxDecoration(color:Colors.white, borderRadius: new BorderRadius.only(topLeft:  const  Radius.circular(20.0), bottomLeft: const  Radius.circular(20.0))),
                                    padding: EdgeInsets.only(left:10),
                                    child:
                                    Row(children:<Widget>[
                                      Text("ALL RESTAURANTS", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold)),
                                      IconButton(onPressed: null, icon: Icon(Icons.chevron_right, color: KColors.primaryColor,))
                                    ]))
                            )
                          ],
                        )),
                    /* meilleures ventes, cinema, evenemnts, etc... */
                    Container(
                        color: Colors.grey.shade300,
                        child:Card(
                          color: Colors.white,
                          margin: EdgeInsets.all(10),
                          child: Table(
                            /* table */
                            children: <TableRow>[
                              TableRow(
                                  children: <TableCell>[
                                    TableCell(
                                      child: Container(
                                        padding:EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            GestureDetector(
                                                child:Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text("BEST SELLERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.primaryColor)),
                                                        Container(
                                                          padding: EdgeInsets.all(5),
                                                          height:90, width: 120,
                                                          child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://i2.wp.com/assemblee-messianique.fr/wp-content/uploads/2018/09/globe-png-transparent-background-8.png?ssl=1"),
                                                        ),
                                                      ],
                                                    )), onTap: _jumpToBestSeller),
                                            Column(
                                              children: <Widget>[
                                                Text("EVENEMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.primaryYellowColor)),
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  height:90, width: 120,
                                                  child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://tz5spe4rrwpn7tzx-zippykid.netdna-ssl.com/wp-content/uploads/2019/05/grad-cap-1280x960.png"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ]
                              ),
                              TableRow(
                                  children: <TableCell>[
                                    TableCell(
                                      child: Container(
                                        padding:EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Text("CINEMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.mGreen)),
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  height:90, width: 120,
                                                  child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://freepngimg.com/thumb/roar/35300-2-lioness-roar-transparent-background.png"),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Text("BON PLANS", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: Colors.black)),
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  height:90, width: 120,
                                                  child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: "https://clipart.info/images/ccovers/1495725897Free-spiderman-png-transparent-background.png"),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ]
                              ),
                            ],
                          ),
                        )
                    ),
                    /* groups ads */
                    Column(
                        children: <Widget>[]
                          ..addAll(
                              List<Widget>.generate(3, (int index) {
                                return GroupAdsWidget();
                              })
                          )
                    )
                  ]
              ),
            ))
    );
  }

  void menuChoiceAction(String value) {
    /* jump to the other activity */
  }

  void _onItemTapped(int value) {
    /* zwitch */
  }

  _carousselPageChanged(int index) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  _mainRestaurantWidget({name="WINGS'N SHAKE TOTSI", imgUrl="http://www.tourismematane.com/adaptive/images/Upload/Membres/mc-donalds.png", isPromo=true, isNew=false}) {
    return Container (
      padding: EdgeInsets.only(top:20, right:15, left:15),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container (
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(imgUrl)
                    )
                )
            ),
            SizedBox(height: 10),
            Text(name, style:TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            SizedBox(height: 10),
            ShinningTextWidget(text: "NEW")
          ]
      ),
    );
  }


  void _jumpToBestSeller() {
    Navigator.pushNamed(context, BestSellersPage.routeName);
  }

  Future<void> _refresh() {
    setState(() {

    });
  }

  void _jumpToScanPage() {}
}


class KabaRoundTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.arcToPoint(Offset(size.width, size.height), radius: Radius.circular(1000));
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(KabaRoundTopClipper oldClipper) => true;
}
