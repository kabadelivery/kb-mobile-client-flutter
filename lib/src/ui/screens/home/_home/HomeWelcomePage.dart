import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaba_flutter/src/blocs/HomeScreenBloc.dart';
import 'package:kaba_flutter/src/contracts/home_welcome_contract.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/models/HomeScreenModel.dart';
import 'package:kaba_flutter/src/models/RestaurantModel.dart';
import 'package:kaba_flutter/src/ui/customwidgets/GroupAdsWidget.dart';
import 'package:kaba_flutter/src/ui/customwidgets/ShinningTextWidget.dart';
import 'package:kaba_flutter/src/ui/screens/home/HomePage.dart';
import 'package:kaba_flutter/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:kaba_flutter/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:kaba_flutter/src/ui/screens/message/ErrorPage.dart';
import 'package:kaba_flutter/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:kaba_flutter/src/ui/screens/splash/SplashPage.dart';
import 'package:kaba_flutter/src/utils/_static_data/KTheme.dart';
import 'package:kaba_flutter/src/utils/_static_data/Vectors.dart';
import 'package:kaba_flutter/src/utils/functions/CustomerUtils.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:toast/toast.dart';

class HomeWelcomePage extends StatefulWidget {

  HomeScreenModel data;

  static HomeScreenModel standardData;

  HomeWelcomePresenter presenter;

  HomeWelcomePage({Key key, this.title, this.presenter}) : super(key: key);


  final String title;

  @override
  _HomeWelcomePageState createState() => _HomeWelcomePageState();
}

class _HomeWelcomePageState extends State<HomeWelcomePage>  implements HomeWelcomeView {

  static final List<String> popupMenus = ["Logout","Settings"];

  int _carousselPageIndex = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();


  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;

  @override
  void initState() {
    // TODO: implement initState
//    if (widget.data == null)
//      homeScreenBloc.fetchHomeScreenModel();
    super.initState();
    this.widget.presenter.homeWelcomeView = this;
    this.widget.presenter.fetchHomePage();
  }

  @override
  Widget build(BuildContext context) {

    /* init fetch data bloc */
    return Scaffold(
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
                border: new Border(bottom: BorderSide(color: Colors.white, width: 2)),
//                color: Colors.white.withAlpha(60)
            ),
//            padding: EdgeInsets.only(left:8, right: 8, top:8, bottom:8),

            child:Container(child: TextField(decoration:InputDecoration(hintText: widget.data?.feed, hintStyle: TextStyle(color:Colors.white.withAlpha(200))), style: TextStyle(fontSize: 12), enabled: false,)),
//            child:TextField(decoration:InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, )),hintText: widget.data?.feed, hintStyle: TextStyle(color:Colors.white.withAlpha(200))), style: TextStyle(fontSize: 12), enabled: false,),
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
//            IconButton(tooltip: "Scanner", icon: Icon(Icons.center_focus_strong), onPressed: (){_jumpToScanPage();}),
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
        body: _buildHomeScreen(widget.data)
      /* stream builder no interesting, too much data going up and down.
            *
            * use MVP instead.
            *
            * */
//        StreamBuilder(
//            stream: homeScreenBloc.homeScreenModel,
//            builder: (context, AsyncSnapshot<HomeScreenModel> snapshot) {
//              if (snapshot.hasData) {
//                return _buildHomeScreen(snapshot.data);
//              } else if (snapshot.hasError) {
//                return ErrorPage(onClickAction: (){homeScreenBloc.fetchHomeScreenModel();});
//              }
//              return Center(child: CircularProgressIndicator());
//            }
//        )
    );
  }

  void menuChoiceAction(String value) {
    /* jump to the other activity */
    switch(popupMenus.indexOf(value)) {
      case 0:
      /* logout */
        CustomerUtils.clearCustomerInformations().whenComplete((){
          //       get back to the splash page.
//          Navigator.popUntil(context, ModalRoute.withName(SplashPage.routeName));
          Navigator.pushNamedAndRemoveUntil(context, SplashPage.routeName, (r) => false);
        });
        break;
      case 1:
        break;
    }
  }

  void _onItemTapped(int value) {
    /* zwitch */
  }

  _carousselPageChanged(int index) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  _mainRestaurantWidget({RestaurantModel restaurant}) {
    return GestureDetector(
      onTap: ()=>{_jumpToRestaurantDetails(context, restaurant)},
      child: Container (
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
                          image: CachedNetworkImageProvider(Utils.inflateLink(restaurant.pic))
                      )
                  )
              ),
              SizedBox(height: 10),
              Text(restaurant.name, style:TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              SizedBox(height: 10),
              ShinningTextWidget(text: "NEW")
            ]
        ),
      ),
    );
  }

  void _jumpToBestSeller() {
    Navigator.pushNamed(context, BestSellersPage.routeName);
  }

  Future<void> _refresh() async {
    widget.presenter.fetchHomePage();
//    homeScreenBloc.fetchHomeScreenModel();
//    await Future.delayed(const Duration(seconds:1));
//    return;
  }


  void _jumpToScanPage() {}

  Widget _buildHomeScreen(HomeScreenModel data) {

    if (data != null)
      widget.data = data;
    if (widget.data != null)
      return RefreshIndicator(
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
                            autoPlay: data.slider.length > 1 ? true:false,
                            reverse: data.slider.length > 1 ? true:false,
                            enableInfiniteScroll: data.slider.length > 1 ? true:false,
                            autoPlayInterval: Duration(seconds: 5),
                            autoPlayAnimationDuration: Duration(milliseconds: 150),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            height: 9*MediaQuery.of(context).size.width/16,
                            items: data.slider.map((admodel) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: ()=>_jumpToAdsList(data.slider),
                                    child: Container(
                                        height: 9*MediaQuery.of(context).size.width/16,
                                        width: MediaQuery.of(context).size.width,
                                        child:CachedNetworkImage(
                                            imageUrl: Utils.inflateLink(admodel.pic),
                                            fit: BoxFit.cover
                                        )
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )),
                      Positioned(
                          bottom: 10,
                          right:0,
                          child:Padding(
                            padding: const EdgeInsets.only(right:9.0),
                            child: Row(
                              children: <Widget>[]
                                ..addAll(
                                    List<Widget>.generate(data.slider.length, (int index) {
                                      return Container(
                                          margin: EdgeInsets.only(right:2.5, top: 2.5),
                                          height: 9,width:9,
                                          decoration: new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                              border: new Border.all(color: Colors.white),
                                              color: (index==_carousselPageIndex || index==data.slider.length)?Colors.white:Colors.transparent
                                          ));
                                    })
                                  /* add a list of rounded views */
                                ),
                            ),
                          )),
                    ],
                  ),
                  /* top restaurants */
                  SizedBox(child:
                  Table(
                    children: <TableRow>[]
                      ..addAll(
                        // ignore: null_aware_before_operator
                          List<TableRow>.generate(_getRestaurantRowCount(data.resto.length), (int rowIndex) {
                            return TableRow(
                                children:<TableCell>[]
                                  ..addAll(
                                    /*   List<TableCell>.generate ((data.resto.length-rowIndex*3)%4, (int cell_index) {
                                      return
                                        TableCell(child:_mainRestaurantWidget(restaurant:data.resto[cell_index]));
                                    })*/
                                      List<TableCell>.generate (3, (int cell_index) {
                                        if (data.resto.length > rowIndex*3+cell_index) {
                                          return
                                            TableCell(
                                                child: _mainRestaurantWidget(
                                                    restaurant: data
                                                        .resto[rowIndex*3+cell_index]));
                                        } else {
                                          return TableCell(
                                              child: Container());
                                        }
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
                      color: Colors.grey.shade100,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          InkWell(onTap: (){_switchAllRestaurant();},
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
                      color: Colors.grey.shade100,
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
                            // BON PLANS ET CINEMA
                            /* TableRow(
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
                            ) */
                          ],
                        ),
                      )
                  ),
                  /* groups ads */
                  Column(
                      children: <Widget>[]
                        ..addAll(
                            List<Widget>.generate(data.groupad.length, (int index) {
                              return GroupAdsWidget(groupAd: data.groupad[index]);
                            })
                        )
                  )
                ]
            ),
          ));
    else {
      data = HomeWelcomePage.standardData;
      return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Center(child : widget.presenter.isWorking ? CircularProgressIndicator() : Text("page empty"))
      );
    }
/*    setState(() {
      isLoading = false;
    });*/
  }



  int _getRestaurantRowCount(int restaurantCount) {

    int i;
    for(i = 1; i*3 < restaurantCount; i++);
    return i;
  }

  void _switchAllRestaurant() {

    // tell welcome page to switch.
    /*setState(() {
      HomePage.updateSelectedPage(2);
    });*/
  }

  @override
  void networkError() {
    // TODO: implement networkError
    mToast("please connect network");
    /* setState(() {
      hasNetworkError = true;
    });*/
  }

  @override
  void showErrorMessage(String message) {
    // TODO: implement showErrorMessage
    //  hasSystemError = true;
    mToast("error message");
  }

  @override
  void showLoading(bool isLoading) {
    // TODO: implement showLoading
    setState(() {
      this.isLoading = isLoading;
    });
  }

  @override
  void sysError() {
    // TODO: implement sysError
    setState(() {
      hasSystemError = true;
    });
  }

  @override
  void updateHomeWelcomePage(HomeScreenModel data) {
    // TODO: implement updateHomeWelcomePage
    setState(() {
      if (data != null)
        widget.data = data;
    });
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _jumpToAdsList(List<AdModel> slider) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagesPreviewPage(data: slider),
      ),
    );
  }

}


class KabaRoundTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height*0.97);
    path.arcToPoint(Offset(size.width, size.height), radius: Radius.circular(2000));
//    path.lineTo(size.width, size.height*1);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(KabaRoundTopClipper oldClipper) => true;
}
void _jumpToRestaurantDetails(BuildContext context, RestaurantModel restaurantModel) {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel),
    ),
  );
}