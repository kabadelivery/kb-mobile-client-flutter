import 'dart:async';

import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/blocs/RestaurantBloc.dart';
import 'package:KABA/src/contracts/restaurant_list_food_proposal_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/RestaurantFoodModel.dart';
import 'package:KABA/src/models/RestaurantModel.dart';
import 'package:KABA/src/ui/customwidgets/FoodWithRestaurantDetailsWidget.dart';
import 'package:KABA/src/ui/customwidgets/RestaurantListWidget.dart';
import 'package:KABA/src/ui/screens/message/ErrorPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:android_intent/android_intent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


class RestaurantListPage extends StatefulWidget {

  Position location;

  RestaurantFoodProposalPresenter presenter;

  RestaurantListPage({Key key, this.location, this.presenter}) : super(key: key);

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> implements RestaurantFoodProposalView {

  var _filterEditController = TextEditingController();

  List<RestaurantModel> data;

  bool _searchMode = false;

  Color filter_unactive_button_color = KColors.primaryColor, filter_active_button_color = Colors.white,
      filter_unactive_text_color = Colors.white, filter_active_text_color = KColors.primaryColor;

  int searchTypePosition = 1;

  bool searchMenuHasSystemError = false, searchMenuHasNetworkError = false;
  bool isSearchingMenus = false;

  List<RestaurantFoodModel> foodProposals = null;

  String _filterDropdownValue;

  GlobalKey firstItemKey = GlobalKey();

  ScrollController _searchListScrollController = ScrollController();
  ScrollController _restaurantListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

//    _filterDropdownValue = "${AppLocalizations.of(context).translate('cheap_to_exp')}";

    widget.presenter.restaurantFoodProposalView = this;

    _filterEditController.addListener(_filterEditContent);

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

      if (StateContainer?.of(context)?.location == null) {
        restaurantBloc.fetchRestaurantList();
        _getLastKnowLocation();
      } else
        restaurantBloc.fetchRestaurantList(position: StateContainer?.of(context)?.location);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _filterEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body:  AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child:  StreamBuilder(
                stream: restaurantBloc.restaurantList,
                builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
                  if (snapshot.hasData) {
                    return _buildRestaurantList(snapshot.data);
                  } else if (snapshot.hasError) {
                    return ErrorPage(message:"${AppLocalizations.of(context).translate('network_error')}", onClickAction: (){
                      setState(() {
                        restaurantBloc.fetchRestaurantList(position: StateContainer.of(context).location);
                      });
                    });
                  }
                  return Center(child: CircularProgressIndicator());
                })));
    /*  */
  }


  Map pageRestaurants = Map<int, dynamic>();

  _buildRestaurantList(List<RestaurantModel> d) {

    this.data = d;

    // filter restaurant into a map
    d.forEach((restaurant) {
      pageRestaurants[restaurant.id] = restaurant;
    });

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        //    leading: null,
        backgroundColor: Colors.grey.shade100,
        title: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
//            border: new Border.all(color: Colors.white),
              color: Colors.white
          ),
          padding: EdgeInsets.only(left:8, right: 8),
          margin: EdgeInsets.only(top:8, bottom:8),
          child:Row(
            children: <Widget>[
              Expanded(
                child: Focus( onFocusChange: (hasFocus) {
                  if(hasFocus) {
                    // do staff
                    _searchMode = true;
                  } else {
                    // out search mode
//                    mToast("Out search mode");
                    _searchMode = false;
                  }
                },
                  child: TextField(controller: _filterEditController, onSubmitted: (val) {
                    if (searchTypePosition == 2)
                      widget.presenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
                  }, style: TextStyle(color: Colors.black, fontSize: 16), textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(hintText: "${AppLocalizations.of(context).translate('find_menu_or_restaurant')}", hintStyle: TextStyle(fontSize: 15, color:Colors.grey)), enabled: true),
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.close, color: Colors.grey), onPressed: () {
                    _clearFocus();
                  }),
                  searchTypePosition == 2 ? IconButton(icon: Icon(Icons.search, color: KColors.primaryYellowColor), onPressed: () {
                    if (searchTypePosition == 2)
                      widget.presenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
                  }) : Container(),
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(color: Colors.white,
        child: Column(
          children: <Widget>[
            SizedBox(height:10),
            Container(padding: EdgeInsets.only(left:20,right:20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_unactive_button_color : this.filter_unactive_button_color, borderRadius: BorderRadius.all(const  Radius.circular(40.0)),
                      border: new Border.all(color: searchTypePosition == 2 ? this.filter_unactive_button_color : this.filter_unactive_button_color, width: 1),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          InkWell(onTap: () => _choice(1),child: Container(padding: EdgeInsets.all(10), child: Text("${AppLocalizations.of(context).translate('search_restaurant')}", style: TextStyle(fontSize: 12, color: searchTypePosition == 1 ? this.filter_active_text_color:this.filter_unactive_text_color)),  decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_active_button_color :  this.filter_unactive_button_color,borderRadius: new BorderRadius.circular(30.0)))),
                          SizedBox(width: 5),
                          InkWell(onTap: () => _choice(2),child: Container(padding: EdgeInsets.all(10), child: Text("${AppLocalizations.of(context).translate('search_food')}", style: TextStyle(fontSize: 12, color: searchTypePosition == 1 ? this.filter_unactive_text_color : this.filter_active_text_color)),   decoration: BoxDecoration(color: searchTypePosition == 1 ? this.filter_unactive_button_color : this.filter_active_button_color,borderRadius: new BorderRadius.circular(30.0)))),
                        ]), duration: Duration(milliseconds: 3000),
                  ),
                  DropdownButton<String>(
                    value: _filterDropdownValue,
                    hint: Text("${AppLocalizations.of(context).translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor)),
                    /*Container(decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(5))), padding: EdgeInsets.all(5),
                        child: Text("${AppLocalizations.of(context).translate('filter')}".toUpperCase(), style: TextStyle(fontSize: 14,color:KColors.primaryColor))),
                    */
                    icon: Icon(FontAwesomeIcons.filter, color: KColors.primaryColor, size: 24,),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: KColors.primaryColor),
                    underline: Container(
//                      height: 2,
//                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        _filterDropdownValue = newValue;
                      });
                    },
                    items: <String>['${AppLocalizations.of(context).translate('cheap_to_exp')}', '${AppLocalizations.of(context).translate('exp_to_cheap')}', '${AppLocalizations.of(context).translate('nearest')}', '${AppLocalizations.of(context).translate('farest')}']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            SizedBox(height:15),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
//                  SizedBox(height: 40)
                    ]
                      ..add(
                        /* according to the search position, show a different page. */
                          searchTypePosition == 1 ? (
                              !_searchMode ?
                              /* List<Widget>.generate(data.length, (int index) {
                              return RestaurantListWidget(restaurantModel: data[index]);
                            }).toList()*/
                              Container(color: Colors.white,
                                height: MediaQuery.of(context).size.height,
//                              padding: EdgeInsets.only(bottom:230),
                                child: Scrollbar(
                                  isAlwaysShown: true,
                                  controller: _restaurantListScrollController,
                                  child: ListView.builder(
                                    controller: _restaurantListScrollController,
                                    itemCount: data?.length != null ? data.length + 1 : 0,
                                    itemBuilder: (context, index) {
                                      if (index == data?.length)
                                        return Container(height:100);
                                      return RestaurantListWidget(restaurantModel: data[index]);
                                    },
                                  ),
                                ),
                              )
                                  : _showSearchPage()) :
                          Container(
                              child: isSearchingMenus ? Center(child:CircularProgressIndicator()) :
                              (searchMenuHasNetworkError ? _buildSearchMenuNetworkErrorPage() :
                              searchMenuHasSystemError ? _buildSearchMenuSysErrorPage():
                              _buildSearchedFoodList())
                          )

                      )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _choice(int selected) {
    setState(() {
      this.searchTypePosition = selected;
    });
  }

  _checkLocationActivated () async {
//    return;
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("${AppLocalizations.of(context).translate('cant_get_location')}"),
              content: Text("${AppLocalizations.of(context).translate('please_enable_gps')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text('${AppLocalizations.of(context).translate('ok')}'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future _getLastKnowLocation() async {

    _checkLocationActivated();

    // save in to state container.
    Position position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    var geolocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    /* StreamSubscription<Position> positionStream =*/
    geolocator.getPositionStream(locationOptions).listen(
            (Position position) {
//          print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
          print("location :: ${position?.toJson()?.toString()}");
          if (position != null)
            StateContainer.of(context).updateLocation(location: position);
          if (StateContainer.of(context).location != null) {
            restaurantBloc.fetchRestaurantList(position: StateContainer
                .of(context)
                .location);
          }});
  }

  _buildSearchMenuNetworkErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(message:"${AppLocalizations.of(context).translate('sys_error')}", onClickAction: (){
      widget.presenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
    });
  }

  _buildSearchMenuSysErrorPage() {
    /* show a page that will help us search more back. */
    return ErrorPage(message:"${AppLocalizations.of(context).translate('network_error')}", onClickAction: (){
      widget.presenter.fetchRestaurantFoodProposalFromTag(_filterEditController.text);
    });
  }

  _buildSearchedFoodList() {
    if (foodProposals == null)
      return Container(child: Center(
          child: Column(children: <Widget>[
            SizedBox(height:20),
            Icon(Icons.restaurant, color: Colors.grey),
            SizedBox(height:10),
            Text("${AppLocalizations.of(context).translate('please_search_food')}")
          ])
      ));

    if (foodProposals?.length == 0) {
      return Container(child: Center(
          child: Column(children: <Widget>[
            SizedBox(height:20),
            Icon(Icons.restaurant, color: Colors.grey),
            SizedBox(height:10),
            Text("${AppLocalizations.of(context).translate('sorry_cant_find_food')}")
          ])
      ));
    }

    /* generating food proposals lazily */
    /*  return Column(children: <Widget>[]
      ..addAll(List<Widget>.generate(foodProposals?.length, (int index) {
        return FoodWithRestaurantDetailsWidget(food: foodProposals[index]);
      }).toList()));*/
    var filteredResult =  _filteredFoodProposal(_filterDropdownValue, foodProposals);

    firstItemKey = new GlobalKey();

    Future.delayed(Duration(seconds: 2), () {
      Scrollable.ensureVisible(firstItemKey.currentContext);
    });

    return Container(color: Colors.white,
      height: MediaQuery.of(context).size.height,
//      padding: EdgeInsets.only(bottom:230),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _searchListScrollController,
        child: ListView.builder(
          controller: _searchListScrollController,
          itemCount: filteredResult?.length != null ? filteredResult.length + 1 : 0,
          itemBuilder: (context, index) {
            if (index == filteredResult?.length)
              return Container(height:300);
            return FoodWithRestaurantDetailsWidget(key: index == 0 ? firstItemKey : null, food: filteredResult[index]);
          },
        ),
      ),
    );
  }

  List<RestaurantModel> _filterEditContent() {
    setState(() {});
    /* launching request to look for food, but at the same moment, we need to cancel previous links. */
  }

  _filteredData(List<RestaurantModel> data) {
    String content = _filterEditController.text;
    List<RestaurantModel> d = List();

    for (var restaurant in data) {
      if (removeAccentFromString("${restaurant.name}".toLowerCase()).contains(removeAccentFromString(content.trim().toLowerCase()))) {
        d.add(restaurant);
      }
    }
    return d;
  }

  String removeAccentFromString(String sentence) {

    return
      sentence
        ..replaceAll("é", "e")
        ..replaceAll("è", "e")
        ..replaceAll("ê", "e")
        ..replaceAll("ë", "e")
        ..replaceAll("ē", "e")
        ..replaceAll("ė", "e")
        ..replaceAll("ę", "e")

        ..replaceAll("à", "a")
        ..replaceAll("á", "a")
        ..replaceAll("â", "a")
        ..replaceAll("ä", "a")
        ..replaceAll("æ", "a")
        ..replaceAll("ã", "a")
        ..replaceAll("ā", "a")

        ..replaceAll("ô", "o")
        ..replaceAll("ö", "o")
        ..replaceAll("ò", "o")
        ..replaceAll("ó", "o")
        ..replaceAll("œ", "o")
        ..replaceAll("ø", "o")
        ..replaceAll("ō", "o")
        ..replaceAll("õ", "o")

        ..replaceAll("î", "i")
        ..replaceAll("ï", "i")
        ..replaceAll("í", "i")
        ..replaceAll("ī", "i")
        ..replaceAll("į", "i")
        ..replaceAll("ì", "i")

        ..replaceAll("û", "u")
        ..replaceAll("ü", "u")
        ..replaceAll("ù", "u")
        ..replaceAll("ú", "u")
        ..replaceAll("ū", "u")
    ;
  }

  void _clearFocus() {
    _filterEditController.clear();
  }

  void mToast(String message) {
    Toast.show(message, context, duration: Toast.LENGTH_LONG);
  }

  _showSearchPage() {
    /* show first few restaurants with a show more button, */
    /*  return <Widget>[]
      ..addAll(List<Widget>.generate(_filteredData(data).length, (int index) {
        return RestaurantListWidget(restaurantModel: _filteredData(data)[index]);
      }).toList())*/
    ;
    return Container(color: Colors.white,
      height: MediaQuery
          .of(context)
          .size
          .height,
      padding: EdgeInsets.only(bottom: 230),
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _restaurantListScrollController,
        child: ListView.builder(
          controller: _restaurantListScrollController,
          itemCount: _filteredData(data).length,
          itemBuilder: (context, index) {
            return RestaurantListWidget(
                restaurantModel: _filteredData(data)[index]);
          },
        ),
      ),
    );
  }


  @override
  void inflateFoodsProposal(List<RestaurantFoodModel> foods) {
    setState(() {

      for (var i = 0; i < foods?.length; i++) {
        if (foods[i]?.restaurant_entity?.id != null &&  pageRestaurants[foods[i]?.restaurant_entity?.id] != null) {
          // we get the restaurant and we switch it.
          foods[i].restaurant_entity =  pageRestaurants[foods[i]?.restaurant_entity?.id];
        }
      }

      this.foodProposals = foods;
    });
  }

  @override
  void searchMenuNetworkError() {
    setState(() {
      searchMenuHasNetworkError = true;
    });
  }


  @override
  void searchMenuSystemError() {
    setState(() {
      searchMenuHasSystemError = true;
    });
  }

  @override
  void searchMenuShowLoading(bool isLoading) {
    setState(() {
      if (isLoading == true) {
        this.searchMenuHasNetworkError = false;
        this.searchMenuHasSystemError = false;
      }
      this.isSearchingMenus = isLoading;
    });
  }

  _filteredFoodProposal(String filterDropdownValue, List<RestaurantFoodModel> foodProposals) {

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('cheap_to_exp')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      fd.sort((fd1, fd2) => int.parse(fd1.price).compareTo(int.parse(fd2.price)));
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('exp_to_cheap')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      fd.sort((fd1, fd2) => int.parse(fd2.price).compareTo(int.parse(fd1.price)));
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('farest')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      fd.sort((fd1, fd2) => int.parse(fd2.restaurant_entity?.delivery_pricing).compareTo(int.parse(fd1.restaurant_entity?.delivery_pricing)));
      return fd;
    }

    if (filterDropdownValue == ("${AppLocalizations.of(context).translate('nearest')}")) {
      // cheap to exp
      List<RestaurantFoodModel> fd = foodProposals;
      fd.sort((fd1, fd2) => int.parse(fd1?.restaurant_entity?.delivery_pricing).compareTo(int.parse(fd2?.restaurant_entity?.delivery_pricing)));
      return fd;
    }


    return foodProposals;
  }

}
