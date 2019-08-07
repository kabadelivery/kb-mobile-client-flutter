import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaba_flutter/src/blocs/RestaurantBloc.dart';
import 'package:kaba_flutter/src/locale/locale.dart';
import 'package:kaba_flutter/src/models/RestaurantFoodModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/models/RestaurantSubMenuModel.dart';
import 'package:kaba_flutter/src/ui/screens/auth/login/LoginPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/MessagePage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/food/RestaurantFoodDetailsPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantFoodListWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';

class RestaurantMenuPage extends StatefulWidget {

  static var routeName = "/RestaurantMenuPage";

  RestaurantModel restaurant;

  RestaurantMenuPage({Key key, this.title, this.restaurant}) : super(key: key);

  final String title;

  @override
  _RestaurantMenuPageState createState() => _RestaurantMenuPageState(restaurant);
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {

  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  GlobalKey _menuBasketKey;

  Offset _menuBasketOffset;

  RestaurantModel restaurant;

  List<RestaurantSubMenuModel> data;

  int currentIndex = 0;

  _RestaurantMenuPageState(this.restaurant);

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _computeBasketOffset());
    super.initState();
    _menuBasketKey = GlobalKey();
    restaurantBloc.fetchRestaurantMenuList(restaurant);
  }


  @override
  Widget build(BuildContext context) {

    var appBar =  AppBar (
      backgroundColor: KColors.primaryColor,
      title:  GestureDetector(child:  Row(children: <Widget>[Text("MENU", style:TextStyle(fontSize:14, color:Colors.white)),
        SizedBox(width: 10),
        Container(decoration: BoxDecoration(color: Colors.white.withAlpha(100), borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Text(restaurant.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12,color: Colors.white)))]), onTap: _openDrawer),
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: (){Navigator.pop(context);}),
      actions: <Widget>[
        IconButton(key: _menuBasketKey,icon: Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {})
      ],
    );

    return InnerDrawer(
        key: _innerDrawerKey,
        position: InnerDrawerPosition.start, // required
        onTapClose: true, // default false
//        swipe: true, // default true
        offset: 0.1, // default 0.4
        animationType: InnerDrawerAnimation.quadratic, // default static
        innerDrawerCallback: (a) => print(a), // return bool
        child:  data?.length == null ? Container() : Material(
            child: SafeArea(
                child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.withAlpha(150),height: 1),
                    itemCount: data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: (){setState(() {
                            _innerDrawerKey.currentState.toggle();
                            this.currentIndex = index;
                          });},
                          child: index == this.currentIndex ? Container(color: KColors.primaryColor, padding: EdgeInsets.only(top: 10, bottom: 10, left: 8, right:8), child: Text(data[index].name?.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), textAlign: TextAlign.center)) :
                          Container(color: data[currentIndex].promotion!=0 ? KColors.primaryYellowColor:Colors.transparent, padding: EdgeInsets.only(top: 10, bottom: 10, left: 8, right:8), child: Text(data[index].name?.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: data[currentIndex].promotion==0 ? Colors.black : KColors.primaryColor), textAlign: TextAlign.center)));
                    })
            )
        ),
        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBar,
            body:  Container(
              height: (MediaQuery.of(context).size.height - appBar.preferredSize.height),
              child: Stack(
                children: <Widget>[
                  StreamBuilder(
                      stream: restaurantBloc.restaurantMenu,
                      builder: (context, AsyncSnapshot<List<RestaurantSubMenuModel>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length != 0)
                            return _buildRestaurantMenu(snapshot.data);
                          else
                            return MessagePage(message: "Empty content");
                        } else if (snapshot.hasError) {
                          return ErrorPage(onClickAction: (){restaurantBloc.fetchRestaurantMenuList(restaurant);});
                        }
                        return Center(child: CircularProgressIndicator());
                      }
                  ),
                  Positioned(
                    right:15,
                    top: 10,
                    child: Column(children: <Widget>[
                      SizedBox(height: 10),
                      RotatedBox(child: FlatButton.icon(onPressed: (){_openDrawer();},
                          icon: Icon(Icons.fastfood, color:Colors.white),
                          label: Text("REPAS", style: TextStyle(color: Colors.white)),
                          color: KColors.primaryYellowColor,
                          splashColor: KColors.primaryYellowColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        quarterTurns: -1,
                      ),
                      SizedBox(height: 10),
                      RotatedBox(child: FlatButton.icon(onPressed: (){_openDrawer();},
                          icon: Icon(Icons.fastfood, color:Colors.white),
                          label: Text("SUPP.", style: TextStyle(color: Colors.white)),
                          color: Colors.blue,
                          splashColor: KColors.primaryYellowColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        quarterTurns: -1,
                      ),
                      /*  FloatingActionButton(backgroundColor: KColors.mBlue, child: Icon(Icons.fastfood, color:Colors.white), onPressed: () {},),
                      SizedBox(height: 10),
                      FloatingActionButton(backgroundColor: KColors.primaryYellowColor, child: Icon(Icons.fastfood, color:Colors.white), onPressed: () {},)*/
                    ]),
                  ),
                ],
              ),
            ),
            floatingActionButton:   this.data != null ?  RotatedBox(child: FlatButton.icon(onPressed: (){_openDrawer();},
                icon: Icon(Icons.fastfood, color:Colors.white),
                label: Text("MENU", style: TextStyle(color: Colors.white)),
                color: KColors.primaryColor,
                splashColor: KColors.primaryYellowColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              quarterTurns: -1,
            ) : Container()
        )
    );
  }

  void _openDrawer()
  {
    _innerDrawerKey.currentState.open();
  }

  void _closeDrawer()
  {
    _innerDrawerKey.currentState.close();
  }

  Widget getRow(int i) {
    return new GestureDetector(
      child: new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//        color: index == i ? YColors.color_F9F9F9 : Colors.white,
        color: Colors.white,
        child: new Text("text $i",
            style: TextStyle(
                color: Colors.black,
//                color: index == i ? textColor : YColors.color_666,
//                fontWeight: index == i ? FontWeight.w600 : FontWeight.w400,
                fontSize: 16)),
      ),
      onTap: () {
        setState(() {
//          index = i; //记录选中的下标
//          textColor = YColors.colorPrimary;
        });
      },
    );
  }

  _computeBasketOffset() {
    final RenderBox renderBox = _menuBasketKey.currentContext.findRenderObject();
    _menuBasketOffset = renderBox.localToGlobal(Offset.zero);
  }

  _buildRestaurantMenu(List<RestaurantSubMenuModel> data) {
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {this.data= data;}));
    /* return  ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: data[currentIndex].foods.length,
      itemBuilder: (BuildContext context, int index) {
        return RestaurantFoodListWidget(basket_offset: _menuBasketOffset, food: data[currentIndex].foods[index]);
      },
      key: new Key(new DateTime.now().toIso8601String()),
    );*/


//      SingleChildScrollView(
//        child: Column(
//            children: <Widget>[
    /*          Card(
                              margin: EdgeInsets.all(10),
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.all(10),
                                                child:Column(
                                                  children: <Widget>[
                                                    Container(height:30, width: 30, decoration: BoxDecoration(shape: BoxShape.circle,image: new DecorationImage(fit: BoxFit.cover, image: CachedNetworkImageProvider("https://www.bp.com/content/dam/bp-careers/en/images/icons/graduates-interns-instagram-icon-16x9.png")))),
                                                    SizedBox(height: 5),
                                                    Text("RESTAURANT", style: TextStyle(color: KColors.primaryColor, fontSize: 14)),
                                                    SizedBox(height: 5),
                                                    SizedBox(width: 2*MediaQuery.of(context).size.width/5, child: Text("WINGS'N SHAKE TOTSI",textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(color: KColors.primaryYellowColor, fontSize: 12)),
                                                    )
                                                  ],
                                                ))
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Row(children: <Widget>[Text("Working Hour:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)), Text("11h00-21h00", style: TextStyle(fontSize: 12, color: Colors.black))]),
                                            SizedBox(height: 5),
                                            Container(padding: EdgeInsets.all(5), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(7)), color: Colors.blueAccent.shade700), child:Text("Closed", style: TextStyle(color: Colors.white, fontSize: 12)))
                                          ],
                                        )
                                      ]
                                  )
                              )
                          ),*/
//              Container(
//                child: Column(
    /*children:  List<Widget>.generate(data[currentIndex].foods.length, (int index) {
                      return RestaurantFoodListWidget(basket_offset: _menuBasketOffset, food: data[currentIndex].foods[index]);
                    })*/
//                ),
//              )
//            ]
//        ));

    return SingleChildScrollView (
      child:
      ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: data[currentIndex].foods.length,
        itemBuilder: (BuildContext context, int index) {
//          return RestaurantFoodListWidget(basket_offset: _menuBasketOffset, food: data[currentIndex].foods[index]);
          return _buildFoodListWidget(food:data[currentIndex].foods[index]);
        },
        key: new Key(new DateTime.now().toIso8601String()),
      ),
    );
  }

  _buildFoodListWidget({RestaurantFoodModel food}) {
    return (InkWell(child:Card(
        margin: EdgeInsets.only(left: 10, right: 70, top: 6, bottom: 6),
        child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),   boxShadow: [
              BoxShadow(
                color: Colors.grey..withAlpha(50),
                offset: new Offset(0.0, 2.0),
              )
            ]),
            child:
            Column(children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(top:10, bottom:10, left: 10),
                  leading: Stack(
                    children: <Widget>[
                      Container(
                        height:50, width: 50,
                        decoration: BoxDecoration(
                            border: new Border.all(color: KColors.primaryYellowColor, width: 2),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(Utils.inflateLink(food.pic))
                            )
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(icon: Icon(Icons.add_shopping_cart, color: KColors.primaryColor), onPressed: (){_addFoodToChart();}),
                  title:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${food?.name.toUpperCase()}", overflow: TextOverflow.ellipsis,maxLines: 3, textAlign: TextAlign.left, style: TextStyle(color:Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("${food?.price}", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 20, fontWeight: FontWeight.normal)),

                            (food.promotion!=0 ? Text("${food?.promotion_price}",  overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryColor, fontSize: 20, fontWeight: FontWeight.normal, decoration: TextDecoration.lineThrough))
                                : Container()),

                            Text("FCFA", overflow: TextOverflow.ellipsis,maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color:KColors.primaryYellowColor, fontSize: 10, fontWeight: FontWeight.normal)),
                          ]),
                        ],
                      ),
                    ],
                  )
              )
            ])
        ))
        , onTap: ()=>_jumpToFoodDetails(context, food)));
  }


  _jumpToFoodDetails(BuildContext context, RestaurantFoodModel food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantFoodDetailsPage (food: food),
      ),
    );
  }

    _addFoodToChart() {}
}
