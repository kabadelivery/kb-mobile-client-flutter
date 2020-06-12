import 'dart:async';

import 'package:KABA/src/contracts/ads_viewer_contract.dart';
import 'package:KABA/src/contracts/bestseller_contract.dart';
import 'package:KABA/src/contracts/customercare_contract.dart';
import 'package:KABA/src/contracts/evenement_contract.dart';
import 'package:KABA/src/contracts/home_welcome_contract.dart';
import 'package:KABA/src/contracts/restaurant_details_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/HomeScreenModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/customwidgets/GroupAdsWidget.dart';
import 'package:KABA/src/ui/customwidgets/ShinningTextWidget.dart';
import 'package:KABA/src/ui/screens/home/ImagesPreviewPage.dart';
import 'package:KABA/src/ui/screens/home/_home/InfoPage.dart';
import 'package:KABA/src/ui/screens/home/_home/bestsellers/BestSellersPage.dart';
import 'package:KABA/src/ui/screens/home/me/customer/care/CustomerCareChatPage.dart';
import 'package:KABA/src/ui/screens/home/me/settings/SettingsPage.dart';
import 'package:KABA/src/ui/screens/restaurant/RestaurantDetailsPage.dart';
import 'package:KABA/src/ui/screens/splash/SplashPage.dart';
import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/FlareData.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/MusicData.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:KABA/src/utils/_static_data/Vectors.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../../../../StateContainer.dart';
import 'events/EventsPage.dart';



class HomeWelcomePage extends StatefulWidget {

  HomeScreenModel data;

  static HomeScreenModel standardData;

  HomeWelcomePresenter presenter;

  CustomerModel customer;

  HomeWelcomePage({Key key, this.title, this.presenter}) : super(key: key);


  final String title;

  @override
  _HomeWelcomePageState createState() => _HomeWelcomePageState();
}

class _HomeWelcomePageState extends State<HomeWelcomePage>  implements HomeWelcomeView {

  static List<String> popupMenus;

  int _carousselPageIndex = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;
  bool hasNetworkError = false;
  bool hasSystemError = false;


  @override
  void initState() {
    super.initState();

    popupMenus = ["Logout", "Settings"];
    this.widget.presenter.homeWelcomeView = this;
    showLoading(true);

    CustomerUtils.getCustomer().then((customer) {
      // check if i token updates successfully
      // ignore: unrelated_type_equality_checks
      if (CustomerUtils.isPusTokenUploaded() != true) {
        this.widget.presenter.updateToken(customer);
      }
      popupMenus = ["${AppLocalizations.of(context).translate('logout')}","${AppLocalizations.of(context).translate('settings')}"];
    });

    this.widget.presenter.fetchHomePage();

    CustomerUtils.getCustomer().then((customer) {
      widget.customer = customer;
      this.widget.presenter.checkUnreadMessages(customer);
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool has_subscribed = false;
      try {
        prefs.getBool('has_subscribed');
      } catch(_) {
        has_subscribed = false;
      }
      if (has_subscribed == false) {
        FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
        _firebaseMessaging.subscribeToTopic(ServerConfig.TOPIC).whenComplete(() => {
          prefs.setBool('has_subscribed', true)
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    /* init fetch data bloc */
    return Scaffold(
        appBar: AppBar(brightness: Brightness.dark,
          title: SizedBox(height: 70,
//            margin: EdgeInsets.only(bottom: 30, top: 30),
//            decoration: BoxDecoration(
//                border: new Border(bottom: BorderSide(color: Colors.white, width: 2)),
//                color: Colors.yellow
//            ),
//            padding: EdgeInsets.only(left:8, right: 8, top:8, bottom:8),

              child:Container( margin: EdgeInsets.only(bottom: 15, top: 20),
                decoration: BoxDecoration(
                  border: new Border(bottom: BorderSide(color: Colors.white, width: 1)),
//                color: Colors.white.withAlpha(30)
                ),
                child:Container(child: TextField(textAlign: TextAlign.center,decoration:InputDecoration(hintText: widget.data?.feed == null ? "KABA DELIVERY" : widget.data?.feed , hintStyle: TextStyle(color:Colors.white)), style: TextStyle(fontSize: _textSizeWithText(widget.data?.feed)), enabled: false)),
//                child: TextField(decoration:InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, )),hintText: widget.data?.feed, hintStyle: TextStyle(color:Colors.white.withAlpha(200))), style: TextStyle(fontSize: 12), enabled: false,)),
              )),
          leading: IconButton(icon: SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                VectorsData.kaba_icon_svg,
                color: Colors.white,
              )), onPressed: (){_jumpToInfoPage();}),
          backgroundColor: KColors.primaryColor,
          actions: <Widget>[
            InkWell(onTap: ()=>_jumpToPage(context, CustomerCareChatPage(presenter: CustomerCareChatPresenter())),
              child: Container(width: 60,height:60,
                child: FlareActor(
                    FlareData.new_message,
                    alignment: Alignment.center,
                    animation: "normal",
                    fit: BoxFit.contain,
                    isPaused : StateContainer.of(context).hasUnreadMessage != true
                ),
              ),
            ),
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
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child:  _buildHomeScreen(widget.data),
        )
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
        _jumpToPage(context, SettingsPage());
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
              _getShinningImage(restaurant)
            ]
        ),
      ),
    );
  }

  void _jumpToBestSeller() {
//    Navigator.pushNamed(context, BestSellersPage.routeName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BestSellersPage (presenter: BestSellerPresenter()),
      ),
    );
  }

  void _jumpToEvents() {
//    Navigator.pushNamed(context, BestSellersPage.routeName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvenementPage (presenter: EvenementPresenter()),
      ),
    );
  }


  Future<void> _refresh() async {
    widget.presenter.fetchHomePage();
//    homeScreenBloc.fetchHomeScreenModel();
//    await Future.delayed(const Duration(seconds:1));
//    return;
  }


  void _jumpToInfoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(), // ramener infos
      ),
    );
  }

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
                                    onTap: ()=>_jumpToAdsList(data.slider, data.slider.indexOf(admodel)),
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
                                    Text("${AppLocalizations.of(context).translate('all_restaurants')}", style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold)),
                                    IconButton(onPressed: null, icon: Icon(Icons.chevron_right, color: KColors.primaryColor,))
                                  ]))
                          )
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(top:20, bottom:20),
                      color: Colors.grey.shade100,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          InkWell(onTap: (){_callCustomerCare();},
                              child:Container(
                                  decoration: BoxDecoration(color:Colors.white, borderRadius: new BorderRadius.only(topRight:  const  Radius.circular(20.0), bottomRight: const  Radius.circular(20.0))),
                                  padding: EdgeInsets.only(right:10),
                                  child:
                                  Row(children:<Widget>[
                                    SizedBox(width: 5),
                                    Container(height: 50, width: 40,
                                      decoration: BoxDecoration(
                                          image: new DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(Utils.inflateLink("/web/assets/app_icons/call.gif"))
                                          )
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text("${AppLocalizations.of(context).translate('call_us')}", style: TextStyle(color: KColors.mGreen, fontWeight: FontWeight.bold)),
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
                                          InkWell(
                                              child:Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text("${AppLocalizations.of(context).translate('best_seller')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.primaryColor)),
                                                      Container(
                                                        padding: EdgeInsets.all(5),
                                                        height:90, width: 120,
                                                        child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl: Utils.inflateLink(widget.data.promotion.pic)),
                                                      ),
                                                    ],
                                                  )), onTap: _jumpToBestSeller),
                                          InkWell(onTap: _jumpToEvents,
                                            child: Container(
                                              child: Column(
                                                children: <Widget>[
                                                  Text("${AppLocalizations.of(context).translate('events')}", style: TextStyle(fontWeight: FontWeight.bold, fontSize:16, color: KColors.primaryYellowColor)),
                                                  Container(
                                                    padding: EdgeInsets.all(5),
                                                    height:90, width: 120,
                                                    child:CachedNetworkImage(fit:BoxFit.fitHeight,imageUrl:Utils.inflateLink(widget.data.event.pic)),
                                                  ),
                                                ],
                                              ),
                                            ),
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
          child: Center(child : isLoading ? CircularProgressIndicator() :
          Container(
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(icon: Icon(Icons.flight_takeoff, color: Colors.grey)),
                SizedBox(height: 5),
                Container(margin: EdgeInsets.only(left:20,right:20),child: Text("${AppLocalizations.of(context).translate('home_page_loading_error')}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                SizedBox(height: 5),

                RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
//                    side: BorderSide(color: Colors.red)
                    ),
                    color: Colors.yellow,child: Text("${AppLocalizations.of(context).translate('try_again')}"), onPressed: () {widget.presenter.fetchHomePage();})
              ],
            ),
          )
          )
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
    StateContainer.of(context).updateTabPosition(tabPosition: 1);
  }

  @override
  void networkError() {
    // TODO: implement networkError
    showLoading(false);
    mToast("${AppLocalizations.of(context).translate('network_error')}");
    /* setState(() {
      hasNetworkError = true;
    });*/
  }

  @override
  void showErrorMessage(String message) {
    // TODO: implement showErrorMessage
    //  hasSystemError = true;
    showLoading(false);
    mToast("${AppLocalizations.of(context).translate('error_message')}");
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

  _jumpToAdsList(List<AdModel> slider, int position) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsPreviewPage(data: slider, position:position, presenter: AdsViewerPresenter()),
      ),
    );
  }

  _textSizeWithText(String feed) {

    double ssize = 0;
    if (feed != null)
      ssize = 1.0 * feed?.length;
    // from 8 to 16 according to the size.
    // 8 for more than ...
    // to 16 as maximum.
    return  (230 - 2*ssize)/13;
  }

  Future<void> _callCustomerCare() async {
//    Toast.show("call customer care", context);
    const url = "tel:+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // ask launch.
      Toast.show("Call error", context);
    }
  }

  @override
  void tokenUpdateSuccessfully() {
    CustomerUtils.setPushTokenUploadedSuccessfully();
  }

  @override
  void hasUnreadMessages(bool hasNewMessage) {
    if (hasNewMessage){

      // check inside the sharedprefs
      if (!StateContainer.of(context).hasGotNewMessageOnce) {
        StateContainer.of(context).updateHasGotNewMessage(hasGotNewMessage: true);
        _playMusicForNewMessage();
      }
        setState(() {
          StateContainer.of(context).updateUnreadMessage(
              hasUnreadMessage: hasNewMessage);
        });
    } else {
      setState(() {
        StateContainer.of(context).updateUnreadMessage(hasUnreadMessage: false);
      });
    }
  }

  _getShinningImage(RestaurantModel restaurant) {

    //
    if (restaurant.is_new == 1){
      // new logo
      return ShinningTextWidget(text:"${AppLocalizations.of(context).translate('new')}", backgroundColor: KColors.primaryYellowColor, textColor: Colors.white);
    } else {
      if (restaurant.is_promotion == 1) {
        // promotion
        return ShinningTextWidget(text:"${AppLocalizations.of(context).translate('promo')}", backgroundColor: KColors.primaryColor, textColor: Colors.white);
      } else {
        return Container();
      }
    }
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

void _jumpToPage (BuildContext context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );
}

Future<void> _playMusicForNewMessage() async {
  // play music
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  audioPlayer.setVolume(1.0);
  AudioPlayer.logEnabled = true;
  var audioCache = new AudioCache(fixedPlayer: audioPlayer);
  audioCache.play(MusicData.new_message);
  if (await Vibration.hasVibrator()
  ) {
    Vibration.vibrate(duration: 500);
  }
}

void _jumpToRestaurantDetails(BuildContext context, RestaurantModel restaurantModel) {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RestaurantDetailsPage(restaurant: restaurantModel, presenter: RestaurantDetailsPresenter()),
    ),
  );
}