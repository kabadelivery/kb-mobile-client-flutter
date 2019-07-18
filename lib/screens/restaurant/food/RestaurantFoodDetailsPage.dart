import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kaba_flutter/utils/_static_data/KTheme.dart';


class RestaurantFoodDetailsPage extends StatefulWidget {

  static var routeName = "/RestaurantFoodDetailsPage";

  RestaurantFoodDetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RestaurantFoodDetailsPageState createState() => _RestaurantFoodDetailsPageState();
}

class _RestaurantFoodDetailsPageState extends State<RestaurantFoodDetailsPage> {

  ScrollController _scrollController;

  int _carousselPageIndex = 0;

  List<String> mImages = [
    "https://smppharmacy.com/wp-content/uploads/2019/02/food-post.jpg",
    "https://www.restoconnection.fr/wp-content/uploads/2018/11/les-tendances-2019-dans-la-restauration.jpg",
    "https://100jewishfoods.tabletmag.com/wp-content/uploads/2018/02/Social-Share-v1@2x.png",
    "https://www.goodfood.com.au/content/dam/images/h/1/e/d/m/5/image.related.wideLandscape.940x529.h1dua5.png/1558922095436.jpg",
    "https://cdn.shopify.com/s/files/1/2620/2784/files/slide-1_1400x.progressive.jpg?v=1538539622"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
  }

  _carousselPageChanged(int index) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double expandedHeight = 9*MediaQuery.of(context).size.width/16 + 20;
    /* use silver-app-bar first */
    var flexibleSpaceWidget = new SliverAppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
//        collapseMode: CollapseMode.parallax,
          background:
          Padding(
              padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),
              child: Stack(
                children: <Widget>[
                  CarouselSlider(
                    onPageChanged: _carousselPageChanged,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    reverse: true,
                    enableInfiniteScroll: true,
                    autoPlayInterval: Duration(seconds: 5),
                    autoPlayAnimationDuration: Duration(milliseconds: 300),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    height: expandedHeight,
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
                  ),
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
              )
          )
      ),
    );

    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: DefaultTabController(
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
                      children: <Widget>[
                        Card(
                          margin: EdgeInsets.all(10),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("SALADE DU CHEF", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: KColors.primaryColor)),
                                    SizedBox(height: 20),
                                    /* either promotion or not we can use different type */
//                                    Text("3000FCFA", style: TextStyle(fontSize: 30, color: KColors.primaryYellowColor)),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text("3500", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                                          SizedBox(width: 10),
                                          Text("1750", style: TextStyle(color: KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 10),
                                          Text("FCFA", style: TextStyle(color:KColors.primaryYellowColor, fontSize: 12))
                                        ]),
                                    SizedBox(height: 10),
                                    Text("Chicken wings barbecue épicé (10 pièces). 50% de Remise chaque Mardi su tous les Chicken Wings.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withAlpha(150), fontSize: 14)),
                                    SizedBox(height: 20)
                                  ]
                              )),
                        ),
                        Card(
                            margin: EdgeInsets.all(10),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            height:35, width: 35,
                                            child:CachedNetworkImage(fit:BoxFit.cover,imageUrl: "https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png"),
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(10),
                                              child:Column(
                                                children: <Widget>[
                                                  Text("RESTAURANT", style: TextStyle(color: KColors.primaryColor, fontSize: 14)),
                                                  SizedBox(height: 5),
                                                  SizedBox(width: 2*MediaQuery.of(context).size.width/5, child:
                                                  Text("LA MAISON DES PETITES SAVEURS",textAlign: TextAlign.center, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 12)),
                                                  )
                                                ],
                                              ))
                                        ],
                                      ),
                                      Container(
                                          color: KColors.primaryColor,
                                          child: SizedBox(
                                              width: 6,
                                              height:100
                                            /* height is max*/
                                          )),
                                      Text("3.000", style: TextStyle(fontSize: 30, color: KColors.primaryYellowColor)),
                                    ]
                                )
                            )
                        )
                      ]
                  ),

                )
            )
        )
    );
  }
}
